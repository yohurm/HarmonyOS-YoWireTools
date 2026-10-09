import { LifecycleCoordinator, PlatformEvent, PlatformEventType } from 'common_platform';
import { IdentityStability } from '../model/DeviceIdentity';
import { BluetoothRepository } from '../../data/repository/BluetoothRepository';

type GattReconnectAction = () => Promise<void>;

/**
 * BLE GATT auto-reconnect per architecture 02-§8.2.
 * Always binds bleDeviceId (never classic-only address).
 */
export class BleGattReconnectCoordinator {
  private static instance: BleGattReconnectCoordinator | undefined;
  private lifecycleUnsub: (() => void) | undefined;
  private pendingAction: GattReconnectAction | undefined;
  private bleDeviceId: string = '';
  private identityStability: IdentityStability = IdentityStability.UNKNOWN;
  private userDisconnect: boolean = false;
  private failCountValue: number = 0;
  private lastFailure: string = '';
  private autoReconnectStopped: boolean = false;

  static getInstance(): BleGattReconnectCoordinator {
    if (BleGattReconnectCoordinator.instance === undefined) {
      BleGattReconnectCoordinator.instance = new BleGattReconnectCoordinator();
    }
    return BleGattReconnectCoordinator.instance;
  }

  bind(
    bleDeviceId: string,
    identityStability: IdentityStability,
    action: GattReconnectAction
  ): void {
    this.bleDeviceId = bleDeviceId;
    this.identityStability = identityStability;
    this.pendingAction = action;
    this.userDisconnect = false;
    this.autoReconnectStopped = false;
    this.lifecycleUnsub?.();
    this.lifecycleUnsub = LifecycleCoordinator.getInstance().addListener((event: PlatformEvent) => {
      if (event.type === PlatformEventType.APP_FOREGROUND || event.type === PlatformEventType.BLUETOOTH_SWITCH) {
        void this.tryReconnect();
      }
    });
  }

  markUserDisconnect(): void {
    this.userDisconnect = true;
    this.unbind();
  }

  failCount(): number {
    return this.failCountValue;
  }

  lastFailureReason(): string {
    return this.lastFailure;
  }

  stopAutoReconnect(): void {
    this.autoReconnectStopped = true;
    this.userDisconnect = true;
    this.pendingAction = undefined;
  }

  unbind(): void {
    this.lifecycleUnsub?.();
    this.lifecycleUnsub = undefined;
    this.pendingAction = undefined;
    this.bleDeviceId = '';
  }

  async onUnexpectedDisconnect(): Promise<void> {
    if (this.userDisconnect) {
      return;
    }
    await this.tryReconnect();
  }

  async tryReconnect(): Promise<void> {
    if (this.userDisconnect || this.autoReconnectStopped ||
      this.pendingAction === undefined || this.bleDeviceId.length === 0) {
      return;
    }
    if (this.identityStability === IdentityStability.EPHEMERAL_RANDOM ||
      this.identityStability === IdentityStability.PERSISTENT_MAC ||
      this.identityStability === IdentityStability.UNKNOWN) {
      this.lastFailure = 'identity not reusable';
      return;
    }
    const repository = BluetoothRepository.getInstance();
    const adapter = await repository.loadAdapterState();
    if (!adapter.success || adapter.value === undefined || !adapter.value.enabled) {
      return;
    }
    repository.stopBleScan();
    try {
      await this.pendingAction();
    } catch (error) {
      this.failCountValue = this.failCountValue + 1;
      this.lastFailure = error instanceof Error ? error.message : 'reconnect failed';
    }
  }

  static canFastReconnect(stability: IdentityStability): boolean {
    return stability === IdentityStability.PAIRED_STABLE ||
      stability === IdentityStability.CURRENT_SESSION;
  }
}
