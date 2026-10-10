import { LifecycleCoordinator } from 'common_platform';
import { EnsurePermissionUseCase, PermissionScenario } from 'debug_core';
import {
  BleGattReconnectCoordinator,
  BluetoothRepository,
  SppReconnectCoordinator
} from 'yobluetooth';

@ObservedV2
export class BluetoothDiagnosticsViewModel {
  @Trace keepBackground: boolean = false;
  @Trace statusText: string = '';
  @Trace bleFailures: number = 0;
  @Trace sppFailures: number = 0;
  @Trace serviceStopped: boolean = false;

  private readonly ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase();

  refreshCounts(): void {
    this.bleFailures = BleGattReconnectCoordinator.getInstance().failCount();
    this.sppFailures = SppReconnectCoordinator.getInstance().failureCount();
    this.serviceStopped = BluetoothRepository.getInstance().isServiceStopped();
    const last = BleGattReconnectCoordinator.getInstance().lastFailureReason();
    if (last.length > 0) {
      this.statusText = last;
    }
  }

  stopReconnect(): void {
    BleGattReconnectCoordinator.getInstance().stopAutoReconnect();
    SppReconnectCoordinator.getInstance().stopAutoReconnect();
    this.refreshCounts();
  }

  async toggleBackground(): Promise<void> {
    if (this.keepBackground) {
      this.keepBackground = false;
      LifecycleCoordinator.getInstance().configureBackgroundSettings(false, false);
      return;
    }
    const granted = await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_BACKGROUND);
    if (!granted.granted) {
      this.statusText = 'KEEP_BACKGROUND_RUNNING';
      this.keepBackground = false;
      return;
    }
    this.keepBackground = true;
    LifecycleCoordinator.getInstance().configureBackgroundSettings(true, false);
  }
}
