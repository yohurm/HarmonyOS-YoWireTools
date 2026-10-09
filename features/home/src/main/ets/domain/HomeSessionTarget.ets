import { ModuleType, ProtocolType } from 'debug_core';

/**
 * Maps a debug session to a root destination the product shell can open.
 * Bluetooth BLE and SPP stay distinct because they are different pages.
 */
export class HomeSessionTarget {
  static readonly BLUETOOTH: string = 'bluetooth';
  static readonly BLUETOOTH_SPP: string = 'bluetooth_spp';
  static readonly BLUETOOTH_BLE: string = 'bluetooth_ble';
  static readonly WIFI: string = 'wifi';
  static readonly NEARLINK: string = 'nearlink';

  static visibleTitle(displayName: string): string {
    if (displayName === 'WiFi Scan' ||
      displayName === 'NearLink Scan' ||
      displayName === 'BLE Scan' ||
      displayName === 'Classic Bluetooth Scan') {
      return '';
    }
    return displayName;
  }

  static resolve(module: string, protocol: string): string {
    if (module === ModuleType.BLUETOOTH) {
      if (protocol === ProtocolType.BLE_SCAN ||
        protocol === ProtocolType.BLE_GATT ||
        protocol === ProtocolType.BLE_UART) {
        return HomeSessionTarget.BLUETOOTH_BLE;
      }
      if (protocol === ProtocolType.SPP || protocol === ProtocolType.CLASSIC_SCAN) {
        return HomeSessionTarget.BLUETOOTH_SPP;
      }
      return HomeSessionTarget.BLUETOOTH;
    }
    if (module === ModuleType.WIFI) {
      return HomeSessionTarget.WIFI;
    }
    if (module === ModuleType.NEARLINK) {
      return HomeSessionTarget.NEARLINK;
    }
    return '';
  }
}
