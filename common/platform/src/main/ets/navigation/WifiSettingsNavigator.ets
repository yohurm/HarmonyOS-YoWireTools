import { common } from '@kit.AbilityKit';

/**
 * System settings entry per architecture 03-§4.1 and wifi_network/01-§7.
 */
export class WifiSettingsNavigator {
  static async openAppPermissionSettings(context: common.UIAbilityContext): Promise<void> {
    try {
      await context.startAbility({
        bundleName: 'com.huawei.hmos.settings',
        abilityName: 'com.huawei.hmos.settings.MainAbility',
        uri: 'application_info_entry',
        parameters: { pushParams: context.applicationInfo.name }
      });
    } catch (_error) {
    }
  }

  static async openWifiSettings(context: common.UIAbilityContext): Promise<void> {
    try {
      await context.startAbility({ action: 'ohos.settings.manageWiFi' });
    } catch (_error) {
      try {
        await context.startAbility({
          bundleName: 'com.huawei.hmos.settings',
          abilityName: 'com.huawei.hmos.settings.MainAbility'
        });
      } catch (_inner) {
      }
    }
  }
}
