import { LoadBluetoothModuleSettingsUseCase, SaveBluetoothAutoStopUseCase } from 'debug_core';

@ObservedV2
export class BluetoothSettingsViewModel {
  @Trace enabled: boolean = true;
  @Trace unread: boolean = false;
  private readonly loadSettings: LoadBluetoothModuleSettingsUseCase;
  private readonly saveAutoStop: SaveBluetoothAutoStopUseCase;

  constructor(
    loadSettings: LoadBluetoothModuleSettingsUseCase = new LoadBluetoothModuleSettingsUseCase(),
    saveAutoStop: SaveBluetoothAutoStopUseCase = new SaveBluetoothAutoStopUseCase()
  ) {
    this.loadSettings = loadSettings;
    this.saveAutoStop = saveAutoStop;
  }

  async refresh(): Promise<void> {
    const loaded = await this.loadSettings.execute();
    if (!loaded.success || loaded.value === undefined) {
      this.unread = true;
      return;
    }
    this.unread = false;
    this.enabled = loaded.value;
  }

  async toggle(): Promise<void> {
    const saved = await this.saveAutoStop.execute(!this.enabled);
    if (saved.success) {
      await this.refresh();
    } else {
      this.unread = true;
    }
  }
}
