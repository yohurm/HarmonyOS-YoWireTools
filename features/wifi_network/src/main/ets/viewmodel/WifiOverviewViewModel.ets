import { UiPageState } from 'common_ui';
import { DebugSessionSummary, ModuleType, SessionRuntimeStore } from 'feature_debug_core';
import { WifiNetworkRepository } from '../data/repository/WifiNetworkRepository';
import { LoadWifiOverviewUseCase } from '../domain/usecase/WifiNetworkUseCases';
import { PermissionState, WifiOverviewUiState } from '../domain/model/WifiOverviewUiState';

@ObservedV2
export class WifiOverviewViewModel {
  @Trace pageState: UiPageState = UiPageState.LOADING;
  @Trace uiState: WifiOverviewUiState | undefined;
  @Trace activeSessions: DebugSessionSummary[] = [];
  @Trace statusMessage: string = '';

  private readonly repository: WifiNetworkRepository = WifiNetworkRepository.getInstance();
  private readonly loadOverview: LoadWifiOverviewUseCase = new LoadWifiOverviewUseCase();

  async initialize(): Promise<void> {
    this.pageState = UiPageState.LOADING;
    this.repository.onWifiStateChange(() => {
      void this.refresh();
    });
    this.repository.onWifiConnectionChange(() => {
      void this.refresh();
    });
    await this.refresh();
    this.pageState = UiPageState.CONTENT;
  }

  dispose(): void {
    this.repository.offWifiStateChange();
    this.repository.offWifiConnectionChange();
  }

  async refresh(): Promise<void> {
    this.uiState = await this.loadOverview.execute();
    this.activeSessions = SessionRuntimeStore.getInstance().listActiveSummaries()
      .filter((item: DebugSessionSummary) => item.module === ModuleType.WIFI);
    if (this.uiState !== undefined && this.uiState.wifiInfoPermission === PermissionState.DENIED) {
      this.statusMessage = '请在系统设置中授予 GET_WIFI_INFO 权限';
    } else if (this.uiState !== undefined && this.uiState.overview.wifiActive === false) {
      this.statusMessage = 'WiFi 已关闭，网络工具仍可使用';
    } else {
      this.statusMessage = 'WiFi 就绪';
    }
  }
}
