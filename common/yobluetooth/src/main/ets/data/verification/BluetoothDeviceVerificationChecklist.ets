export class BluetoothVerificationItem {
  readonly id: string;
  readonly title: string;
  readonly description: string;

  constructor(id: string, title: string, description: string) {
    this.id = id;
    this.title = title;
    this.description = description;
  }
}

/**
 * Architecture 02-§10.2 device verification checklist as executable catalog.
 */
export class BluetoothDeviceVerificationChecklist {
  static listAll(): BluetoothVerificationItem[] {
    return [
      new BluetoothVerificationItem('bt-v-01', 'Permission flow', 'Grant/deny ACCESS_BLUETOOTH and return from settings'),
      new BluetoothVerificationItem('bt-v-02', 'Classic scan', 'Start/stop classic discovery with 12s timeout'),
      new BluetoothVerificationItem('bt-v-02b', 'Transport filter', 'Paired LE-only excluded from SPP list; BR_EDR/DUAL remain'),
      new BluetoothVerificationItem('bt-v-02c', 'Dual address', 'getRemoteDeviceTransport + classicDeviceId/bleDeviceId linked for DUAL'),
      new BluetoothVerificationItem('bt-v-03', 'Pairing', 'System pairing dialog completes successfully'),
      new BluetoothVerificationItem('bt-v-03b', 'BLE to classic bridge', 'Pair via BLE MAC then resolve classic MAC by name'),
      new BluetoothVerificationItem('bt-v-04', 'SPP standard UUID', 'Connect with classicDeviceId + default SPP UUID'),
      new BluetoothVerificationItem('bt-v-04b', 'Reject BLE MAC for SPP', 'sppConnect with BLE address fails YW-BT-1303'),
      new BluetoothVerificationItem('bt-v-05', 'SPP custom UUID', 'Connect with user-defined UUID'),
      new BluetoothVerificationItem('bt-v-06', 'SPP large payload', 'Send/receive payload >512 bytes'),
      new BluetoothVerificationItem('bt-v-07', 'Scan stop before connect', 'Connect succeeds after stopping discovery'),
      new BluetoothVerificationItem('bt-v-08', 'BLE multi-filter', 'Filter by name/service/manufacturer/mask/RSSI'),
      new BluetoothVerificationItem('bt-v-09', 'GATT discover', 'Service tree populated after connect'),
      new BluetoothVerificationItem('bt-v-09b', 'Reject classic MAC for GATT', 'createGattClient with classic-only fails YW-BT-1305'),
      new BluetoothVerificationItem('bt-v-10', 'GATT read/write/notify', 'Characteristic operations succeed'),
      new BluetoothVerificationItem('bt-v-11', 'BLE MTU + chunk', 'MTU negotiation and chunked write'),
      new BluetoothVerificationItem('bt-v-12', 'Foreground reconcile', 'Resume sessions after background/foreground')
    ];
  }
}
