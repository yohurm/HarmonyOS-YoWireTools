import { Result } from 'common_core';
import { DeviceFavoriteRecord } from 'common_storage';
import { UiPageState } from 'common_ui';
import { CapabilityResult } from 'common_platform';
import { DebugSessionSummary, SessionRuntimeStore, ModuleType } from 'feature_debug_core';
import { NearLinkRepository } from '../data/repository/NearLinkRepository';
import { ResolveNearLinkCapabilityUseCase, LoadNearLinkOverviewUseCase } from '../domain/usecase/NearLinkUseCases';
import { SaveNearLinkFavoriteUseCase } from '../domain/usecase/NearLinkExtendedUseCases';
import { NearLinkCapabilityService } from '../domain/service/NearLinkCapabilityService';
import {
  NearLinkOverviewSnapshot,
  NearLinkCapabilitySnapshot,
  NearLinkDevice
} from '../domain/model/NearLinkDevice';
import { NearLinkRecentConnection } from '../domain/model/NearLinkRecentConnection';
import { NearLinkOverviewUiState, PermissionState } from '../domain/model/NearLinkOverviewUiState';

@ObservedV2
export class NearLinkOverviewViewModel {
  @Trace pageState: UiPageState = UiPageState.LOADING;
  @Trace overview: NearLinkOverviewSnapshot | undefined;
  @Trace capability: NearLinkCapabilitySnapshot | undefined;
  @Trace capabilityResults: CapabilityResult[] = [];
  @Trace uiState: NearLinkOverviewUiState | undefined;
  @Trace favorites: DeviceFavoriteRecord[] = [];
  @Trace recentConnections: NearLinkRecentConnection[] = [];
  @Trace recentDevices: NearLinkDevice[] = [];
  @Trace activeSessions: DebugSessionSummary[] = [];
  @Trace permissionGranted: boolean = false;
  @Trace statusMessage: string = '';

  private readonly repository: NearLinkRepository = NearLinkRepository.getInstance();
  private readonly resolveCapability: ResolveNearLinkCapabilityUseCase = new ResolveNearLinkCapabilityUseCase();
  private readonly loadOverview: LoadNearLinkOverviewUseCase = new LoadNearLinkOverviewUseCase();
  private readonly saveFavorite: SaveNearLinkFavoriteUseCase = new SaveNearLinkFavoriteUseCase();

  async initialize(): Promise<void> {
    this.pageState = UiPageState.LOADING;
    NearLinkCapabilityService.ensureRegistered();
    this.repository.onAdapterStateChange(() => {
      void this.refresh();
    });
    await this.refresh();
    this.pageState = UiPageState.CONTENT;
  }

  dispose(): void {
    this.repository.offAdapterStateChange();
  }

  canOpenScan(): boolean {
    return this.capability?.readyForScan === true;
  }

  async refresh(): Promise<void> {
    this.capabilityResults = await NearLinkCapabilityService.probeAll();
    const capability: Result<NearLinkCapabilitySnapshot> = await this.resolveCapability.execute();
    if (capability.success && capability.value !== undefined) {
      this.capability = capability.value;
      this.permissionGranted = capability.value.permissionGranted;
    }
    this.overview = await this.repository.loadOverview(this.permissionGranted === true);
    await this.loadOverview.execute();
    this.favorites = this.saveFavorite.listFavorites();
    this.recentConnections = this.repository.listRecentConnections();
    this.recentDevices = this.repository.listDevices().slice(0, 8);
    this.activeSessions = SessionRuntimeStore.getInstance().listActiveSummaries()
      .filter((item: DebugSessionSummary) => item.module === ModuleType.NEARLINK);
    const permissionState = this.permissionGranted ? PermissionState.GRANTED : PermissionState.DENIED;
    if (this.overview !== undefined) {
      this.uiState = new NearLinkOverviewUiState(
        permissionState,
        this.overview.adapter,
        this.recentConnections,
        this.favorites,
        this.activeSessions,
        this.overview.warnings
      );
    }
    if (!this.permissionGranted) {
      this.statusMessage = '请在系统设置中授予 ACCESS_NEARLINK 权限';
    } else if (this.capability !== undefined && !this.capability.supported) {
      this.statusMessage = '当前设备不支持星闪';
    } else if (this.capability !== undefined && !this.capability.switchOn) {
      this.statusMessage = '请在系统设置中开启星闪开关';
    } else if (this.capability?.readyForScan === true) {
      this.statusMessage = '星闪就绪';
    } else {
      this.statusMessage = '星闪能力受限，请查看警告信息';
    }
  }
}
