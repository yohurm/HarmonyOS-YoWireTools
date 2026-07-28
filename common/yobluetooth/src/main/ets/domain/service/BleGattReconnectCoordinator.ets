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
    if (this.userDisconnect || this.pendingAction === undefined || this.bleDeviceId.length === 0) {
      return;
    }
    if (this.identityStability === IdentityStability.EPHEMERAL_RANDOM) {
      return;
    }
    const repository = BluetoothRepository.getInstance();
    const adapter = await repository.loadAdapterState();
    if (!adapter.success || adapter.value === undefined || !adapter.value.enabled) {
      return;
    }
    repository.stopBleScan();
    await this.pendingAction();
  }

  static canFastReconnect(stability: IdentityStability): boolean {
    return stability === IdentityStability.PAIRED_STABLE ||
      stability === IdentityStability.PERSISTENT_MAC ||
      stability === IdentityStability.CURRENT_SESSION;
  }
}
