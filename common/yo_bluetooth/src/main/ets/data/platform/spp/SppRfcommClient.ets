import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { SppReadStrategy } from '../../../domain/model/SppRuntimeState';
import { SppPlatformGateway, SppRfcommConnectRequest } from './SppPlatformGateway';

type IncomingListener = (bytes: Uint8Array) => void;
type LinkLostListener = (reason: string) => void;

/**
 * One HarmonyOS RFCOMM clientSocket lifecycle (architecture 02 L2).
 *
 * Multi-session rules:
 * - Prefer sppReadAsync serial loop (safe for N parallel sockets)
 * - on('sppRead') is per-socket fallback only; never share one global subscription
 * - Close order: stop read → off('sppRead') if used → sppCloseClientSocket
 * - Connect timeout cancel token: late-arriving clientSocket is closed immediately
 */
export class SppRfcommClient {
  private readonly gateway: SppPlatformGateway;
  private clientSocket: number = -1;
  private readStrategy: SppReadStrategy = SppReadStrategy.ASYNC_LOOP;
  private readLoopActive: boolean = false;
  private readCancelled: boolean = false;
  private unsubscribeRead: (() => void) | undefined;
  private incomingListener: IncomingListener | undefined;
  private linkLostListener: LinkLostListener | undefined;
  private linkLostEmitted: boolean = false;
  private consecutiveReadFailures: number = 0;
  private connectGeneration: number = 0;
  private cancelledConnectGeneration: number = -1;
  private static readonly MAX_ASYNC_READ_FAILURES: number = 3;

  constructor(gateway: SppPlatformGateway = new SppPlatformGateway()) {
    this.gateway = gateway;
  }

  get socketId(): number {
    return this.clientSocket;
  }

  get activeReadStrategy(): SppReadStrategy {
    return this.readStrategy;
  }

  isOpen(): boolean {
    return this.clientSocket >= 0;
  }

  setIncomingListener(listener: IncomingListener | undefined): void {
    this.incomingListener = listener;
  }

  setLinkLostListener(listener: LinkLostListener | undefined): void {
    this.linkLostListener = listener;
  }

  async open(request: SppRfcommConnectRequest, timeoutMs: number): Promise<Result<void>> {
    if (this.isOpen()) {
      return Result.fail(new ResultError(BluetoothErrorCodes.OPERATION_BUSY, 'RFCOMM client already open'));
    }
    this.resetRuntimeFlags();
    this.connectGeneration = this.connectGeneration + 1;
    const attemptId = this.connectGeneration;
    const connected = await this.raceConnect(this.gateway.connect(request), timeoutMs, attemptId);
    if (!connected.success || connected.value === undefined) {
      return Result.fail(connected.error ?? new ResultError(BluetoothErrorCodes.SPP_CONNECT_FAILED, 'connect failed'));
    }
    if (attemptId !== this.connectGeneration || this.cancelledConnectGeneration === attemptId) {
      this.gateway.closeClient(connected.value);
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_CONNECT_TIMEOUT, 'connect attempt superseded'));
    }
    this.clientSocket = connected.value;
    this.readStrategy = SppReadStrategy.ASYNC_LOOP;
    this.startAsyncReadLoop();
    return Result.ok(undefined);
  }

  async write(bytes: Uint8Array): Promise<Result<number>> {
    if (!this.isOpen()) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'RFCOMM not open'));
    }
    const written = await this.gateway.writeAsync(this.clientSocket, bytes);
    if (!written.success && SppRfcommClient.isFatalIo(written.error)) {
      this.emitLinkLost(written.error?.message ?? 'write failed');
    }
    return written;
  }

  /**
   * Stop read, off('sppRead') if event-read, then sppCloseClientSocket.
   */
  async close(): Promise<void> {
    this.readCancelled = true;
    this.readLoopActive = false;
    const unsub = this.unsubscribeRead;
    this.unsubscribeRead = undefined;
    const socketId = this.clientSocket;
    this.clientSocket = -1;
    if (socketId >= 0) {
      this.gateway.closeClient(socketId, unsub);
    }
  }

  private startAsyncReadLoop(): void {
    if (this.readLoopActive || !this.isOpen()) {
      return;
    }
    this.readLoopActive = true;
    this.readCancelled = false;
    void this.readLoopAsync();
  }

  private async readLoopAsync(): Promise<void> {
    const socketId = this.clientSocket;
    while (this.readLoopActive && !this.readCancelled && this.clientSocket === socketId && socketId >= 0) {
      const read = await this.gateway.readAsync(socketId);
      if (this.readCancelled || this.clientSocket !== socketId) {
        break;
      }
      if (!read.success) {
        if (SppRfcommClient.isFatalIo(read.error)) {
          this.readLoopActive = false;
          this.emitLinkLost(read.error?.message ?? 'read failed');
          return;
        }
        this.consecutiveReadFailures = this.consecutiveReadFailures + 1;
        if (this.consecutiveReadFailures >= SppRfcommClient.MAX_ASYNC_READ_FAILURES &&
          this.readStrategy === SppReadStrategy.ASYNC_LOOP) {
          const fallback = this.activateEventReadFallback();
          if (fallback.success) {
            return;
          }
        }
        this.readLoopActive = false;
        this.emitLinkLost(read.error?.message ?? 'read failed');
        return;
      }
      this.consecutiveReadFailures = 0;
      if (read.value !== undefined && read.value.length > 0 && this.incomingListener !== undefined) {
        this.incomingListener(read.value);
      }
    }
    this.readLoopActive = false;
    if (!this.readCancelled && this.isOpen()) {
      this.emitLinkLost('read loop ended');
    }
  }

  /**
   * Fallback when sppReadAsync is unavailable — one socket, one on('sppRead') subscription.
   * Must never mix with sppReadAsync on the same clientSocket.
   */
  activateEventReadFallback(): Result<void> {
    if (!this.isOpen()) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'RFCOMM not open'));
    }
    this.readCancelled = true;
    this.readLoopActive = false;
    if (this.unsubscribeRead !== undefined) {
      this.unsubscribeRead();
      this.unsubscribeRead = undefined;
    }
    this.readStrategy = SppReadStrategy.EVENT_CALLBACK;
    const subscribed = this.gateway.subscribeRead(this.clientSocket, (bytes: Uint8Array) => {
      if (bytes.length > 0 && this.incomingListener !== undefined) {
        this.incomingListener(bytes);
      }
    });
    if (!subscribed.success || subscribed.value === undefined) {
      return Result.fail(subscribed.error ?? new ResultError(BluetoothErrorCodes.SPP_IO_ERROR, 'event read failed'));
    }
    this.unsubscribeRead = subscribed.value;
    this.readCancelled = false;
    return Result.ok(undefined);
  }

  private emitLinkLost(reason: string): void {
    if (this.linkLostEmitted) {
      return;
    }
    this.linkLostEmitted = true;
    this.readCancelled = true;
    this.readLoopActive = false;
    this.linkLostListener?.(reason);
  }

  private resetRuntimeFlags(): void {
    this.readCancelled = false;
    this.readLoopActive = false;
    this.linkLostEmitted = false;
    this.consecutiveReadFailures = 0;
    this.unsubscribeRead = undefined;
    this.readStrategy = SppReadStrategy.ASYNC_LOOP;
  }

  /**
   * Cancel-token race for sppConnect.
   * If timeout wins and connect later succeeds, the late clientSocket is closed immediately
   * to prevent socket leak (architecture 02 §5.3).
   */
  private raceConnect(
    connectPromise: Promise<Result<number>>,
    timeoutMs: number,
    attemptId: number
  ): Promise<Result<number>> {
    if (timeoutMs <= 0) {
      return connectPromise;
    }
    return new Promise((resolve: (value: Result<number>) => void) => {
      let settled = false;
      const timer = setTimeout(() => {
        if (settled) {
          return;
        }
        settled = true;
        this.cancelledConnectGeneration = attemptId;
        resolve(Result.fail(new ResultError(
          BluetoothErrorCodes.SPP_CONNECT_TIMEOUT,
          `sppConnect exceeded ${timeoutMs}ms`
        )));
      }, timeoutMs);
      connectPromise.then((result: Result<number>) => {
        if (this.cancelledConnectGeneration === attemptId) {
          // Late success for THIS timed-out attempt only; never close another session's socket.
          if (result.success && result.value !== undefined && result.value >= 0 &&
            this.clientSocket !== result.value) {
            this.gateway.closeClient(result.value);
          }
          return;
        }
        if (settled) {
          return;
        }
        settled = true;
        clearTimeout(timer);
        resolve(result);
      });
    });
  }

  private static isFatalIo(error: ResultError | undefined): boolean {
    if (error === undefined) {
      return true;
    }
    return error.code === BluetoothErrorCodes.SPP_IO_ERROR ||
      error.code === BluetoothErrorCodes.DISCONNECTED ||
      error.code === BluetoothErrorCodes.ADAPTER_OFF;
  }
}
