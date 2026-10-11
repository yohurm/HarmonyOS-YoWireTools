import {
  AbilityContextRegistry,
  BluetoothSettingsNavigator,
  LifecycleCoordinator,
  WifiSettingsNavigator
} from 'common_platform';

@ObservedV2
export class MoreHubViewModel {
  @Trace contextReady: boolean = false;

  private lifecycleUnsubscribe: (() => void) | undefined;

  onPageAppear(): void {
    this.refresh();
    this.lifecycleUnsubscribe = LifecycleCoordinator.getInstance().addReconcileCallback(async () => {
      this.refresh();
    });
  }

  onPageDisappear(): void {
    if (this.lifecycleUnsubscribe !== undefined) {
      this.lifecycleUnsubscribe();
      this.lifecycleUnsubscribe = undefined;
    }
  }

  refresh(): void {
    this.contextReady = AbilityContextRegistry.getInstance().get() !== undefined;
  }

  async openBluetoothSettings(): Promise<void> {
    const context = AbilityContextRegistry.getInstance().get();
    if (context === undefined) {
      this.contextReady = false;
      return;
    }
    await BluetoothSettingsNavigator.openBluetoothSettings(context);
  }

  async openWifiSettings(): Promise<void> {
    const context = AbilityContextRegistry.getInstance().get();
    if (context === undefined) {
      this.contextReady = false;
      return;
    }
    await WifiSettingsNavigator.openWifiSettings(context);
  }
}
