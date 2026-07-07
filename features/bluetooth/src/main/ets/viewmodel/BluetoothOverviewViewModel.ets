import { Result } from 'common_core';
import { DeviceFavoriteRecord } from 'common_storage';
import { UiPageState } from 'common_ui';
import { DebugSessionSummary, SessionRuntimeStore, ModuleType } from 'feature_debug_core';
import { BluetoothRepository } from '../data/repository/BluetoothRepository';
import { ResolveBluetoothCapabilityUseCase, SaveBluetoothFavoriteUseCase } from '../domain/usecase/BluetoothExtendedUseCases';
import { LoadBluetoothOverviewUseCase } from '../domain/usecase/BluetoothUseCases';
import { BluetoothOverviewSnapshot, BluetoothCapabilitySnapshot } from '../domain/model/BluetoothDevice';
import { BluetoothRecentConnection } from '../domain/model/BluetoothRecentConnection';
import { BluetoothOverviewUiState, PermissionState } from '../domain/model/BluetoothOverviewUiState';
import { PairingCoordinator } from '../domain/service/PairingCoordinator';
@ObservedV2
export class BluetoothOverviewViewModel {
  @Trace pageState: UiPageState = UiPageState.LOADING;
  @Trace overview: BluetoothOverviewSnapshot | undefined;
  @Trace uiState: BluetoothOverviewUiState | undefined;
  @Trace favorites: DeviceFavoriteRecord[] = [];
  @Trace recentConnections: BluetoothRecentConnection[] = [];
  @Trace activeSessions: DebugSessionSummary[] = [];
  @Trace permissionGranted: boolean = false;
  @Trace statusMessage: string = '';
  private readonly repository: BluetoothRepository = BluetoothRepository.getInstance();
  private readonly resolveCapability: ResolveBluetoothCapabilityUseCase = new ResolveBluetoothCapabilityUseCase();
  private readonly loadOverview: LoadBluetoothOverviewUseCase = new LoadBluetoothOverviewUseCase();
  private readonly saveFavorite: SaveBluetoothFavoriteUseCase = new SaveBluetoothFavoriteUseCase();
  async initialize(): Promise<void> {
    this.pageState = UiPageState.LOADING;
    PairingCoordinator.getInstance().ensureStarted();
    this.repository.onAdapterStateChange(() => {
      void this.refresh();
    });
    await this.refresh();
    this.pageState = UiPageState.CONTENT;
  }
  dispose(): void {
    this.repository.offAdapterStateChange();
  }
  async refresh(): Promise<void> {
    const capability: Result<BluetoothCapabilitySnapshot> =
      await this.resolveCapability.execute();
    this.permissionGranted = capability.success && capability.value?.permissionGranted === true;
    const overview = await this.repository.loadOverview(this.permissionGranted === true);
    if (overview !== undefined) {
      this.overview = overview;
    }
    await this.loadOverview.execute();
    this.favorites = this.saveFavorite.listFavorites();
    this.recentConnections = this.repository.listRecentConnections();
    this.activeSessions = SessionRuntimeStore.getInstance().listActiveSummaries()
      .filter((item: DebugSessionSummary) => item.module === ModuleType.BLUETOOTH);
    const permissionState = this.permissionGranted ? PermissionState.GRANTED : PermissionState.DENIED;
    if (this.overview !== undefined) {
      this.uiState = new BluetoothOverviewUiState(
        permissionState,
        this.overview.adapter,
        this.overview.classicSupported,
        this.overview.bleSupported,
        this.recentConnections,
        this.favorites,
        this.activeSessions,
        this.overview.warnings
      );
    }
    if (!this.permissionGranted) {
      this.statusMessage = '请在系统设置中授予蓝牙权限';
    } else if (this.overview !== undefined && !this.overview.adapter.enabled) {
      this.statusMessage = '请先开启蓝牙';
    } else {
      this.statusMessage = '蓝牙就绪';
    }
  }
}
