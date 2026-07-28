import { BluetoothConstants } from '../../constants/BluetoothConstants';

/**
 * Splits GATT writes by negotiated MTU per architecture 02-§4.6.
 */
export class GattWriteChunker {
  static chunk(bytes: Uint8Array, mtu: number = BluetoothConstants.BLE_DEFAULT_MTU): Uint8Array[] {
    const maxPayload = Math.max(1, mtu - BluetoothConstants.BLE_GATT_OVERHEAD_BYTES);
    if (bytes.length <= maxPayload) {
      return [bytes];
    }
    const chunks: Uint8Array[] = [];
    for (let offset = 0; offset < bytes.length; offset += maxPayload) {
      const end = Math.min(offset + maxPayload, bytes.length);
      chunks.push(bytes.subarray(offset, end));
    }
    return chunks;
  }
}
