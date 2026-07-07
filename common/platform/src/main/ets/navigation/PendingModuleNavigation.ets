/**
 * Cross-tab deep link queue for module NavPathStack routes.
 * Entry schedules a route before tab switch; feature shells consume on navToken change.
 */
export class PendingModuleNavigation {
  private static bluetoothRoute: string = '';
  private static wifiRoute: string = '';
  private static nearlinkRoute: string = '';
  private static bluetoothExtras: Record<string, string> = {};
  private static wifiExtras: Record<string, string> = {};
  private static nearlinkExtras: Record<string, string> = {};

  static scheduleBluetooth(route: string, extras?: Record<string, string>): void {
    PendingModuleNavigation.bluetoothRoute = route;
    PendingModuleNavigation.bluetoothExtras = extras ?? {};
  }

  static scheduleWifi(route: string, extras?: Record<string, string>): void {
    PendingModuleNavigation.wifiRoute = route;
    PendingModuleNavigation.wifiExtras = extras ?? {};
  }

  static scheduleNearlink(route: string, extras?: Record<string, string>): void {
    PendingModuleNavigation.nearlinkRoute = route;
    PendingModuleNavigation.nearlinkExtras = extras ?? {};
  }

  static pullBluetooth(): string {
    const route = PendingModuleNavigation.bluetoothRoute;
    PendingModuleNavigation.bluetoothRoute = '';
    return route;
  }

  static pullWifi(): string {
    const route = PendingModuleNavigation.wifiRoute;
    PendingModuleNavigation.wifiRoute = '';
    return route;
  }

  static pullNearlink(): string {
    const route = PendingModuleNavigation.nearlinkRoute;
    PendingModuleNavigation.nearlinkRoute = '';
    return route;
  }

  static pullBluetoothExtras(): Record<string, string> {
    const extras = PendingModuleNavigation.bluetoothExtras;
    PendingModuleNavigation.bluetoothExtras = {};
    return extras;
  }

  static pullWifiExtras(): Record<string, string> {
    const extras = PendingModuleNavigation.wifiExtras;
    PendingModuleNavigation.wifiExtras = {};
    return extras;
  }

  static pullNearlinkExtras(): Record<string, string> {
    const extras = PendingModuleNavigation.nearlinkExtras;
    PendingModuleNavigation.nearlinkExtras = {};
    return extras;
  }
}
