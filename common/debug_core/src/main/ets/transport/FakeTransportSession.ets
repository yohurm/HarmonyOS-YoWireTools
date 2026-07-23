import { Observable, TimeUtil } from 'common_core';
import {
  ModuleType,
  ProtocolType,
  TransportState
} from '../domain/enums/DomainEnums';
import {
  ITransportSession,
  IncomingPayload,
  TransportCapabilities,
  TransportStateSnapshot,
  WriteOptions,
  WriteResult
} from './TransportContracts';

/**
 * In-memory transport for Phase 0 fake session/log validation.
 */
export class FakeTransportSession implements ITransportSession {
  readonly id: string;
  readonly module: ModuleType;
  readonly protocol: ProtocolType;
  readonly capabilities: TransportCapabilities;
  private currentState: TransportState = TransportState.IDLE;
  private readonly incomingObservable: Observable<IncomingPayload>;
  private readonly stateObservable: Observable<TransportStateSnapshot>;

  constructor(id: string, module: ModuleType, protocol: ProtocolType) {
    this.id = id;
    this.module = module;
    this.protocol = protocol;
    this.capabilities = new TransportCapabilities(true, false, 65535, true, true, false, false, true, true);
    this.incomingObservable = new Observable<IncomingPayload>(new IncomingPayload(new Uint8Array(0), 0));
    this.stateObservable = new Observable<TransportStateSnapshot>(
      new TransportStateSnapshot(TransportState.IDLE)
    );
  }

  get state(): TransportState {
    return this.currentState;
  }

  async connect(_params: Record<string, string | number | boolean>): Promise<void> {
    this.transition(TransportState.CONNECTING);
    this.transition(TransportState.CONNECTED);
  }

  async disconnect(reason: string): Promise<void> {
    this.transition(TransportState.DISCONNECTING, reason);
    this.transition(TransportState.DISCONNECTED, reason);
  }

  async write(payload: Uint8Array, _options?: WriteOptions): Promise<WriteResult> {
    if (this.currentState !== TransportState.CONNECTED) {
      return new WriteResult(false, 0, 'YW-CMD-1002', 'Transport not connected');
    }
    return new WriteResult(true, payload.length);
  }

  observeIncoming(): Observable<IncomingPayload> {
    return this.incomingObservable;
  }

  observeState(): Observable<TransportStateSnapshot> {
    return this.stateObservable;
  }

  emitIncoming(bytes: Uint8Array): void {
    this.incomingObservable.next(new IncomingPayload(bytes, TimeUtil.nowMs(), false));
  }

  destroy(): void {
    this.incomingObservable.clearObservers();
    this.stateObservable.clearObservers();
  }

  private transition(state: TransportState, reason: string = ''): void {
    this.currentState = state;
    this.stateObservable.next(new TransportStateSnapshot(state, reason, TimeUtil.nowMs()));
  }
}
