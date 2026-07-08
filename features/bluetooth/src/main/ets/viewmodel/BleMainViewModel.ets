import { LoadBluetoothOverviewSnapshotUseCase } from '../domain/usecase/overview/OverviewUseCases';

@ObservedV2
export class BleMainViewModel {
  @Trace isLoading: boolean = true;
  @Trace ready: boolean = false;
  @Trace discoveredDeviceCount: number = 0;
  @Trace activeSessionCount: number = 0;

  private readonly loadOverview: LoadBluetoothOverviewSnapshotUseCase;

  constructor(loadOverview: LoadBluetoothOverviewSnapshotUseCase = new LoadBluetoothOverviewSnapshotUseCase()) {
    this.loadOverview = loadOverview;
  }

  async onPageAppear(): Promise<void> {
    await this.refresh();
  }

  async refresh(): Promise<void> {
    this.isLoading = true;
    const result = await this.loadOverview.execute();
    if (result.success && result.value !== undefined) {
      const snapshot = result.value;
      this.ready = snapshot.permissionGranted && snapshot.adapter.enabled && snapshot.bleSupported;
      this.discoveredDeviceCount = snapshot.bleDeviceCount;
      this.activeSessionCount = snapshot.activeSessionCount;
    }
    this.isLoading = false;
  }
}
