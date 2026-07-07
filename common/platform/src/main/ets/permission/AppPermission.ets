import { PlatformPermission } from './PlatformPermission';

/**
 * Permission constants aligned with architecture §7.2 and PRD-06 matrix.
 */
export class AppPermission {
  static readonly ACCESS_BLUETOOTH: PlatformPermission = 'ohos.permission.ACCESS_BLUETOOTH';
  static readonly PERSISTENT_BLUETOOTH_PEERS_MAC: PlatformPermission =
    'ohos.permission.PERSISTENT_BLUETOOTH_PEERS_MAC';
  static readonly GET_WIFI_INFO: PlatformPermission = 'ohos.permission.GET_WIFI_INFO';
  static readonly GET_WIFI_PEERS_MAC: PlatformPermission = 'ohos.permission.GET_WIFI_PEERS_MAC';
  static readonly SET_WIFI_INFO: PlatformPermission = 'ohos.permission.SET_WIFI_INFO';
  static readonly INTERNET: PlatformPermission = 'ohos.permission.INTERNET';
  static readonly GET_NETWORK_INFO: PlatformPermission = 'ohos.permission.GET_NETWORK_INFO';
  static readonly ACCESS_NEARLINK: PlatformPermission = 'ohos.permission.ACCESS_NEARLINK';
}
