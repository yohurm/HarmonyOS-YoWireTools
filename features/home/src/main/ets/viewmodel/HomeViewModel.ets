import { Subscription } from 'common_core';
import { AppPermission, CapabilityRegistry, CapabilityResult, PermissionOrchestrator, PermissionStatus } from 'common_platform';
import { SessionQuery, SessionRecord, SessionRepository } from 'common_storage';
import {
  DebugSessionSummary,
  LoadSessionLogPreviewUseCase,
  LoadWorkbenchOverviewUseCase,
  RepeatCommandCoordinator,
  SessionRuntimeStore,
  WorkbenchLogLine
} from 'feature_debug_core';
import { UiPageState } from 'common_ui';

/**
 * Home workbench ViewModel: active sessions, permission summary, log preview.
 */
@ObservedV2
export class HomeViewModel {
  @Trace pageState: UiPageState = UiPageState.LOADING;
  @Trace activeSessions: DebugSessionSummary[] = [];
  @Trace recentSessions: SessionRecord[] = [];
  @Trace selectedSessionId: string = '';
  @Trace logPreviewLines: WorkbenchLogLine[] = [];
  @Trace permissionLines: string[] = [];
  @Trace capabilityResults: CapabilityResult[] = [];
  @Trace statusMessage: string = '';
  @Trace repeatSendRunning: boolean = false;
  @Trace repeatSendCount: number = 0;

  private readonly loadOverview: LoadWorkbenchOverviewUseCase = new LoadWorkbenchOverviewUseCase();
  private readonly loadLogPreview: LoadSessionLogPreviewUseCase = new LoadSessionLogPreviewUseCase();
  private readonly sessionRepository: SessionRepository = SessionRepository.getInstance();
  private readonly runtimeStore: SessionRuntimeStore = SessionRuntimeStore.getInstance();
  private readonly repeatCoordinator: RepeatCommandCoordinator = RepeatCommandCoordinator.getInstance();
  private activeSubscription: Subscription | undefined;
  private sessionSubscription: Subscription | undefined;
  private repeatPollTimerId: number = -1;

  async initialize(): Promise<void> {
    this.pageState = UiPageState.LOADING;
    await this.refresh();
    this.bindActiveObservation();
    this.startRepeatPolling();
    this.pageState = UiPageState.CONTENT;
  }

  dispose(): void {
    this.stopRepeatPolling();
    if (this.activeSubscription !== undefined) {
      this.activeSubscription.dispose();
      this.activeSubscription = undefined;
    }
    if (this.sessionSubscription !== undefined) {
      this.sessionSubscription.dispose();
      this.sessionSubscription = undefined;
    }
  }

  async refresh(): Promise<void> {
    await this.refreshPermissions();
    await this.refreshCapabilities();
    await this.loadRecentSessions();
    const overview = this.loadOverview.execute();
    if (overview.success && overview.value !== undefined) {
      this.activeSessions = overview.value;
      if (this.selectedSessionId.length === 0 && this.activeSessions.length > 0) {
        this.selectedSessionId = this.activeSessions[0].id;
        this.bindSessionObservation();
      } else if (this.selectedSessionId.length > 0 &&
        !HomeViewModel.containsSession(this.activeSessions, this.selectedSessionId)) {
        this.selectedSessionId = this.activeSessions.length > 0 ? this.activeSessions[0].id : '';
        this.bindSessionObservation();
      }
    }
    await this.refreshLogPreview();
    this.statusMessage =
      `${this.activeSessions.length} 个活跃 · ${this.recentSessions.length} 条最近会话`;
  }

  async selectSession(sessionId: string): Promise<void> {
    this.selectedSessionId = sessionId;
    this.bindSessionObservation();
    await this.refreshLogPreview();
  }

  stopAllRepeatSend(): void {
    this.repeatCoordinator.stopAll();
    this.updateRepeatStatus();
    this.statusMessage = '已停止全部周期发送';
  }

  recentSessionLabel(session: SessionRecord): string {
    const name = session.displayName.length > 0 ? session.displayName : session.id;
    return `${session.module}/${session.protocol}: ${name}`;
  }

  capabilityChipLabel(result: CapabilityResult): string {
    const segments = result.capabilityId.split('.');
    return segments.length > 0 ? segments[segments.length - 1] : result.capabilityId;
  }

  private async refreshCapabilities(): Promise<void> {
    this.capabilityResults = await CapabilityRegistry.getInstance().list();
  }

  private async loadRecentSessions(): Promise<void> {
    const query = new SessionQuery('', '', 0, 10);
    const listed = await this.sessionRepository.list(query);
    if (!listed.success || listed.value === undefined) {
      this.recentSessions = [];
      return;
    }
    this.recentSessions = listed.value.items;
  }

  private async refreshPermissions(): Promise<void> {
    const orchestrator = PermissionOrchestrator.getInstance();
    const bluetooth = await orchestrator.checkPermission(AppPermission.ACCESS_BLUETOOTH);
    const internet = await orchestrator.checkPermission(AppPermission.INTERNET);
    const networkInfo = await orchestrator.checkPermission(AppPermission.GET_NETWORK_INFO);
    const wifi = await orchestrator.checkPermission(AppPermission.GET_WIFI_INFO);
    const nearlink = await orchestrator.checkPermission(AppPermission.ACCESS_NEARLINK);
    this.permissionLines = [
      HomeViewModel.formatPermission('蓝牙', bluetooth),
      HomeViewModel.formatPermission('网络访问', internet),
      HomeViewModel.formatPermission('网络状态', networkInfo),
      HomeViewModel.formatPermission('WiFi 信息', wifi),
      HomeViewModel.formatPermission('星闪', nearlink)
    ];
  }

  private async refreshLogPreview(): Promise<void> {
    if (this.selectedSessionId.length === 0) {
      this.logPreviewLines = [];
      return;
    }
    const preview = await this.loadLogPreview.execute(this.selectedSessionId, 30);
    if (!preview.success || preview.value === undefined) {
      this.statusMessage = preview.error?.message ?? '加载日志预览失败';
      this.logPreviewLines = [];
      return;
    }
    this.logPreviewLines = preview.value;
  }

  private bindActiveObservation(): void {
    if (this.activeSubscription !== undefined) {
      this.activeSubscription.dispose();
    }
    this.activeSubscription = this.runtimeStore.subscribeActiveSessions((summaries: DebugSessionSummary[]) => {
      this.activeSessions = summaries;
      if (this.selectedSessionId.length === 0 && summaries.length > 0) {
        this.selectedSessionId = summaries[0].id;
        this.bindSessionObservation();
      }
      void this.refreshLogPreview();
    });
  }

  private bindSessionObservation(): void {
    if (this.sessionSubscription !== undefined) {
      this.sessionSubscription.dispose();
      this.sessionSubscription = undefined;
    }
    if (this.selectedSessionId.length === 0) {
      return;
    }
    try {
      this.sessionSubscription = this.runtimeStore.subscribeSession(this.selectedSessionId, () => {
        void this.refreshLogPreview();
      });
    } catch (_error) {
      // Session may not be registered yet.
    }
  }

  private static containsSession(sessions: DebugSessionSummary[], sessionId: string): boolean {
    for (let i = 0; i < sessions.length; i++) {
      if (sessions[i].id === sessionId) {
        return true;
      }
    }
    return false;
  }

  private static formatPermission(label: string, status: PermissionStatus): string {
    return `${label}：${HomeViewModel.permissionStatusText(status)}`;
  }

  private static permissionStatusText(status: PermissionStatus): string {
    switch (status) {
      case PermissionStatus.GRANTED:
        return '已授权';
      case PermissionStatus.DENIED:
        return '已拒绝';
      case PermissionStatus.DENIED_NO_DIALOG:
        return '需在设置中授权';
      case PermissionStatus.NOT_REQUESTED:
        return '未请求';
      default:
        return status;
    }
  }

  private startRepeatPolling(): void {
    this.updateRepeatStatus();
    if (this.repeatPollTimerId >= 0) {
      return;
    }
    this.repeatPollTimerId = setInterval(() => {
      this.updateRepeatStatus();
    }, 800);
  }

  private stopRepeatPolling(): void {
    if (this.repeatPollTimerId >= 0) {
      clearInterval(this.repeatPollTimerId);
      this.repeatPollTimerId = -1;
    }
  }

  private updateRepeatStatus(): void {
    this.repeatSendRunning = this.repeatCoordinator.hasAnyRunning();
    this.repeatSendCount = this.repeatCoordinator.runningCount();
  }
}
