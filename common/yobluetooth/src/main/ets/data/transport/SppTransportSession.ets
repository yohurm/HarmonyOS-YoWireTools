import { IdGenerator, Observable, TimeUtil } from 'common_core';
import {
  ITransportSession,
  IncomingPayload,
  ModuleType,
  ProtocolType,
  TransportCapabilities,
  TransportState,
  TransportStateSnapshot,
  WriteOptions,
  WriteResult
} from 'debug_core';
import { BluetoothConstants } from '../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';
import { SppRfcommClient } from '../platform/spp/SppRfcommClient';
import { SppRfcommConnectRequest } from '../platform/spp/SppPlatformGateway';
import { SppConnectParams } from '../../domain/model/SppConnectParams';
import { ReconnectPolicy } from '../../domain/model/ReconnectPolicy';
import { SppReadStrategy } from '../../domain/model/SppRuntimeState';
import { SppSessionKey } from '../../domain/model/SppSessionKey';
import { ISppTransportFacet } from '../../domain/model/spp/ISppTransportFacet';
import { SppReconnectCoordinator } from '../../domain/service/SppReconnectCoordinator';
import { SppSessionLedger } from '../../domain/service/spp/SppSessionLedger';
import { SppSessionTeardown } from '../../domain/service/spp/SppSessionTeardown';

/**
 * One debug session ↔ one HarmonyOS clientSocket (RFCOMM) — architecture 02 L3.
 * Uses SppRfcommClient only (SppSocketDataSource removed).
 * Byte counters owned by LogCaptureService / SendCommand (avoid double applyPatch here).
 * Reconnect owner = SppReconnectCoordinator (no Transport-only reconnect loop).
 */
export class SppTransportSession implements ITransportSession, ISppTransportFacet {
  readonly sppFacetBrand: 'spp' = 'spp';
  readonly id: string;
  readonly module: ModuleType = ModuleType.BLUETOOTH;
  readonly protocol: ProtocolType = ProtocolType.SPP;
  readonly capabilities: TransportCapabilities;
  private currentState: TransportState = TransportState.IDLE;
  private readonly incomingObservable: Observable<IncomingPayload>;
  private readonly stateObservable: Observable<TransportStateSnapshot>;
  private readonly rfcommClient: SppRfcommClient;
  private connectParams: SppConnectParams | undefined;
  private userDisconnect: boolean = false;

  constructor(sessionId: string, rfcommClient: SppRfcommClient = new SppRfcommClient()) {
    this.id = sessionId.length > 0 ? sessionId : IdGenerator.next('spp');
    this.rfcommClient = rfcommClient;
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
    this.rfcommClient.setIncomingListener((bytes: Uint8Array) => {
      this.onIncomingBytes(bytes);
    });
    this.rfcommClient.setLinkLostListener((reason: string) => {
      if (this.currentState === TransportState.CONNECTED && !this.userDisconnect) {
        void this.handleLinkLoss(reason);
      }
    });
  }

  get state(): TransportState {
    return this.currentState;
  }

  getSessionKey(): SppSessionKey | undefined {
    if (this.connectParams === undefined) {
      return undefined;
    }
    return SppSessionKey.fromParts(this.connectParams.classicDeviceId, this.connectParams.uuid);
  }

  getClientSocketId(): number {
    return this.rfcommClient.socketId;
  }

  getReadStrategy(): SppReadStrategy {
    return this.rfcommClient.activeReadStrategy;
  }

  cancelReconnect(): void {
    this.userDisconnect = true;
  }

  notifyFailed(reason: string): void {
    this.userDisconnect = true;
    this.transition(TransportState.FAILED, reason);
  }

  /**
   * Coordinator-bound action: reopen RFCOMM + promote ledger after link loss.
   */
  async reopenForReconnect(): Promise<void> {
    if (this.userDisconnect || this.connectParams === undefined) {
      throw new Error('SPP reconnect cancelled');
    }
    if (this.currentState === TransportState.CONNECTED && this.rfcommClient.isOpen()) {
      return;
    }
    this.transition(TransportState.CONNECTING, 'reconnecting');
    await this.openRfcomm();
    const key = this.getSessionKey();
    if (key !== undefined && this.rfcommClient.isOpen()) {
      SppSessionLedger.getInstance().promoteConnected(key, this.rfcommClient.socketId);
    }
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
    const stopOnPairLost = params['stopOnPairLost'] !== false && params['stopOnPairLost'] !== 0;
    const stopOnPermissionLost =
      params['stopOnPermissionLost'] !== false && params['stopOnPermissionLost'] !== 0;
    const policy = new ReconnectPolicy(
      Number(params['maxReconnectAttempts'] ?? 5),
      Number(params['reconnectInitialDelayMs'] ?? 1000),
      Number(params['reconnectMaxDelayMs'] ?? 15000),
      Number(params['reconnectBackoffFactor'] ?? 2),
      stopOnPermissionLost,
      stopOnPairLost
    );
    this.connectParams = new SppConnectParams(
      classicDeviceId,
      displayName,
      uuid,
      secure,
      Number(params['timeoutMs'] ?? BluetoothConstants.DEFAULT_SPP_CONNECT_TIMEOUT_MS),
      autoReconnect,
      policy
    );
    this.userDisconnect = false;
    await this.openRfcomm();
  }

  private async openRfcomm(): Promise<void> {
    if (this.connectParams === undefined) {
      throw new Error('SPP connect params missing');
    }
    this.transition(TransportState.CONNECTING);
    const params = this.connectParams;
    const opened = await this.rfcommClient.open(
      new SppRfcommConnectRequest(params.classicDeviceId, params.uuid, params.secure),
      params.timeoutMs
    );
    if (!opened.success) {
      this.transition(TransportState.FAILED, opened.error?.message ?? 'connect failed');
      throw new Error(opened.error?.message ?? 'SPP connect failed');
    }
    this.transition(TransportState.CONNECTED);
  }

  async disconnect(reason: string): Promise<void> {
    this.userDisconnect = true;
    this.transition(TransportState.DISCONNECTING, reason);
    await this.rfcommClient.close();
    this.transition(TransportState.DISCONNECTED, reason);
  }

  async write(payload: Uint8Array, _options?: WriteOptions): Promise<WriteResult> {
    if (this.currentState !== TransportState.CONNECTED || !this.rfcommClient.isOpen()) {
      return new WriteResult(false, 0, BluetoothErrorCodes.NOT_CONNECTED, 'SPP not connected');
    }
    const written = await this.rfcommClient.write(payload);
    if (!written.success) {
      // Fatal IO triggers link-lost callback → Coordinator reconnect or fail teardown
      return new WriteResult(
        false,
        0,
        written.error?.code ?? BluetoothErrorCodes.SPP_IO_ERROR,
        written.error?.message ?? 'write failed',
        written.error?.nativeCode ?? ''
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
    // Defensive: tear-down must free ledger even if Disconnect UC skipped (connect-fail path).
    this.releaseLedgerIfHeld('destroy');
    void this.rfcommClient.close();
    this.incomingObservable.clearObservers();
    this.stateObservable.clearObservers();
  }

  private onIncomingBytes(bytes: Uint8Array): void {
    if (bytes.length === 0) {
      return;
    }
    this.incomingObservable.next(new IncomingPayload(bytes, TimeUtil.nowMs(), false));
  }

  /**
   * Link loss → Coordinator.requestReconnect when autoReconnect, else full fail teardown.
   */
  private async handleLinkLoss(reason: string): Promise<void> {
    await this.rfcommClient.close();
    if (this.userDisconnect) {
      return;
    }
    if (this.connectParams === undefined || !this.connectParams.autoReconnect) {
      SppReconnectCoordinator.getInstance().unbind(this.id);
      await SppSessionTeardown.failCleanup(this.id, reason);
      return;
    }
    const key = this.getSessionKey();
    if (key !== undefined) {
      SppSessionLedger.getInstance().markReconnecting(key);
    }
    this.transition(TransportState.CONNECTING, `reconnecting:${reason}`);
    await SppReconnectCoordinator.getInstance().requestReconnect(this.id, reason);
  }

  private releaseLedgerIfHeld(reason: string): void {
    const key = this.getSessionKey();
    if (key === undefined) {
      return;
    }
    const ledger = SppSessionLedger.getInstance();
    if (ledger.hasKey(key)) {
      ledger.release(key, reason);
    }
  }

  private transition(state: TransportState, reason: string = ''): void {
    this.currentState = state;
    this.stateObservable.next(new TransportStateSnapshot(state, reason, TimeUtil.nowMs()));
  }
}
