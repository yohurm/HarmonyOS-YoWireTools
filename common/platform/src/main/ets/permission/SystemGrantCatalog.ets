import { PlatformPermission } from './PlatformPermission';

/**
 * Normal system-grant permissions. Declared in module.json5 they are granted
 * at install. They must not go through requestPermissionsFromUser.
 */
export class SystemGrantCatalog {
  static isSystemGrant(permission: PlatformPermission): boolean {
    return permission === 'ohos.permission.GET_WIFI_INFO' ||
      permission === 'ohos.permission.SET_WIFI_INFO' ||
      permission === 'ohos.permission.GET_NETWORK_INFO' ||
      permission === 'ohos.permission.INTERNET';
  }
}
