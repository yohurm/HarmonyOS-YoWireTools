import { BluetoothConstants } from '../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';

/**
 * Structured SPP connect failure hints per architecture bluetooth/00 §9 + 02-§13.
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
      case BluetoothErrorCodes.SPP_DUPLICATE_SESSION:
        // YW-BT-1316 — same (classicDeviceId, serviceUuid) already reserved/connected
        hints.push('Same device and UUID already has an active SPP session (YW-BT-1316)');
        hints.push('Disconnect that session, or connect with a different UUID');
        break;
      case BluetoothErrorCodes.SPP_SESSION_LIMIT:
        // YW-BT-1317 — application cap
        hints.push(
          `At most ${BluetoothConstants.SPP_MAX_SESSIONS} parallel SPP sessions are allowed (YW-BT-1317)`
        );
        hints.push('Disconnect an existing SPP session before opening another');
        break;
      case BluetoothErrorCodes.SPP_CONNECT_TIMEOUT:
        // YW-BT-1318 — sppConnect exceeded timeoutMs
        hints.push('sppConnect timed out before the remote answered (YW-BT-1318)');
        hints.push('Stop classic discovery, move closer, then retry with a longer timeout');
        break;
      case BluetoothErrorCodes.NOT_CONNECTED:
        hints.push('Session disconnected — reconnect from SPP connect dialog');
        break;
      case BluetoothErrorCodes.NOT_PAIRED:
        hints.push('Device is not paired (2900016)');
        hints.push('Start pairing. This is not a connection timeout');
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
