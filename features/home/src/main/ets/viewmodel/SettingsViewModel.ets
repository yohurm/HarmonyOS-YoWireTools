import { AppMode } from 'debug_core';
import {
  ClearLocalDataUseCase,
  LoadSettingsUseCase,
  SettingsSnapshot,
  UpdateSettingUseCase
} from 'debug_core';

@ObservedV2
export class SettingsViewModel {
  @Trace snapshot: SettingsSnapshot | undefined = undefined;
  @Trace unread: boolean = false;
  @Trace confirmingClear: boolean = false;
  @Trace cleared: boolean = false;
  private readonly loadSettings: LoadSettingsUseCase;
  private readonly updateSetting: UpdateSettingUseCase;
  private readonly clearData: ClearLocalDataUseCase;

  constructor(
    loadSettings: LoadSettingsUseCase = new LoadSettingsUseCase(),
    updateSetting: UpdateSettingUseCase = new UpdateSettingUseCase(),
    clearData: ClearLocalDataUseCase = new ClearLocalDataUseCase()
  ) {
    this.loadSettings = loadSettings;
    this.updateSetting = updateSetting;
    this.clearData = clearData;
  }

  async refresh(): Promise<void> {
    const loaded = await this.loadSettings.execute();
    if (!loaded.success || loaded.value === undefined) {
      this.unread = true;
      this.snapshot = undefined;
      return;
    }
    this.unread = false;
    this.snapshot = loaded.value;
  }

  async cycleTheme(): Promise<void> {
    const current = this.snapshot !== undefined ? this.snapshot.themeMode : 'system';
    const next = current === 'system' ? 'light' : (current === 'light' ? 'dark' : 'system');
    await this.updateSetting.saveTheme(next);
    await this.refresh();
  }

  async cycleMode(): Promise<void> {
    const current = this.snapshot !== undefined ? this.snapshot.appMode : AppMode.EXPERT;
    const next = current === AppMode.LIGHT ? AppMode.EXPERT : AppMode.LIGHT;
    await this.updateSetting.saveAppMode(next);
    await this.refresh();
  }

  async cycleRetention(): Promise<void> {
    const current = this.snapshot !== undefined ? this.snapshot.logRetentionDays : 30;
    const next = current === 7 ? 30 : (current === 30 ? 90 : 7);
    await this.updateSetting.saveLogRetentionDays(next);
    await this.refresh();
  }

  async cycleDisplay(): Promise<void> {
    const current = this.snapshot !== undefined ? this.snapshot.logDefaultDisplay : 'mixed';
    const next = current === 'text' ? 'hex' : (current === 'hex' ? 'mixed' : 'text');
    await this.updateSetting.saveLogDisplay(next);
    await this.refresh();
  }

  async toggleBackgroundConnection(): Promise<void> {
    const current = this.snapshot !== undefined ? this.snapshot.allowBackgroundConnection : true;
    await this.updateSetting.saveBackgroundConnection(!current);
    await this.refresh();
  }

  async toggleRepeat(): Promise<void> {
    const current = this.snapshot !== undefined ? this.snapshot.allowRepeatCommand : false;
    await this.updateSetting.saveRepeatAllowed(!current);
    await this.refresh();
  }

  async cycleLineEnding(): Promise<void> {
    const current = this.snapshot !== undefined ? this.snapshot.commandLineEnding : 'lf';
    const next = current === 'lf' ? 'cr' : (current === 'cr' ? 'crlf' : (current === 'crlf' ? 'none' : 'lf'));
    await this.updateSetting.saveLineEnding(next);
    await this.refresh();
  }

  async toggleBluetooth(): Promise<void> {
    const current = this.snapshot !== undefined ? this.snapshot.bluetoothAutoStopDiscovery : true;
    await this.updateSetting.saveBluetoothAutoStop(!current);
    await this.refresh();
  }

  async cycleCooldown(): Promise<void> {
    const current = this.snapshot !== undefined ? this.snapshot.wifiScanCooldownMs : 3000;
    const next = current === 3000 ? 5000 : (current === 5000 ? 10000 : 3000);
    await this.updateSetting.saveWifiScanCooldown(next);
    await this.refresh();
  }

  async toggleNearLink(): Promise<void> {
    const current = this.snapshot !== undefined ? this.snapshot.nearlinkRequireFilter : true;
    await this.updateSetting.saveNearLinkRequireFilter(!current);
    await this.refresh();
  }

  async toggleMaskAddress(): Promise<void> {
    const current = this.snapshot !== undefined ? this.snapshot.maskAddress : false;
    await this.updateSetting.saveMaskAddress(!current);
    await this.refresh();
  }

  async toggleMaskHeaders(): Promise<void> {
    const current = this.snapshot !== undefined ? this.snapshot.maskHeaders : true;
    await this.updateSetting.saveMaskHeaders(!current);
    await this.refresh();
  }

  askClear(): void {
    this.confirmingClear = true;
    this.cleared = false;
  }

  cancelClear(): void {
    this.confirmingClear = false;
  }

  async confirmClear(): Promise<void> {
    this.confirmingClear = false;
    const cleared = await this.clearData.execute();
    this.cleared = cleared.success;
    this.unread = !cleared.success;
  }
}
