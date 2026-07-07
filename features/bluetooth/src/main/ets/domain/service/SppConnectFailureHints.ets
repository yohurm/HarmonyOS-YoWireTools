import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';

/**
 * Structured SPP connect failure hints per architecture 02-§4.3.
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
      case BluetoothErrorCodes.SPP_PROFILE_UNSUPPORTED:
        hints.push('Device may not expose RFCOMM SPP profile');
        hints.push('Try a custom UUID from device documentation');
        break;
      case BluetoothErrorCodes.SPP_IO_ERROR:
        hints.push('Stop classic discovery before connecting');
        hints.push('Ensure device is paired and in range');
        break;
      case BluetoothErrorCodes.SPP_CONNECT_FAILED:
        hints.push('Verify UUID matches remote service record');
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
