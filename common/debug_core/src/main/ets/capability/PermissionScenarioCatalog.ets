import { AppPermission, PermissionPresentation, PlatformPermission } from 'common_platform';
import { PermissionScenario } from './PermissionScenario';

/**
 * Maps business permission scenarios to platform requests and UI copy.
 */
export class PermissionScenarioCatalog {
  static permissionsFor(scenario: PermissionScenario): PlatformPermission[] {
    switch (scenario) {
      case PermissionScenario.HOME_SUMMARY:
        return [];
      case PermissionScenario.BLUETOOTH_SCAN_CONNECT:
        return [AppPermission.ACCESS_BLUETOOTH];
      case PermissionScenario.BLUETOOTH_PERSISTENT_MAC:
        return [AppPermission.ACCESS_BLUETOOTH, AppPermission.PERSISTENT_BLUETOOTH_PEERS_MAC];
      case PermissionScenario.BLUETOOTH_BACKGROUND:
        return [AppPermission.KEEP_BACKGROUND_RUNNING];
      case PermissionScenario.WIFI_INFO:
        return [AppPermission.GET_WIFI_INFO];
      case PermissionScenario.WIFI_PEERS_MAC:
        return [AppPermission.GET_WIFI_INFO, AppPermission.GET_WIFI_PEERS_MAC];
      case PermissionScenario.WIFI_CONTROL:
        return [AppPermission.GET_WIFI_INFO, AppPermission.SET_WIFI_INFO];
      case PermissionScenario.NETWORK_ACCESS:
        return [AppPermission.INTERNET];
      case PermissionScenario.NETWORK_INFO:
        return [AppPermission.GET_NETWORK_INFO];
      case PermissionScenario.NEARLINK_ACCESS:
        return [AppPermission.ACCESS_NEARLINK];
      default:
        return [];
    }
  }

  static reasonFor(scenario: PermissionScenario): string {
    switch (scenario) {
      case PermissionScenario.BLUETOOTH_SCAN_CONNECT:
        return 'Bluetooth scan and connection require ACCESS_BLUETOOTH';
      case PermissionScenario.BLUETOOTH_PERSISTENT_MAC:
        return 'Persistent Bluetooth address requires additional permission';
      case PermissionScenario.BLUETOOTH_BACKGROUND:
        return 'Background Bluetooth keep-alive requires KEEP_BACKGROUND_RUNNING';
      case PermissionScenario.WIFI_INFO:
        return 'WiFi overview requires GET_WIFI_INFO';
      case PermissionScenario.WIFI_PEERS_MAC:
        return 'Real BSSID requires GET_WIFI_PEERS_MAC';
      case PermissionScenario.WIFI_CONTROL:
        return 'WiFi control requires SET_WIFI_INFO';
      case PermissionScenario.NETWORK_ACCESS:
        return 'Network debugging requires INTERNET';
      case PermissionScenario.NETWORK_INFO:
        return 'Network status requires GET_NETWORK_INFO';
      case PermissionScenario.NEARLINK_ACCESS:
        return 'NearLink debugging requires ACCESS_NEARLINK';
      default:
        return 'Permission required for current feature';
    }
  }

  static presentationFor(scenario: PermissionScenario): PermissionPresentation {
    if (scenario === PermissionScenario.HOME_SUMMARY) {
      return new PermissionPresentation(
        scenario,
        'No permission needed',
        'Home summary does not request permissions on entry.',
        ''
      );
    }
    return new PermissionPresentation(
      scenario,
      'Permission required',
      'Current feature needs system permission to continue.',
      'Grant permission'
    );
  }
}
