import { IdGenerator, Observable, Result, ResultError, TimeUtil } from 'common_core';
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
import { dataTransfer } from '@kit.NearLinkKit';
import { NearLinkConstants } from '../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';
import { CongestionPolicy } from '../../domain/model/DataTransferPortConfig';
import { NearLinkExtendedUseCases } from '../../domain/usecase/NearLinkExtendedUseCases';
import { DataTransferDataSource } from '../datasource/platform/DataTransferDataSource';

/**
 * NearLink dataTransfer transport per architecture 01-§4.1 and nearlink/03.
 */
export class NearLinkDataTransferSession implements ITransportSession {
  readonly id: string;
  readonly module: ModuleType = ModuleType.NEARLINK;
  readonly protocol: ProtocolType = ProtocolType.DATA_TRANSFER;
  readonly capabilities: TransportCapabilities;
  private currentState: TransportState = TransportState.IDLE;
  private readonly incomingObservable: Observable<IncomingPayload>;
  private readonly stateObservable: Observable<TransportStateSnapshot>;
  private readonly dataSource: DataTransferDataSource;
  private readonly congestionPolicy: CongestionPolicy;
  private address: string = '';
  private portUuid: string = '';
  private mtu: number = NearLinkConstants.DEFAULT_MTU;
  private handlersRegistered: boolean = false;

  constructor(
    sessionId: string,
    dataSource: DataTransferDataSource,
    congestionPolicy: CongestionPolicy = new CongestionPolicy()
  ) {
    this.id = sessionId.length > 0 ? sessionId : IdGenerator.next('nl-dt');
    this.dataSource = dataSource;
    this.congestionPolicy = congestionPolicy;
    this.capabilities = new TransportCapabilities(
      true,
      true,
      NearLinkConstants.MAX_MTU,
      false,
      true,
      true,
      false,
      false,
      false
    );
    this.incomingObservable = new Observable<IncomingPayload>(
      new IncomingPayload(new Uint8Array(0), 0, true)
    );
    this.stateObservable = new Observable<TransportStateSnapshot>(
      new TransportStateSnapshot(TransportState.IDLE)
    );
  }

  get state(): TransportState {
    return this.currentState;
  }

  async connect(params: Record<string, string | number | boolean>): Promise<void> {
    this.address = `${params['address'] ?? params['deviceId'] ?? ''}`;
    this.portUuid = `${params['uuid'] ?? params['portUuid'] ?? ''}`;
    this.mtu = Number(params['mtu'] ?? NearLinkConstants.DEFAULT_MTU);
    if (this.address.length === 0 || this.portUuid.length === 0) {
      this.transition(TransportState.FAILED, 'address or uuid missing');
      throw new Error('dataTransfer address/uuid required');
    }
    this.transition(TransportState.CONNECTING);
    if (!this.handlersRegistered) {
      this.dataSource.onReadData((info: dataTransfer.DataParams) => {
        if (info.address !== this.address || info.uuid !== this.portUuid) {
          return;
        }
        const bytes = new Uint8Array(info.data);
        if (bytes.length > 0) {
          this.incomingObservable.next(new IncomingPayload(bytes, TimeUtil.nowMs(), true));
        }
      });
      this.dataSource.onConnectionStateChanged((_info: dataTransfer.ConnectionResult) => {
        this.transition(TransportState.CONNECTED);
      });
      this.handlersRegistered = true;
    }
    const port = this.dataSource.createPort(this.portUuid);
    if (!port.success) {
      this.transition(TransportState.FAILED, port.error?.message ?? 'createPort failed');
      throw new Error(port.error?.message ?? 'createPort failed');
    }
    const connected = await this.dataSource.connect(this.address, this.portUuid, this.mtu);
    if (!connected.success) {
      this.transition(TransportState.FAILED, connected.error?.message ?? 'connect failed');
      throw new Error(connected.error?.message ?? 'connect failed');
    }
    this.transition(TransportState.CONNECTED);
  }

  async disconnect(reason: string): Promise<void> {
    if (this.currentState === TransportState.DISCONNECTED && !this.handlersRegistered) {
      return;
    }
    this.transition(TransportState.DISCONNECTING, reason);
    if (this.address.length > 0 && this.portUuid.length > 0) {
      await this.dataSource.disconnect(this.address, this.portUuid);
    }
    this.dataSource.release(this.portUuid);
    this.handlersRegistered = false;
    this.transition(TransportState.DISCONNECTED, reason);
  }

  async write(payload: Uint8Array, _options?: WriteOptions): Promise<WriteResult> {
    if (this.currentState !== TransportState.CONNECTED) {
      return new WriteResult(false, 0, NearLinkErrorCodes.NOT_CONNECTED, 'dataTransfer not connected');
    }
    const buffer = payload.buffer.slice(payload.byteOffset, payload.byteOffset + payload.byteLength);
    let backoff = this.congestionPolicy.initialBackoffMs;
    for (let attempt = 0; attempt <= this.congestionPolicy.maxRetryCount; attempt++) {
      const result = await this.dataSource.writeData(this.address, this.portUuid, buffer);
      if (result.success) {
        return new WriteResult(true, payload.length);
      }
      if (result.error?.code !== NearLinkErrorCodes.DT_WRITE_CONGESTED) {
        return new WriteResult(
          false,
          0,
          result.error?.code ?? NearLinkErrorCodes.DT_GENERIC_FAILED,
          result.error?.message ?? 'write failed'
        );
      }
      this.transition(TransportState.CONNECTED, 'congested');
      await NearLinkExtendedUseCases.sleep(backoff);
      backoff = Math.min(backoff * 2, this.congestionPolicy.maxBackoffMs);
    }
    return new WriteResult(false, 0, NearLinkErrorCodes.DT_WRITE_CONGESTED, 'Write congested after retries');
  }

  observeIncoming(): Observable<IncomingPayload> {
    return this.incomingObservable;
  }

  observeState(): Observable<TransportStateSnapshot> {
    return this.stateObservable;
  }

  destroy(): void {
    if (this.currentState === TransportState.DISCONNECTED && !this.handlersRegistered) {
      this.incomingObservable.clearObservers();
      this.stateObservable.clearObservers();
      return;
    }
    void this.disconnect('destroy');
    this.incomingObservable.clearObservers();
    this.stateObservable.clearObservers();
  }

  private transition(state: TransportState, reason: string = ''): void {
    this.currentState = state;
    this.stateObservable.next(new TransportStateSnapshot(state, reason, TimeUtil.nowMs()));
  }
}
