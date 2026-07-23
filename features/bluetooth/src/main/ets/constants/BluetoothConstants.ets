/**
 * Bluetooth module shared constants.
 */
export class BluetoothConstants {
  static readonly DEFAULT_SPP_UUID: string = '00001101-0000-1000-8000-00805F9B34FB';
  static readonly CLASSIC_DISCOVERY_TIMEOUT_MS: number = 12000;
  static readonly DEFAULT_SPP_CONNECT_TIMEOUT_MS: number = 15000;
  static readonly SPP_MAX_WRITE_BYTES: number = 1024;
  static readonly NORDIC_UART_SERVICE_UUID: string = '6E400001-B5A3-F393-E0A9-E50E24DCCA9E';
  static readonly NORDIC_UART_RX_UUID: string = '6E400002-B5A3-F393-E0A9-E50E24DCCA9E';
  static readonly NORDIC_UART_TX_UUID: string = '6E400003-B5A3-F393-E0A9-E50E24DCCA9E';
  static readonly BLE_DEFAULT_MTU: number = 23;
  static readonly BLE_GATT_OVERHEAD_BYTES: number = 3;
  /** TX CommandWriteQueue depth before reject (architecture bluetooth/05). */
  static readonly COMMAND_WRITE_QUEUE_MAX_DEPTH: number = 32;
  /** Application-layer GATT multi-session cap (architecture bluetooth/05). */
  static readonly GATT_MAX_SESSIONS: number = 4;
  static readonly GATT_CCCD_UUID: string = '00002902-0000-1000-8000-00805F9B34FB';
  static readonly TI_UART_SERVICE_UUID: string = '0000FFE0-0000-1000-8000-00805F9B34FB';
  static readonly TI_UART_CHAR_UUID: string = '0000FFE1-0000-1000-8000-00805F9B34FB';
}
