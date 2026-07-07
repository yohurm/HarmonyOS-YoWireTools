import { DeviceNameSource } from '../model/BleAdvertisingPacket';

export class ParsedAdFields {
  readonly localName: string;
  readonly nameSource: DeviceNameSource;
  readonly serviceUuids: string[];
  readonly flags: number;

  constructor(
    localName: string = '',
    nameSource: DeviceNameSource = DeviceNameSource.UNKNOWN,
    serviceUuids: string[] = [],
    flags: number = 0
  ) {
    this.localName = localName;
    this.nameSource = nameSource;
    this.serviceUuids = serviceUuids;
    this.flags = flags;
  }
}

/**
 * Parses BLE AD structure bytes per architecture bluetooth/03-§3.4.
 */
export class BleAdStructureParser {
  static parse(bytes: Uint8Array, fromScanResponse: boolean = false): ParsedAdFields {
    let localName = '';
    let nameSource = DeviceNameSource.UNKNOWN;
    const serviceUuids: string[] = [];
    let flags = 0;
    let offset = 0;
    while (offset < bytes.length) {
      const length = bytes[offset];
      if (length === 0) {
        break;
      }
      const type = bytes[offset + 1];
      const valueStart = offset + 2;
      const valueEnd = offset + 1 + length;
      if (valueEnd > bytes.length) {
        break;
      }
      const value = bytes.subarray(valueStart, valueEnd);
      if (type === 0x01 && value.length > 0) {
        flags = value[0];
      }
      if (type === 0x08 || type === 0x09) {
        localName = BleAdStructureParser.decodeUtf8(value);
        nameSource = fromScanResponse
          ? DeviceNameSource.SCAN_RESPONSE
          : DeviceNameSource.ADV_LOCAL_NAME;
      }
      if (type === 0x02 || type === 0x03) {
        BleAdStructureParser.pushUuids(serviceUuids, value, 2);
      }
      if (type === 0x06 || type === 0x07) {
        BleAdStructureParser.pushUuids(serviceUuids, value, 16);
      }
      offset = valueEnd;
    }
    return new ParsedAdFields(localName, nameSource, serviceUuids, flags);
  }

  private static pushUuids(target: string[], value: Uint8Array, uuidLength: number): void {
    for (let i = 0; i + uuidLength <= value.length; i += uuidLength) {
      target.push(BleAdStructureParser.formatUuid(value.subarray(i, i + uuidLength)));
    }
  }

  private static formatUuid(bytes: Uint8Array): string {
    if (bytes.length === 2) {
      const hex = BleAdStructureParser.toHex(bytes);
      return `0000${hex}-0000-1000-8000-00805F9B34FB`.toUpperCase();
    }
    const parts: string[] = [];
    for (let i = 0; i < bytes.length; i++) {
      parts.push(bytes[i].toString(16).padStart(2, '0'));
    }
    return parts.join('').toUpperCase();
  }

  private static decodeUtf8(bytes: Uint8Array): string {
    let result = '';
    for (let i = 0; i < bytes.length; i++) {
      result += String.fromCharCode(bytes[i]);
    }
    return result;
  }

  private static toHex(bytes: Uint8Array): string {
    const parts: string[] = [];
    for (let i = 0; i < bytes.length; i++) {
      parts.push(bytes[i].toString(16).padStart(2, '0'));
    }
    return parts.join('');
  }
}
