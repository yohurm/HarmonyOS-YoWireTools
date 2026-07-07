import { AppPermission } from './AppPermission';
import { PermissionPresentation } from './PermissionPresentation';
import { PlatformPermission } from './PlatformPermission';

/**
 * Business permission groups for feature modules — maps capability to platform permissions and copy.
 */
export enum BusinessPermissionGroup {
  BLUETOOTH_SCAN_CONNECT = 'bluetooth_scan_connect',
  BLUETOOTH_PERSISTENT_MAC = 'bluetooth_persistent_mac',
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

  static reasonFor(group: BusinessPermissionGroup): string {
    switch (group) {
      case BusinessPermissionGroup.BLUETOOTH_SCAN_CONNECT:
        return '蓝牙扫描与连接需要 ACCESS_BLUETOOTH 权限';
      case BusinessPermissionGroup.BLUETOOTH_PERSISTENT_MAC:
        return '持久化蓝牙地址需要额外权限';
      case BusinessPermissionGroup.WIFI_INFO:
        return 'WiFi 环境分析需要 GET_WIFI_INFO 权限';
      case BusinessPermissionGroup.WIFI_PEERS_MAC:
        return '读取真实 BSSID 需要 GET_WIFI_PEERS_MAC 权限';
      case BusinessPermissionGroup.WIFI_CONTROL:
        return 'WiFi 控制需要 SET_WIFI_INFO 权限';
      case BusinessPermissionGroup.NETWORK_ACCESS:
        return '网络调试需要 INTERNET 权限';
      case BusinessPermissionGroup.NETWORK_INFO:
        return '网络状态查询需要 GET_NETWORK_INFO 权限';
      case BusinessPermissionGroup.NEARLINK_ACCESS:
        return '星闪调试需要 ACCESS_NEARLINK 权限';
      default:
        return '当前功能需要系统权限';
    }
  }

  static presentationFor(group: BusinessPermissionGroup): PermissionPresentation {
    return new PermissionPresentation(
      group,
      '需要权限',
      BusinessPermissionCatalog.reasonFor(group),
      '去授权'
    );
  }
}
