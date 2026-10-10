import { LoadWifiModuleSettingsUseCase, SaveWifiScanCooldownUseCase } from 'debug_core';

@ObservedV2
export class WifiSettingsViewModel {
  @Trace cooldownMs: number = 3000;
  @Trace unread: boolean = false;
  private readonly loadSettings: LoadWifiModuleSettingsUseCase;
  private readonly saveCooldown: SaveWifiScanCooldownUseCase;

  constructor(
    loadSettings: LoadWifiModuleSettingsUseCase = new LoadWifiModuleSettingsUseCase(),
    saveCooldown: SaveWifiScanCooldownUseCase = new SaveWifiScanCooldownUseCase()
  ) {
    this.loadSettings = loadSettings;
    this.saveCooldown = saveCooldown;
  }

  async refresh(): Promise<void> {
    const loaded = await this.loadSettings.execute();
    if (!loaded.success || loaded.value === undefined) {
      this.unread = true;
      return;
    }
    this.unread = false;
    this.cooldownMs = loaded.value;
  }

  async cycle(): Promise<void> {
    const next = this.cooldownMs === 3000 ? 5000 : (this.cooldownMs === 5000 ? 10000 : 3000);
    const saved = await this.saveCooldown.execute(next);
    if (saved.success) {
      await this.refresh();
    } else {
      this.unread = true;
    }
  }
}
