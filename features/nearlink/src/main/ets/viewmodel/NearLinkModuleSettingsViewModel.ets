import { PreferencesStore } from 'common_storage';
import { UiPageState } from 'common_ui';

@ObservedV2
export class NearLinkModuleSettingsViewModel {
  @Trace pageState: UiPageState = UiPageState.LOADING;
  @Trace requireScanFilter: boolean = true;
  @Trace statusMessage: string = '';

  private readonly preferences: PreferencesStore = PreferencesStore.getInstance();

  async initialize(): Promise<void> {
    this.pageState = UiPageState.LOADING;
    this.requireScanFilter = await this.preferences.isNearlinkRequireFilterEnabled();
    this.pageState = UiPageState.CONTENT;
    this.statusMessage = '星闪模块设置已加载';
  }

  async setRequireScanFilter(enabled: boolean): Promise<void> {
    this.requireScanFilter = enabled;
    const saved = await this.preferences.setNearlinkRequireFilterEnabled(enabled);
    this.statusMessage = saved.success ?
      (enabled ? '扫描必须配置过滤条件' : '允许无过滤扫描（可能受限）') :
      (saved.error?.message ?? '保存失败');
  }
}
