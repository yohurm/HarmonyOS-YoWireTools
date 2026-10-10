import { LoadNearLinkModuleSettingsUseCase, SaveNearLinkRequireFilterUseCase } from 'debug_core';

@ObservedV2
export class NearLinkSettingsViewModel {
  @Trace requireFilter: boolean = true;
  @Trace unread: boolean = false;
  private readonly loadSettings: LoadNearLinkModuleSettingsUseCase;
  private readonly saveFilter: SaveNearLinkRequireFilterUseCase;

  constructor(
    loadSettings: LoadNearLinkModuleSettingsUseCase = new LoadNearLinkModuleSettingsUseCase(),
    saveFilter: SaveNearLinkRequireFilterUseCase = new SaveNearLinkRequireFilterUseCase()
  ) {
    this.loadSettings = loadSettings;
    this.saveFilter = saveFilter;
  }

  async refresh(): Promise<void> {
    const loaded = await this.loadSettings.execute();
    if (!loaded.success || loaded.value === undefined) {
      this.unread = true;
      return;
    }
    this.unread = false;
    this.requireFilter = loaded.value;
  }

  async toggle(): Promise<void> {
    const saved = await this.saveFilter.execute(!this.requireFilter);
    if (saved.success) {
      await this.refresh();
    } else {
      this.unread = true;
    }
  }
}
