import { Subscription } from 'common_core';
import { LifecycleCoordinator, PlatformEvent, PlatformEventType } from 'common_platform';
import { BluetoothAdapterSnapshot } from '../model/BluetoothDevice';
import { PairingState } from '../model/PairingState';
import { BluetoothRepository } from '../../data/repository/BluetoothRepository';
import { SppReconnectEventLogger } from './SppReconnectEventLogger';
type ReconnectAction = () => Promise<void>;

/**
 * Coordinates SPP reconnect triggers per architecture 02-§8.1.
 */

export class SppReconnectCoordinator {
  private static instance: SppReconnectCoordinator | undefined;
  private adapterSub: Subscription | undefined;
  private lifecycleUnsub: (() => void) | undefined;
  private pendingAction: ReconnectAction | undefined;
  private deviceId: string = '';
  private sessionId: string = '';
  private attempt: number = 0;
  static getInstance(): SppReconnectCoordinator {
    if (SppReconnectCoordinator.instance === undefined) {
      SppReconnectCoordinator.instance = new SppReconnectCoordinator();
    }
    return SppReconnectCoordinator.instance;
  }
  bind(deviceId: string, action: ReconnectAction, sessionId: string = ''): void {
    this.deviceId = deviceId;
    this.sessionId = sessionId;
    this.pendingAction = action;
    this.attempt = 0;
    const repository = BluetoothRepository.getInstance();
    this.adapterSub?.dispose();
    this.adapterSub = repository.observeAdapterState().subscribe((snapshot: BluetoothAdapterSnapshot) => {
      if (snapshot.enabled && this.pendingAction !== undefined) {
        void this.tryReconnect('adapter_on');
      }
    });
    this.lifecycleUnsub?.();
    this.lifecycleUnsub = LifecycleCoordinator.getInstance().addListener((event: PlatformEvent) => {
      if (event.type === PlatformEventType.APP_FOREGROUND || event.type === PlatformEventType.BLUETOOTH_SWITCH) {
        void this.tryReconnect('lifecycle');
      }
    });
  }
  unbind(): void {
    this.adapterSub?.dispose();
    this.adapterSub = undefined;
    this.lifecycleUnsub?.();
    this.lifecycleUnsub = undefined;
    this.pendingAction = undefined;
    this.deviceId = '';
    this.sessionId = '';
    this.attempt = 0;
  }
  async tryReconnect(reason: string = 'unexpected_disconnect'): Promise<void> {
    if (this.pendingAction === undefined || this.deviceId.length === 0) {
      return;
    }
    const repository = BluetoothRepository.getInstance();
    await repository.ensureClassicDiscoveryStopped();
    const pairState = await repository.getPairState(this.deviceId);
    if (pairState.success && pairState.value === PairingState.UNPAIRED) {
      return;
    }
    this.attempt += 1;
    const sid = this.sessionId.length > 0 ? this.sessionId : `spp-reconnect-${this.deviceId}`;
    await SppReconnectEventLogger.logReconnectAttempt(sid, this.attempt, reason);
    await this.pendingAction();
  }
}
