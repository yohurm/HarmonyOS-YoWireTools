import { PreferencesStore } from 'common_storage';
import { UiPageState } from 'common_ui';

/**
 * Bluetooth module-level settings (encoding, scan, connection behavior).
 */
@ObservedV2
export class BluetoothModuleSettingsViewModel {
  @Trace pageState: UiPageState = UiPageState.LOADING;
  @Trace autoStopDiscovery: boolean = true;
  @Trace lineEnding: string = 'lf';
  @Trace statusMessage: string = '';

  private readonly preferences: PreferencesStore = PreferencesStore.getInstance();

  async initialize(): Promise<void> {
    this.pageState = UiPageState.LOADING;
    this.autoStopDiscovery = await this.preferences.isBluetoothAutoStopDiscoveryEnabled();
    this.lineEnding = await this.preferences.getCommandDefaultLineEnding();
    this.pageState = UiPageState.CONTENT;
    this.statusMessage = '蓝牙模块设置已加载';
  }

  async setAutoStopDiscovery(enabled: boolean): Promise<void> {
    this.autoStopDiscovery = enabled;
    const saved = await this.preferences.setBluetoothAutoStopDiscoveryEnabled(enabled);
    this.statusMessage = saved.success ?
      (enabled ? '连接前将自动停止扫描' : '连接前不再自动停止扫描') :
      (saved.error?.message ?? '保存失败');
  }

  async setLineEnding(mode: string): Promise<void> {
    this.lineEnding = mode;
    const saved = await this.preferences.setCommandDefaultLineEnding(mode);
    this.statusMessage = saved.success ?
      `默认行尾：${BluetoothModuleSettingsViewModel.lineEndingLabel(mode)}` :
      (saved.error?.message ?? '保存失败');
  }

  static lineEndingLabel(mode: string): string {
    if (mode === 'crlf') {
      return 'CRLF';
    }
    if (mode === 'none') {
      return '无';
    }
    return 'LF';
  }
}
