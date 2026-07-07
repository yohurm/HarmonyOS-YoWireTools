import { DeviceNameSource, NearLinkAdvertisingPacket, NearLinkManufacturerData, NearLinkServiceData } from '../model/NearLinkAdvertisingPacket';
import { NearLinkConstants } from '../../constants/NearLinkConstants';

export class ParsedNearLinkAdvFields {
  readonly localName: string;
  readonly nameSource: DeviceNameSource;
  readonly serviceUuids: string[];
  readonly manufacturerData: NearLinkManufacturerData[];
  readonly serviceData: NearLinkServiceData[];
  readonly parseWarnings: string[];

  constructor(
    localName: string = '',
    nameSource: DeviceNameSource = DeviceNameSource.UNKNOWN,
    serviceUuids: string[] = [],
    manufacturerData: NearLinkManufacturerData[] = [],
    serviceData: NearLinkServiceData[] = [],
    parseWarnings: string[] = []
  ) {
    this.localName = localName;
    this.nameSource = nameSource;
    this.serviceUuids = serviceUuids;
    this.manufacturerData = manufacturerData;
    this.serviceData = serviceData;
    this.parseWarnings = parseWarnings;
  }
}

/**
 * Parses NearLink advertising TLV bytes per architecture nearlink/01-§7.
 */
export class NearLinkAdvParser {
  static parseBytes(bytes: Uint8Array): ParsedNearLinkAdvFields {
    const warnings: string[] = [];
    let localName = '';
    let nameSource = DeviceNameSource.UNKNOWN;
    const serviceUuids: string[] = [];
    const manufacturerData: NearLinkManufacturerData[] = [];
    const serviceData: NearLinkServiceData[] = [];
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
        warnings.push(`TLV length overflow at offset ${offset}`);
        break;
      }
      const value = bytes.subarray(valueStart, valueEnd);
      if (type === 0x08 || type === 0x09) {
        localName = NearLinkAdvParser.decodeUtf8(value);
        nameSource = DeviceNameSource.ADV_LOCAL_NAME;
      }
      if (type === 0x02 || type === 0x03) {
        NearLinkAdvParser.pushUuids(serviceUuids, value, 2);
      }
      if (type === 0x06 || type === 0x07) {
        NearLinkAdvParser.pushUuids(serviceUuids, value, 16);
      }
      if (type === 0x16 && value.length >= 2) {
        const uuidBytes = value.subarray(0, 2);
        const dataBytes = value.subarray(2);
        serviceData.push(new NearLinkServiceData(
          NearLinkAdvParser.formatUuid(uuidBytes),
          NearLinkAdvParser.toHex(dataBytes)
        ));
      }
      if (type === 0xFF && value.length >= 2) {
        const manufacturerId = (value[1] << 8) | value[0];
        manufacturerData.push(new NearLinkManufacturerData(
          manufacturerId,
          NearLinkAdvParser.toHex(value.subarray(2))
        ));
      }
      offset = valueEnd;
    }
    return new ParsedNearLinkAdvFields(
      localName,
      nameSource,
      serviceUuids,
      manufacturerData,
      serviceData,
      warnings
    );
  }

  static parseRawData(data: ArrayBuffer | undefined, deviceName: string = ''): NearLinkAdvertisingPacket {
    if (data === undefined) {
      return new NearLinkAdvertisingPacket('', 0, [], [], [], deviceName,
        deviceName.length > 0 ? DeviceNameSource.SYSTEM : DeviceNameSource.UNKNOWN, []);
    }
    const bytes = new Uint8Array(data);
    const parsed = NearLinkAdvParser.parseBytes(bytes);
    const localName = parsed.localName.length > 0 ? parsed.localName : deviceName;
    const nameSource = parsed.localName.length > 0 ? parsed.nameSource :
      (deviceName.length > 0 ? DeviceNameSource.SYSTEM : DeviceNameSource.UNKNOWN);
    return new NearLinkAdvertisingPacket(
      NearLinkAdvParser.toHex(bytes),
      bytes.length,
      parsed.serviceUuids,
      parsed.serviceData,
      parsed.manufacturerData,
      localName,
      nameSource,
      parsed.parseWarnings
    );
  }

  static isRssiValid(rssi: number): boolean {
    return rssi !== NearLinkConstants.INVALID_RSSI;
  }

  private static pushUuids(target: string[], value: Uint8Array, uuidLength: number): void {
    for (let i = 0; i + uuidLength <= value.length; i += uuidLength) {
      target.push(NearLinkAdvParser.formatUuid(value.subarray(i, i + uuidLength)));
    }
  }

  private static formatUuid(bytes: Uint8Array): string {
    if (bytes.length === 2) {
      return `0000${NearLinkAdvParser.toHex(bytes)}-0000-1000-8000-00805F9B34FB`.toUpperCase();
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

  static toHex(bytes: Uint8Array): string {
    const parts: string[] = [];
    for (let i = 0; i < bytes.length; i++) {
      parts.push(bytes[i].toString(16).padStart(2, '0'));
    }
    return parts.join('').toUpperCase();
  }
}
