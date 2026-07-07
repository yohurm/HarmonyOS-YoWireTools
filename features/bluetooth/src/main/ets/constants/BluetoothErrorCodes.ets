/**
 * Bluetooth module error codes per architecture §9.
 */
export class BluetoothErrorCodes {
  static readonly ADAPTER_OFF: string = 'YW-BT-1001';
  static readonly CLASSIC_UNAVAILABLE: string = 'YW-BT-1002';
  static readonly NOT_CONNECTED: string = 'YW-BT-1003';
  static readonly OPERATION_BUSY: string = 'YW-BT-1004';
  static readonly DISCONNECTED: string = 'YW-BT-1005';
  static readonly SCAN_ALREADY_RUNNING: string = 'YW-BT-1101';
  static readonly SCAN_RESOURCE_FAILED: string = 'YW-BT-1102';
  static readonly PAIRING_CANCELLED: string = 'YW-BT-1201';
  static readonly PROFILE_UUID_FAILED: string = 'YW-BT-1202';
  static readonly SPP_INVALID_PARAMS: string = 'YW-BT-1301';
  static readonly SPP_UNSUPPORTED: string = 'YW-BT-1302';
  static readonly SPP_SERVICE_STOPPED: string = 'YW-BT-1303';
  static readonly SPP_PROFILE_UNSUPPORTED: string = 'YW-BT-1304';
  static readonly SPP_IO_ERROR: string = 'YW-BT-1305';
  static readonly SPP_CONNECT_FAILED: string = 'YW-BT-1399';
  /** Architecture 02-§9: MTU negotiation failure */
  static readonly BLE_MTU_FAILED: string = 'YW-BLE-2001';
  /** Architecture 02-§9: Notify subscription failure */
  static readonly BLE_NOTIFY_FAILED: string = 'YW-BLE-2002';
  static readonly BLE_GATT_CONNECT_FAILED: string = 'YW-BLE-2003';
  static readonly BLE_GATT_DISCOVER_FAILED: string = 'YW-BLE-2004';
  static readonly BLE_SCAN_UNFILTERED: string = 'YW-BLE-2101';
  static readonly BLE_SCAN_FAILED: string = 'YW-BLE-2102';
  static readonly PERMISSION_DENIED: string = 'YW-PERM-1001';
}
