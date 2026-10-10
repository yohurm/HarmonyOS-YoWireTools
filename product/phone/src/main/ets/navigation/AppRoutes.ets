/**
 * Five main tabs, then feature-stack pushes. One Navigation, one NavPathStack.
 */
export class AppRoutes {
  static readonly HOME: string = '/home/dashboard';
  static readonly BLUETOOTH: string = '/bluetooth/overview';
  static readonly BLUETOOTH_SPP: string = '/bluetooth/spp';
  static readonly BLUETOOTH_SPP_TERMINAL: string = '/bluetooth/spp/terminal';
  static readonly BLUETOOTH_BLE: string = '/bluetooth/ble';
  static readonly BLUETOOTH_SETTINGS: string = '/bluetooth/settings';
  static readonly BLUETOOTH_COMMAND: string = '/bluetooth/command';
  static readonly NEARLINK: string = '/nearlink/overview';
  static readonly NEARLINK_SETTINGS: string = '/nearlink/settings';
  static readonly NEARLINK_COMMAND: string = '/nearlink/command';
  static readonly WIFI: string = '/wifi/overview';
  static readonly WIFI_SETTINGS: string = '/wifi/settings';
  static readonly WIFI_COMMAND: string = '/wifi/command';
  static readonly SETTINGS: string = '/settings/app';
  static readonly LOG_CENTER: string = 'log/center';
  static readonly LOG_DETAIL: string = 'log/detail';

  static readonly TAB_INDEX_HOME: number = 0;
  static readonly TAB_INDEX_BLUETOOTH: number = 1;
  static readonly TAB_INDEX_NEARLINK: number = 2;
  static readonly TAB_INDEX_WIFI: number = 3;
  static readonly TAB_INDEX_SETTINGS: number = 4;
}
