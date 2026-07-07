import { common } from '@kit.AbilityKit';
import { BusinessError } from '@kit.BasicServicesKit';

/**
 * Opens system settings for permission/bluetooth per architecture 02-§4.1 item 7.
 */
export class BluetoothSettingsNavigator {
  static async openBluetoothSettings(context: common.UIAbilityContext): Promise<boolean> {
    try {
      await context.startAbility({
        action: 'ohos.settings.manageBluetooth'
      });
      return true;
    } catch (error) {
      const err = error as BusinessError;
      return BluetoothSettingsNavigator.openSettingsHome(context, err.message);
    }
  }

  static async openAppPermissionSettings(context: common.UIAbilityContext): Promise<boolean> {
    try {
      await context.startAbility({
        bundleName: 'com.huawei.hmos.settings',
        abilityName: 'com.huawei.hmos.settings.MainAbility',
        uri: 'application_info_entry',
        parameters: {
          pushParams: context.applicationInfo.name
        }
      });
      return true;
    } catch (error) {
      const err = error as BusinessError;
      return BluetoothSettingsNavigator.openSettingsHome(context, err.message);
    }
  }

  private static async openSettingsHome(context: common.UIAbilityContext, _reason: string): Promise<boolean> {
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
