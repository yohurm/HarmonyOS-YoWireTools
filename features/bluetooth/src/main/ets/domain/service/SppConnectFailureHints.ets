import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';

/**
 * Structured SPP connect failure hints per architecture bluetooth/00 §9 + 02-§4.3.
 */
export class SppConnectFailureHints {
  static explain(errorCode: string, nativeMessage: string = ''): string[] {
    const hints: string[] = [];
    switch (errorCode) {
      case BluetoothErrorCodes.PERMISSION_DENIED:
        hints.push('Grant ACCESS_BLUETOOTH in app settings');
        hints.push('Return to YoWire after granting permission');
        break;
      case BluetoothErrorCodes.ADAPTER_OFF:
        hints.push('Turn on Bluetooth in system settings');
        break;
      case BluetoothErrorCodes.TRANSPORT_QUERY_FAILED:
        hints.push('Transport type unknown — retry after pairing');
        hints.push('Use classic scan to confirm BR/EDR device');
        break;
      case BluetoothErrorCodes.SPP_TARGET_LE_ONLY:
        hints.push('This device is BLE-only and cannot use SPP');
        hints.push('Open BLE / GATT tools instead');
        break;
      case BluetoothErrorCodes.SPP_BLE_ADDRESS_REJECTED:
        hints.push('BLE virtual address cannot call sppConnect');
        hints.push('Pair via BLE to bridge and resolve classic address');
        break;
      case BluetoothErrorCodes.DUAL_BRIDGE_NAME_MISMATCH:
        hints.push('Could not match classic MAC by device name');
        hints.push('Confirm unique name or pick from classic scan list');
        break;
      case BluetoothErrorCodes.GATT_CLASSIC_ADDRESS_REJECTED:
        hints.push('Classic-only address cannot create GATT client');
        hints.push('Scan BLE and use bleDeviceId');
        break;
      case BluetoothErrorCodes.SPP_PROFILE_UNSUPPORTED:
        hints.push('Device may not expose RFCOMM SPP profile');
        hints.push('Try a custom UUID from device documentation');
        break;
      case BluetoothErrorCodes.SPP_IO_ERROR:
        hints.push('Stop classic discovery before connecting');
        hints.push('Ensure device is paired and in range');
        break;
      case BluetoothErrorCodes.SPP_CONNECT_FAILED:
        hints.push('Verify classicDeviceId and UUID');
        hints.push('Pair the device first if bond is required');
        break;
      case BluetoothErrorCodes.NOT_CONNECTED:
        hints.push('Session disconnected — reconnect from connect page');
        break;
      default:
        hints.push('Check device power and pairing state');
        break;
    }
    if (nativeMessage.length > 0) {
      hints.push(`Native: ${nativeMessage}`);
    }
    return hints;
  }
}
