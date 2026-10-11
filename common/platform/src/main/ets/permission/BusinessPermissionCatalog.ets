import { AppPermission } from './AppPermission';
import { PermissionPresentation } from './PermissionPresentation';
import { PlatformPermission } from './PlatformPermission';

/**
 * Business permission groups for feature modules — maps capability to platform permissions and copy.
 */
export enum BusinessPermissionGroup {
  BLUETOOTH_SCAN_CONNECT = 'bluetooth_scan_connect',
  BLUETOOTH_PERSISTENT_MAC = 'bluetooth_persistent_mac',
  BLUETOOTH_BACKGROUND = 'bluetooth_background',
  WIFI_INFO = 'wifi_info',
  WIFI_PEERS_MAC = 'wifi_peers_mac',
  WIFI_CONTROL = 'wifi_control',
  NETWORK_ACCESS = 'network_access',
  NETWORK_INFO = 'network_info',
  NEARLINK_ACCESS = 'nearlink_access'
}

export class BusinessPermissionCatalog {
  static permissionsFor(group: BusinessPermissionGroup): PlatformPermission[] {
    switch (group) {
      case BusinessPermissionGroup.BLUETOOTH_SCAN_CONNECT:
        return [AppPermission.ACCESS_BLUETOOTH];
      case BusinessPermissionGroup.BLUETOOTH_PERSISTENT_MAC:
        return [AppPermission.ACCESS_BLUETOOTH, AppPermission.PERSISTENT_BLUETOOTH_PEERS_MAC];
      case BusinessPermissionGroup.BLUETOOTH_BACKGROUND:
        return [AppPermission.KEEP_BACKGROUND_RUNNING];
      case BusinessPermissionGroup.WIFI_INFO:
        return [AppPermission.GET_WIFI_INFO];
      case BusinessPermissionGroup.WIFI_PEERS_MAC:
        return [AppPermission.GET_WIFI_INFO, AppPermission.GET_WIFI_PEERS_MAC];
      case BusinessPermissionGroup.WIFI_CONTROL:
        return [AppPermission.GET_WIFI_INFO, AppPermission.SET_WIFI_INFO];
      case BusinessPermissionGroup.NETWORK_ACCESS:
        return [AppPermission.INTERNET];
      case BusinessPermissionGroup.NETWORK_INFO:
        return [AppPermission.GET_NETWORK_INFO];
      case BusinessPermissionGroup.NEARLINK_ACCESS:
        return [AppPermission.ACCESS_NEARLINK];
      default:
        return [];
    }
  }

  static reasonFor(group: BusinessPermissionGroup): ResourceStr {
    switch (group) {
      case BusinessPermissionGroup.BLUETOOTH_SCAN_CONNECT:
        return $r('app.string.perm_reason_bluetooth_scan_connect');
      case BusinessPermissionGroup.BLUETOOTH_PERSISTENT_MAC:
        return $r('app.string.perm_reason_bluetooth_persistent_mac');
      case BusinessPermissionGroup.BLUETOOTH_BACKGROUND:
        return $r('app.string.perm_reason_bluetooth_background');
      case BusinessPermissionGroup.WIFI_INFO:
        return $r('app.string.perm_reason_wifi_info');
      case BusinessPermissionGroup.WIFI_PEERS_MAC:
        return $r('app.string.perm_reason_wifi_peers_mac');
      case BusinessPermissionGroup.WIFI_CONTROL:
        return $r('app.string.perm_reason_wifi_control');
      case BusinessPermissionGroup.NETWORK_ACCESS:
        return $r('app.string.perm_reason_network_access');
      case BusinessPermissionGroup.NETWORK_INFO:
        return $r('app.string.perm_reason_network_info');
      case BusinessPermissionGroup.NEARLINK_ACCESS:
        return $r('app.string.perm_reason_nearlink_access');
      default:
        return $r('app.string.perm_reason_default');
    }
  }

  static presentationFor(group: BusinessPermissionGroup): PermissionPresentation {
    return new PermissionPresentation(
      group,
      $r('app.string.perm_title_required'),
      BusinessPermissionCatalog.reasonFor(group),
      $r('app.string.perm_action_grant')
    );
  }
}
