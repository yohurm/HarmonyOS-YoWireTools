import { common } from '@kit.AbilityKit';

/**
 * Opens system settings for NearLink actions the kit does not provide.
 * Opening settings is not an unpair success.
 */
export class NearLinkSettingsNavigator {
  static async openNearLinkSettings(context: common.UIAbilityContext): Promise<boolean> {
    try {
      await context.startAbility({
        bundleName: 'com.huawei.hmos.settings',
        abilityName: 'com.huawei.hmos.settings.MainAbility'
      });
      return true;
    } catch (_error) {
      return false;
    }
  }
}
