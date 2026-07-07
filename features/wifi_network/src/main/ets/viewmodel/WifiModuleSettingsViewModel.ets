import { PreferenceKeys, PreferencesStore } from 'common_storage';
import { UiPageState } from 'common_ui';

@ObservedV2
export class WifiModuleSettingsViewModel {
  @Trace pageState: UiPageState = UiPageState.LOADING;
  @Trace scanCooldownMs: number = 3000;
  @Trace scanCooldownText: string = '3000';
  @Trace statusMessage: string = '';

  private readonly preferences: PreferencesStore = PreferencesStore.getInstance();

  async initialize(): Promise<void> {
    this.pageState = UiPageState.LOADING;
    this.scanCooldownMs = await this.preferences.getNumber(PreferenceKeys.WIFI_SCAN_COOLDOWN_MS, 3000);
    this.scanCooldownText = `${this.scanCooldownMs}`;
    this.pageState = UiPageState.CONTENT;
    this.statusMessage = '网络模块设置已加载';
  }

  async updateScanCooldown(text: string): Promise<void> {
    this.scanCooldownText = text;
    const parsed = parseInt(text.trim(), 10);
    if (Number.isNaN(parsed) || parsed < 0) {
      this.statusMessage = '冷却时间须为非负整数（毫秒）';
      return;
    }
    this.scanCooldownMs = parsed;
    const saved = await this.preferences.setWifiScanCooldownMs(parsed);
    this.statusMessage = saved.success ?
      `扫描冷却 ${parsed} ms` :
      (saved.error?.message ?? '保存失败');
  }
}
