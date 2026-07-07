export class BluetoothNavRoutes {
  static readonly OVERVIEW: string = 'bluetooth/overview';
  static readonly CLASSIC_SCAN: string = 'bluetooth/classic_scan';
  static readonly SPP_CONNECT: string = 'bluetooth/spp_connect';
  static readonly SPP_TERMINAL: string = 'bluetooth/spp_terminal';
  static readonly BLE_SCAN: string = 'bluetooth/ble_scan';
  static readonly BLE_DETAIL: string = 'bluetooth/ble_detail';
  static readonly GATT_SERVICE: string = 'bluetooth/gatt_service';
  static readonly MODULE_SETTINGS: string = 'bluetooth/module_settings';
}

export class BluetoothNavParams {
  readonly deviceId: string;
  readonly displayName: string;
  readonly sessionId: string;

  constructor(deviceId: string = '', displayName: string = '', sessionId: string = '') {
    this.deviceId = deviceId;
    this.displayName = displayName;
    this.sessionId = sessionId;
  }
}
