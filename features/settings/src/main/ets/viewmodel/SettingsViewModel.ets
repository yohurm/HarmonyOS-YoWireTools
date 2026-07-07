import {
  AbilityContextRegistry,
  AppLifecycleState,
  BackgroundPolicyAdvisor,
  BackgroundSessionAction,
  BusinessPermissionCatalog,
  BusinessPermissionGroup,
  LifecycleCoordinator,
  PermissionOrchestrator,
  PermissionStatus,
  PlatformBackgroundSessionKind,
  ThemeModeCoordinator
} from 'common_platform';
import { AppThemeMode, AppThemeModeUtil } from 'common_core';
import { AppSettingRepository, PreferenceKeys, PreferencesStore } from 'common_storage';
import { UiPageState } from 'common_ui';

const DEFAULT_LOG_RETENTION_DAYS: number = 30;

@ObservedV2
export class PermissionGroupItem {
  readonly group: BusinessPermissionGroup;
  readonly title: string;
  readonly reason: string;
  @Trace statusText: string = '';
  @Trace allGranted: boolean = false;
  @Trace showOpenSettings: boolean = false;

  constructor(group: BusinessPermissionGroup, title: string, reason: string) {
    this.group = group;
    this.title = title;
    this.reason = reason;
  }
}

/**
 * Settings ViewModel: background policy, log retention, permission status.
 */
@ObservedV2
export class SettingsViewModel {
  @Trace pageState: UiPageState = UiPageState.LOADING;
  @Trace backgroundConnectionEnabled: boolean = true;
  @Trace logRetentionDays: number = DEFAULT_LOG_RETENTION_DAYS;
  @Trace logRetentionDaysText: string = `${DEFAULT_LOG_RETENTION_DAYS}`;
  @Trace permissionGroups: PermissionGroupItem[] = [];
  @Trace lifecycleStateLine: string = '';
  @Trace backgroundPolicyHint: string = '';
  @Trace statusMessage: string = '';
  @Trace themeMode: AppThemeMode = AppThemeMode.SYSTEM;
  @Trace exportMaskAddress: boolean = false;
  @Trace exportMaskHeaders: boolean = true;

  private readonly settingsRepository: AppSettingRepository = AppSettingRepository.getInstance();
  private readonly preferencesStore: PreferencesStore = PreferencesStore.getInstance();
  private readonly lifecycleCoordinator: LifecycleCoordinator = LifecycleCoordinator.getInstance();
  private readonly permissionOrchestrator: PermissionOrchestrator = PermissionOrchestrator.getInstance();

  async initialize(): Promise<void> {
    this.pageState = UiPageState.LOADING;
    this.ensurePermissionGroups();
    await this.loadSettings();
    await this.refreshPermissionGroups();
    this.refreshLifecycleState();
    this.refreshBackgroundPolicyHint();
    this.pageState = UiPageState.CONTENT;
    this.statusMessage = '设置已加载';
  }

  async refresh(): Promise<void> {
    await this.loadSettings();
    await this.refreshPermissionGroups();
    this.refreshLifecycleState();
    this.refreshBackgroundPolicyHint();
    this.statusMessage = '设置已刷新';
  }

  async setThemeMode(mode: AppThemeMode): Promise<void> {
    if (mode === this.themeMode) {
      return;
    }
    this.themeMode = mode;
    const saved = await this.settingsRepository.put(PreferenceKeys.THEME_MODE, mode);
    if (!saved.success) {
      this.statusMessage = saved.error?.message ?? '保存外观设置失败';
      return;
    }
    const ctx = AbilityContextRegistry.getInstance().get();
    if (ctx !== undefined) {
      ThemeModeCoordinator.apply(ctx, mode);
    }
    this.statusMessage = `外观：${AppThemeModeUtil.label(mode)}`;
  }

  async setBackgroundConnectionEnabled(enabled: boolean): Promise<void> {
    this.backgroundConnectionEnabled = enabled;
    const saved = await this.settingsRepository.put(
      PreferenceKeys.BACKGROUND_ALLOW_CONNECTION,
      enabled ? 'true' : 'false'
    );
    if (!saved.success) {
      this.statusMessage = saved.error?.message ?? '保存后台连接设置失败';
      return;
    }
    this.lifecycleCoordinator.configureBackgroundSettings(
      enabled,
      this.lifecycleCoordinator.backgroundPeriodicEnabled
    );
    this.refreshBackgroundPolicyHint();
    this.statusMessage = enabled ? '已允许后台保持连接' : '已关闭后台连接';
  }

  async updateLogRetentionDays(text: string): Promise<void> {
    this.logRetentionDaysText = text;
    const parsed = SettingsViewModel.parseRetentionDays(text);
    if (parsed <= 0) {
      this.statusMessage = '日志保留天数须为正整数';
      return;
    }
    this.logRetentionDays = parsed;
    const saved = await this.settingsRepository.put(
      PreferenceKeys.LOG_RETENTION_DAYS,
      `${parsed}`
    );
    if (!saved.success) {
      this.statusMessage = saved.error?.message ?? '保存日志保留天数失败';
      return;
    }
    this.statusMessage = `日志保留 ${parsed} 天`;
  }

  async setExportMaskAddress(enabled: boolean): Promise<void> {
    this.exportMaskAddress = enabled;
    await this.preferencesStore.setExportMaskAddressEnabled(enabled);
    this.statusMessage = enabled ? '导出时将脱敏 MAC/IP 地址' : '导出时保留完整地址';
  }

  async setExportMaskHeaders(enabled: boolean): Promise<void> {
    this.exportMaskHeaders = enabled;
    await this.preferencesStore.setExportMaskHeadersEnabled(enabled);
    this.statusMessage = enabled ? '导出时将脱敏 HTTP Header' : '导出时保留完整 Header';
  }

  async requestGroupPermissions(group: BusinessPermissionGroup): Promise<void> {
    const permissions = BusinessPermissionCatalog.permissionsFor(group);
    const reason = BusinessPermissionCatalog.reasonFor(group);
    const presentation = BusinessPermissionCatalog.presentationFor(group);
    const decision = await this.permissionOrchestrator.ensurePermissions(permissions, reason, presentation);
    await this.refreshPermissionGroups();
    this.statusMessage = decision.granted ? `${presentation.title}：已授权` : `${presentation.title}：未完全授权`;
  }

  async openGroupSettings(group: BusinessPermissionGroup): Promise<void> {
    const permissions = BusinessPermissionCatalog.permissionsFor(group);
    const reason = BusinessPermissionCatalog.reasonFor(group);
    await this.permissionOrchestrator.requestFromUser(permissions, reason);
    await this.refreshPermissionGroups();
    this.statusMessage = '已打开系统权限设置';
  }

  private ensurePermissionGroups(): void {
    if (this.permissionGroups.length > 0) {
      return;
    }
    this.permissionGroups = [
      new PermissionGroupItem(
        BusinessPermissionGroup.BLUETOOTH_SCAN_CONNECT,
        '蓝牙扫描与连接',
        BusinessPermissionCatalog.reasonFor(BusinessPermissionGroup.BLUETOOTH_SCAN_CONNECT)
      ),
      new PermissionGroupItem(
        BusinessPermissionGroup.BLUETOOTH_PERSISTENT_MAC,
        '蓝牙地址持久化',
        BusinessPermissionCatalog.reasonFor(BusinessPermissionGroup.BLUETOOTH_PERSISTENT_MAC)
      ),
      new PermissionGroupItem(
        BusinessPermissionGroup.WIFI_INFO,
        'WiFi 信息',
        BusinessPermissionCatalog.reasonFor(BusinessPermissionGroup.WIFI_INFO)
      ),
      new PermissionGroupItem(
        BusinessPermissionGroup.WIFI_PEERS_MAC,
        'WiFi BSSID',
        BusinessPermissionCatalog.reasonFor(BusinessPermissionGroup.WIFI_PEERS_MAC)
      ),
      new PermissionGroupItem(
        BusinessPermissionGroup.WIFI_CONTROL,
        'WiFi 控制',
        BusinessPermissionCatalog.reasonFor(BusinessPermissionGroup.WIFI_CONTROL)
      ),
      new PermissionGroupItem(
        BusinessPermissionGroup.NETWORK_ACCESS,
        '网络访问',
        BusinessPermissionCatalog.reasonFor(BusinessPermissionGroup.NETWORK_ACCESS)
      ),
      new PermissionGroupItem(
        BusinessPermissionGroup.NETWORK_INFO,
        '网络状态',
        BusinessPermissionCatalog.reasonFor(BusinessPermissionGroup.NETWORK_INFO)
      ),
      new PermissionGroupItem(
        BusinessPermissionGroup.NEARLINK_ACCESS,
        '星闪访问',
        BusinessPermissionCatalog.reasonFor(BusinessPermissionGroup.NEARLINK_ACCESS)
      )
    ];
  }

  private async loadSettings(): Promise<void> {
    const background = await this.settingsRepository.get(PreferenceKeys.BACKGROUND_ALLOW_CONNECTION);
    if (background.success) {
      this.backgroundConnectionEnabled = background.value !== 'false';
    }

    const retention = await this.settingsRepository.get(PreferenceKeys.LOG_RETENTION_DAYS);
    if (retention.success && retention.value !== undefined) {
      const parsed = SettingsViewModel.parseRetentionDays(retention.value);
      if (parsed > 0) {
        this.logRetentionDays = parsed;
        this.logRetentionDaysText = `${parsed}`;
      }
    }

    const theme = await this.settingsRepository.get(PreferenceKeys.THEME_MODE);
    if (theme.success && theme.value !== undefined) {
      this.themeMode = AppThemeModeUtil.parse(theme.value);
    }

    this.exportMaskAddress = await this.preferencesStore.isExportMaskAddressEnabled();
    this.exportMaskHeaders = await this.preferencesStore.isExportMaskHeadersEnabled();

    this.lifecycleCoordinator.configureBackgroundSettings(
      this.backgroundConnectionEnabled,
      this.lifecycleCoordinator.backgroundPeriodicEnabled
    );
  }

  private async refreshPermissionGroups(): Promise<void> {
    for (let i = 0; i < this.permissionGroups.length; i++) {
      const item = this.permissionGroups[i];
      const permissions = BusinessPermissionCatalog.permissionsFor(item.group);
      let grantedCount = 0;
      let hasDeniedNoDialog = false;
      for (let j = 0; j < permissions.length; j++) {
        const status = await this.permissionOrchestrator.checkPermission(permissions[j]);
        if (status === PermissionStatus.GRANTED) {
          grantedCount = grantedCount + 1;
        }
        if (status === PermissionStatus.DENIED_NO_DIALOG) {
          hasDeniedNoDialog = true;
        }
      }
      item.allGranted = grantedCount === permissions.length && permissions.length > 0;
      item.showOpenSettings = hasDeniedNoDialog || (!item.allGranted && permissions.length > 0);
      item.statusText = item.allGranted ?
        '已授权' :
        `${grantedCount}/${permissions.length} 已授权`;
    }
  }

  private refreshLifecycleState(): void {
    const state = this.lifecycleCoordinator.state;
    this.lifecycleStateLine = state === AppLifecycleState.FOREGROUND ? '应用前台运行' : '应用处于后台';
  }

  private refreshBackgroundPolicyHint(): void {
    const action = BackgroundPolicyAdvisor.resolveAction(PlatformBackgroundSessionKind.CONNECTION);
    this.backgroundPolicyHint = SettingsViewModel.backgroundActionText(action);
  }

  private static backgroundActionText(action: BackgroundSessionAction): string {
    switch (action) {
      case BackgroundSessionAction.KEEP:
        return '后台策略：前台运行，保持连接';
      case BackgroundSessionAction.REQUEST_LONG_TASK:
        return '后台策略：允许后台连接，申请长时任务';
      case BackgroundSessionAction.PAUSE:
        return '后台策略：后台暂停连接';
      case BackgroundSessionAction.STOP:
        return '后台策略：后台停止连接';
      default:
        return '后台策略：按生命周期协调';
    }
  }

  private static parseRetentionDays(text: string): number {
    const trimmed = text.trim();
    if (trimmed.length === 0) {
      return 0;
    }
    const parsed = Number.parseInt(trimmed, 10);
    if (Number.isNaN(parsed)) {
      return 0;
    }
    return parsed;
  }
}
