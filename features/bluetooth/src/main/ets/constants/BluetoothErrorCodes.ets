/**
 * Bluetooth module error codes per architecture bluetooth/00 §9 and 02-§9.
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

  /** transport query failed */
  static readonly TRANSPORT_QUERY_FAILED: string = 'YW-BT-1301';
  /** SPP target is LE-only */
  static readonly SPP_TARGET_LE_ONLY: string = 'YW-BT-1302';
  /** BLE address used for sppConnect */
  static readonly SPP_BLE_ADDRESS_REJECTED: string = 'YW-BT-1303';
  /** dual-mode bridge name match failed */
  static readonly DUAL_BRIDGE_NAME_MISMATCH: string = 'YW-BT-1304';
  /** classic address used for GATT */
  static readonly GATT_CLASSIC_ADDRESS_REJECTED: string = 'YW-BT-1305';

  static readonly SPP_INVALID_PARAMS: string = 'YW-BT-1311';
  static readonly SPP_UNSUPPORTED: string = 'YW-BT-1312';
  static readonly SPP_SERVICE_STOPPED: string = 'YW-BT-1313';
  static readonly SPP_PROFILE_UNSUPPORTED: string = 'YW-BT-1314';
  static readonly SPP_IO_ERROR: string = 'YW-BT-1315';
  static readonly SPP_CONNECT_FAILED: string = 'YW-BT-1399';
  /** TX queue full — backpressure reject */
  static readonly WRITE_QUEUE_FULL: string = 'YW-BT-1401';

  static readonly BLE_MTU_FAILED: string = 'YW-BLE-2001';
  static readonly BLE_NOTIFY_FAILED: string = 'YW-BLE-2002';
  static readonly BLE_GATT_CONNECT_FAILED: string = 'YW-BLE-2003';
  static readonly BLE_GATT_DISCOVER_FAILED: string = 'YW-BLE-2004';
  static readonly BLE_GATT_SESSION_LIMIT: string = 'YW-BLE-2005';
  static readonly BLE_UART_NO_PROFILE: string = 'YW-BLE-2006';
  static readonly BLE_SCAN_UNFILTERED: string = 'YW-BLE-2101';
  static readonly BLE_SCAN_FAILED: string = 'YW-BLE-2102';
  static readonly PERMISSION_DENIED: string = 'YW-PERM-1001';
}
