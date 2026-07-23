import { IdGenerator, Observable, TimeUtil } from 'common_core';
import {
  ModuleType,
  ProtocolType,
  TransportState
} from 'feature_debug_core';
import {
  ITransportSession,
  IncomingPayload,
  TransportCapabilities,
  TransportStateSnapshot,
  WriteOptions,
  WriteResult
} from 'feature_debug_core';
import { BluetoothConstants } from '../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';
import { SppConnectParams } from '../../domain/model/SppConnectParams';
import { ReconnectPolicy } from '../../domain/model/ReconnectPolicy';
import { SppConnectOptions, SppSocketDataSource } from '../datasource/platform/SppSocketDataSource';
import { SppReadStrategy } from '../../domain/model/SppRuntimeState';
import { PairingState } from '../../domain/model/PairingState';
import { BluetoothRepository } from '../repository/BluetoothRepository';

/**
 * SPP RFCOMM transport session. Read loop uses sequential sppReadAsync per WSL FAQ faqs-connectivity-33.
 */
export class SppTransportSession implements ITransportSession {
  readonly id: string;
  readonly module: ModuleType = ModuleType.BLUETOOTH;
  readonly protocol: ProtocolType = ProtocolType.SPP;
  readonly capabilities: TransportCapabilities;
  private currentState: TransportState = TransportState.IDLE;
  private readonly incomingObservable: Observable<IncomingPayload>;
  private readonly stateObservable: Observable<TransportStateSnapshot>;
  private readonly socketDataSource: SppSocketDataSource;
  private clientSocket: number = -1;
  private readLoopActive: boolean = false;
  private readCancelled: boolean = false;
  private useEventRead: boolean = false;
  private connectParams: SppConnectParams | undefined;
  private userDisconnect: boolean = false;
  private reconnectAttempts: number = 0;
  private reconnectScheduled: boolean = false;
  private consecutiveReadFailures: number = 0;
  private readStrategy: SppReadStrategy = SppReadStrategy.ASYNC_LOOP;
  private static readonly MAX_ASYNC_READ_FAILURES: number = 3;

  constructor(
    sessionId: string,
    socketDataSource: SppSocketDataSource = SppSocketDataSource.getInstance()
  ) {
    this.id = sessionId.length > 0 ? sessionId : IdGenerator.next('spp');
    this.socketDataSource = socketDataSource;
    this.capabilities = new TransportCapabilities(
      true,
      false,
      BluetoothConstants.SPP_MAX_WRITE_BYTES,
      false,
      false,
      true,
      false,
      true,
      false
    );
    this.incomingObservable = new Observable<IncomingPayload>(
      new IncomingPayload(new Uint8Array(0), 0)
    );
    this.stateObservable = new Observable<TransportStateSnapshot>(
      new TransportStateSnapshot(TransportState.IDLE)
    );
  }

  get state(): TransportState {
    return this.currentState;
  }

  async connect(params: Record<string, string | number | boolean>): Promise<void> {
    const classicDeviceId = `${params['classicDeviceId'] ?? ''}`;
    if (classicDeviceId.length === 0) {
      throw new Error('classicDeviceId required for SPP');
    }
    const displayName = `${params['displayName'] ?? classicDeviceId}`;
    const uuid = `${params['uuid'] ?? BluetoothConstants.DEFAULT_SPP_UUID}`;
    const secure = params['secure'] === true || params['secure'] === 1;
    const autoReconnect = params['autoReconnect'] === true || params['autoReconnect'] === 1;
    const reconnectPolicy = new ReconnectPolicy(
      Number(params['maxReconnectAttempts'] ?? 5),
      Number(params['reconnectInitialDelayMs'] ?? 1000),
      Number(params['reconnectMaxDelayMs'] ?? 15000),
      Number(params['reconnectBackoffFactor'] ?? 2)
    );
    this.connectParams = new SppConnectParams(
      classicDeviceId,
      displayName,
      uuid,
      secure,
      Number(params['timeoutMs'] ?? BluetoothConstants.DEFAULT_SPP_CONNECT_TIMEOUT_MS),
      autoReconnect,
      reconnectPolicy
    );
    this.userDisconnect = false;
    this.reconnectAttempts = 0;
    await this.openSocket();
  }

  private async openSocket(): Promise<void> {
    if (this.connectParams === undefined) {
      throw new Error('SPP connect params missing');
    }
    this.transition(TransportState.CONNECTING);
    const params = this.connectParams;
    const connected = await this.socketDataSource.connect(
      new SppConnectOptions(params.classicDeviceId, params.uuid, params.secure)
    );
    if (!connected.success || connected.value === undefined) {
      this.transition(TransportState.FAILED, connected.error?.message ?? 'connect failed');
      throw new Error(connected.error?.message ?? 'SPP connect failed');
    }
    this.clientSocket = connected.value;
    this.reconnectAttempts = 0;
    this.transition(TransportState.CONNECTED);
    this.startReadLoop();
  }

  async disconnect(reason: string): Promise<void> {
    this.userDisconnect = true;
    this.reconnectScheduled = false;
    this.transition(TransportState.DISCONNECTING, reason);
    this.stopReadLoop();
    if (this.clientSocket >= 0) {
      this.socketDataSource.close(this.clientSocket);
      this.clientSocket = -1;
    }
    this.transition(TransportState.DISCONNECTED, reason);
  }

  async write(payload: Uint8Array, _options?: WriteOptions): Promise<WriteResult> {
    if (this.currentState !== TransportState.CONNECTED || this.clientSocket < 0) {
      return new WriteResult(false, 0, BluetoothErrorCodes.NOT_CONNECTED, 'SPP not connected');
    }
    const written = await this.socketDataSource.writeAsync(this.clientSocket, payload);
    if (!written.success) {
      if (this.shouldAutoReconnect()) {
        await this.scheduleReconnect(written.error?.message ?? 'write failed');
        return new WriteResult(false, 0, written.error?.code ?? BluetoothErrorCodes.SPP_IO_ERROR, written.error?.message ?? 'write failed');
      }
      return new WriteResult(
        false,
        0,
        written.error?.code ?? BluetoothErrorCodes.SPP_IO_ERROR,
        written.error?.message ?? 'write failed'
      );
    }
    return new WriteResult(true, written.value ?? payload.length);
  }

  observeIncoming(): Observable<IncomingPayload> {
    return this.incomingObservable;
  }

  observeState(): Observable<TransportStateSnapshot> {
    return this.stateObservable;
  }

  destroy(): void {
    this.userDisconnect = true;
    this.reconnectScheduled = false;
    this.stopReadLoop();
    if (this.clientSocket >= 0) {
      this.socketDataSource.close(this.clientSocket);
      this.clientSocket = -1;
    }
    this.incomingObservable.clearObservers();
    this.stateObservable.clearObservers();
  }

  private startReadLoop(): void {
    if (this.readLoopActive || this.clientSocket < 0) {
      return;
    }
    if (this.useEventRead) {
      this.startEventRead();
      return;
    }
    this.readLoopActive = true;
    this.readCancelled = false;
    void this.readLoopAsync();
  }

  private startEventRead(): void {
    this.readStrategy = SppReadStrategy.EVENT_CALLBACK;
    const subscribed = this.socketDataSource.onSppRead(this.clientSocket, (bytes: Uint8Array) => {
      if (bytes.length > 0) {
        this.incomingObservable.next(new IncomingPayload(bytes, TimeUtil.nowMs(), false));
      }
    });
    if (!subscribed.success) {
      this.transition(TransportState.FAILED, subscribed.error?.message ?? 'SPP event read failed');
    }
  }

  private async readLoopAsync(): Promise<void> {
    while (this.readLoopActive && !this.readCancelled && this.clientSocket >= 0) {
      const read = await this.socketDataSource.readAsync(this.clientSocket);
      if (!read.success) {
        this.consecutiveReadFailures = this.consecutiveReadFailures + 1;
        if (this.consecutiveReadFailures >= SppTransportSession.MAX_ASYNC_READ_FAILURES && !this.useEventRead) {
          this.useEventRead = true;
          this.readLoopActive = false;
          this.startEventRead();
          return;
        }
        await this.handleReadFailure(read.error?.message ?? 'read failed');
        break;
      }
      this.consecutiveReadFailures = 0;
      if (read.value !== undefined && read.value.length > 0) {
        this.incomingObservable.next(new IncomingPayload(read.value, TimeUtil.nowMs(), false));
      }
    }
    this.readLoopActive = false;
    if (this.currentState === TransportState.CONNECTED && !this.userDisconnect) {
      await this.handleReadFailure('read loop ended');
    }
  }

  private async handleReadFailure(reason: string): Promise<void> {
    this.stopReadLoop();
    if (this.clientSocket >= 0) {
      this.socketDataSource.close(this.clientSocket);
      this.clientSocket = -1;
    }
    if (this.shouldAutoReconnect()) {
      await this.scheduleReconnect(reason);
      return;
    }
    this.transition(TransportState.FAILED, reason);
  }

  private shouldAutoReconnect(): boolean {
    if (this.userDisconnect || this.connectParams === undefined) {
      return false;
    }
    if (!this.connectParams.autoReconnect) {
      return false;
    }
    return this.reconnectAttempts < this.connectParams.reconnectPolicy.maxAttempts;
  }

  private async scheduleReconnect(reason: string): Promise<void> {
    if (this.reconnectScheduled || this.connectParams === undefined) {
      return;
    }
    if (this.connectParams.reconnectPolicy.stopOnPairLost) {
      const pairState = await BluetoothRepository.getInstance().getPairState(this.connectParams.classicDeviceId);
      if (pairState.success && pairState.value === PairingState.UNPAIRED) {
        this.transition(TransportState.FAILED, 'pair lost');
        return;
      }
    }
    await BluetoothRepository.getInstance().ensureClassicDiscoveryStopped();
    this.reconnectScheduled = true;
    const attempt = this.reconnectAttempts;
    this.reconnectAttempts = attempt + 1;
    const delayMs = this.connectParams.reconnectPolicy.computeDelayMs(attempt);
    this.transition(TransportState.CONNECTING, `reconnecting:${reason}`);
    await new Promise<void>((resolve: () => void) => {
      setTimeout(() => resolve(), delayMs);
    });
    this.reconnectScheduled = false;
    if (this.userDisconnect) {
      return;
    }
    try {
      await this.openSocket();
    } catch (_error) {
      if (this.shouldAutoReconnect()) {
        await this.scheduleReconnect('reconnect failed');
      } else {
        this.transition(TransportState.FAILED, 'reconnect exhausted');
      }
    }
  }

  private stopReadLoop(): void {
    this.readCancelled = true;
    this.readLoopActive = false;
    this.socketDataSource.offSppRead();
  }

  private transition(state: TransportState, reason: string = ''): void {
    this.currentState = state;
    this.stateObservable.next(new TransportStateSnapshot(state, reason, TimeUtil.nowMs()));
  }
}
