import { BluetoothConstants } from '../../../constants/BluetoothConstants';

/**
 * Human-readable RFCOMM service UUID labels for session lists.
 */
export class SppUuidLabel {
  static formatShort(uuid: string): string {
    const normalized = uuid.trim().toLowerCase();
    if (normalized.length === 0) {
      return '';
    }
    if (normalized === BluetoothConstants.DEFAULT_SPP_UUID.toLowerCase()) {
      return 'SPP';
    }
    if (normalized.length <= 8) {
      return normalized;
    }
    return normalized.substring(0, 8);
  }
}
