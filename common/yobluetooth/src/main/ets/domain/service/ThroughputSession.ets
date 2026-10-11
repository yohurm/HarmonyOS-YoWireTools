import { CancellationTokenSource, Result, ResultError, TimeUtil } from 'common_core';
import { LogCaptureService, ModuleType, ProtocolType } from 'debug_core';
import { BluetoothConstants } from '../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';
import { GattWriteChunker } from './GattWriteChunker';

export class ThroughputSnapshot {
  readonly bytesSent: number;
  readonly elapsedMs: number;
  readonly running: boolean;
  readonly chunkCount: number;

  constructor(bytesSent: number, elapsedMs: number, running: boolean, chunkCount: number) {
    this.bytesSent = bytesSent;
    this.elapsedMs = elapsedMs;
    this.running = running;
    this.chunkCount = chunkCount;
  }
}

/**
 * GATT throughput write. Per-packet hex is paused on LogCaptureService for this session.
 */
export class ThroughputSession {
  private readonly cancelSource: CancellationTokenSource = new CancellationTokenSource();
  private bytesSent: number = 0;
  private chunkCount: number = 0;
  private startedAtMs: number = 0;
  private running: boolean = false;
  private sessionId: string = '';

  snapshot(): ThroughputSnapshot {
    const elapsed = this.startedAtMs > 0 ? TimeUtil.monotonicMs() - this.startedAtMs : 0;
    return new ThroughputSnapshot(this.bytesSent, elapsed, this.running, this.chunkCount);
  }

  async run(
    sessionId: string,
    payload: Uint8Array,
    mtu: number,
    writeChunk: (chunk: Uint8Array) => Promise<Result<void>>
  ): Promise<Result<ThroughputSnapshot>> {
    this.sessionId = sessionId;
    this.bytesSent = 0;
    this.chunkCount = 0;
    this.startedAtMs = TimeUtil.monotonicMs();
    this.running = true;
    LogCaptureService.getInstance().setPacketCapturePaused(sessionId, true);
    const chunks = GattWriteChunker.chunk(payload, mtu > 0 ? mtu : BluetoothConstants.BLE_DEFAULT_MTU);
    for (let i = 0; i < chunks.length; i++) {
      if (this.cancelSource.isCancelled) {
        break;
      }
      const written = await writeChunk(chunks[i]);
      if (!written.success) {
        this.running = false;
        LogCaptureService.getInstance().setPacketCapturePaused(sessionId, false);
        return Result.fail(written.error ?? new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, 'throughput write failed'));
      }
      this.bytesSent += chunks[i].length;
      this.chunkCount++;
    }
    this.running = false;
    LogCaptureService.getInstance().setPacketCapturePaused(sessionId, false);
    return Result.ok(this.snapshot());
  }

  stop(): ThroughputSnapshot {
    this.cancelSource.cancel();
    this.running = false;
    if (this.sessionId.length > 0) {
      LogCaptureService.getInstance().setPacketCapturePaused(this.sessionId, false);
    }
    return this.snapshot();
  }
}

export class ThroughputLogMarker {
  static module(): ModuleType {
    return ModuleType.BLUETOOTH;
  }

  static protocol(): ProtocolType {
    return ProtocolType.BLE_GATT;
  }
}
