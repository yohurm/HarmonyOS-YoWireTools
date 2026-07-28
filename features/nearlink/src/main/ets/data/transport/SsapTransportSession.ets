import { IdGenerator, Observable, Result, ResultError, TimeUtil } from 'common_core';
import {
  ModuleType,
  ProtocolType,
  TransportState
} from 'debug_core';
import {
  ITransportSession,
  IncomingPayload,
  TransportCapabilities,
  TransportStateSnapshot,
  WriteOptions,
  WriteResult
} from 'debug_core';
import { ssap } from '@kit.NearLinkKit';
import { NearLinkConstants } from '../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';
import { SsapOperationQueue } from '../../domain/service/SsapOperationQueue';
import { SsapClientDataSource } from '../datasource/platform/SsapClientDataSource';

/**
 * SSAP property transport for command panel per architecture 01-搂4.1.
 * Attaches to an existing SSAP client session; endpoints bound via bindEndpoints().
 */
export class SsapTransportSession implements ITransportSession {
  readonly id: string;
  readonly module: ModuleType = ModuleType.NEARLINK;
  readonly protocol: ProtocolType = ProtocolType.SSAP;
  readonly capabilities: TransportCapabilities;
  private currentState: TransportState = TransportState.IDLE;
  private readonly incomingObservable: Observable<IncomingPayload>;
  private readonly stateObservable: Observable<TransportStateSnapshot>;
  private readonly dataSource: SsapClientDataSource;
  private readonly operationQueue: SsapOperationQueue = new SsapOperationQueue();
  private serviceUuid: string = '';
  private propertyUuid: string = '';
  private notifyPropertyUuid: string = '';
  private sessionId: string = '';
  private endpointsBound: boolean = false;
  private propertyHandler: ((property: ssap.Property) => void) | undefined;

  constructor(sessionId: string, dataSource: SsapClientDataSource) {
    this.id = sessionId.length > 0 ? sessionId : IdGenerator.next('nl-ssap');
    this.sessionId = sessionId;
    this.dataSource = dataSource;
    this.capabilities = new TransportCapabilities(
      true,
      false,
      NearLinkConstants.MAX_MTU,
      true,
      true,
      false,
      false,
      false,
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

  bindEndpoints(serviceUuid: string, propertyUuid: string, notifyPropertyUuid: string = ''): Result<void> {
    this.serviceUuid = serviceUuid;
    this.propertyUuid = propertyUuid;
    this.notifyPropertyUuid = notifyPropertyUuid.length > 0 ? notifyPropertyUuid : propertyUuid;
    this.endpointsBound = this.serviceUuid.length > 0 && this.propertyUuid.length > 0;
    if (!this.endpointsBound) {
      return Result.fail(new ResultError(NearLinkErrorCodes.SSAP_READ_FAILED, 'SSAP endpoints not bound'));
    }
    this.registerPropertyHandler();
    this.transition(TransportState.CONNECTED, 'endpoints_bound');
    return Result.ok(undefined);
  }

  async connect(_params: Record<string, string | number | boolean>): Promise<void> {
    this.transition(TransportState.CONNECTED, 'attached_to_ssap_client');
  }

  async disconnect(reason: string): Promise<void> {
    if (this.currentState === TransportState.DISCONNECTED) {
      return;
    }
    this.transition(TransportState.DISCONNECTING, reason);
    if (this.propertyHandler !== undefined) {
      this.dataSource.offPropertyChange();
      this.propertyHandler = undefined;
    }
    this.operationQueue.reset();
    this.transition(TransportState.DISCONNECTED, reason);
  }

  async write(payload: Uint8Array, _options?: WriteOptions): Promise<WriteResult> {
    if (!this.endpointsBound) {
      return new WriteResult(false, 0, NearLinkErrorCodes.NOT_CONNECTED, 'SSAP endpoints not bound');
    }
    const buffer = payload.buffer.slice(payload.byteOffset, payload.byteOffset + payload.byteLength);
    const written = await this.operationQueue.enqueue(() =>
      this.dataSource.writeProperty(this.serviceUuid, this.propertyUuid, buffer)
    );
    if (!written.success) {
      return new WriteResult(
        false,
        0,
        written.error?.code ?? NearLinkErrorCodes.SSAP_WRITE_FAILED,
        written.error?.message ?? 'SSAP write failed',
        written.error?.nativeCode ?? ''
      );
    }
    // Outbound evidence is owned by SendCommandUseCase — do not capture here.
    return new WriteResult(true, payload.length);
  }

  observeIncoming(): Observable<IncomingPayload> {
    return this.incomingObservable;
  }

  observeState(): Observable<TransportStateSnapshot> {
    return this.stateObservable;
  }

  destroy(): void {
    if (this.currentState === TransportState.DISCONNECTED) {
      this.incomingObservable.clearObservers();
      this.stateObservable.clearObservers();
      return;
    }
    void this.disconnect('destroy');
    this.incomingObservable.clearObservers();
    this.stateObservable.clearObservers();
  }

  private registerPropertyHandler(): void {
    if (this.propertyHandler !== undefined) {
      this.dataSource.offPropertyChange();
    }
    this.propertyHandler = (property: ssap.Property) => {
      if (property.serviceUuid !== this.serviceUuid || property.propertyUuid !== this.notifyPropertyUuid) {
        return;
      }
      if (property.value === undefined) {
        return;
      }
      const bytes = new Uint8Array(property.value);
      if (bytes.length > 0) {
        // Inbound evidence is owned by TransportLogBinder — do not capture here.
        this.incomingObservable.next(new IncomingPayload(bytes, TimeUtil.nowMs(), false));
      }
    };
    this.dataSource.onPropertyChange(this.propertyHandler);
  }

  private transition(state: TransportState, reason: string = ''): void {
    this.currentState = state;
    this.stateObservable.next(new TransportStateSnapshot(state, reason, TimeUtil.nowMs()));
  }
}
