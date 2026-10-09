import { NearLinkConstants } from '../../constants/NearLinkConstants';
import {
  DeviceNameSource,
  NearLinkAdvertisingPacket,
  NearLinkManufacturerData,
  NearLinkServiceData,
  NearLinkUnknownTlv
} from '../model/NearLinkAdvertisingPacket';

export class ParsedNearLinkAdvFields {
  readonly completeLocalName: string;
  readonly shortLocalName: string;
  readonly nameSource: DeviceNameSource;
  readonly serviceUuids: string[];
  readonly manufacturerData: NearLinkManufacturerData[];
  readonly serviceData: NearLinkServiceData[];
  readonly unknownTlvs: NearLinkUnknownTlv[];
  readonly discoveryLevel: number;
  readonly deviceInfoNameByteLength: number;
  readonly parseWarnings: string[];

  constructor(
    completeLocalName: string = '',
    shortLocalName: string = '',
    nameSource: DeviceNameSource = DeviceNameSource.UNKNOWN,
    serviceUuids: string[] = [],
    manufacturerData: NearLinkManufacturerData[] = [],
    serviceData: NearLinkServiceData[] = [],
    unknownTlvs: NearLinkUnknownTlv[] = [],
    discoveryLevel: number = -1,
    deviceInfoNameByteLength: number = -1,
    parseWarnings: string[] = []
  ) {
    this.completeLocalName = completeLocalName;
    this.shortLocalName = shortLocalName;
    this.nameSource = nameSource;
    this.serviceUuids = serviceUuids;
    this.manufacturerData = manufacturerData;
    this.serviceData = serviceData;
    this.unknownTlvs = unknownTlvs;
    this.discoveryLevel = discoveryLevel;
    this.deviceInfoNameByteLength = deviceInfoNameByteLength;
    this.parseWarnings = parseWarnings;
  }

  get localName(): string {
    return this.completeLocalName.length > 0 ? this.completeLocalName : this.shortLocalName;
  }
}

/**
 * Parses NearLink advertising bytes: type, length, value.
 * 16-bit standard UUIDs expand on the alliance base.
 */
export class NearLinkAdvParser {
  static parseBytes(bytes: Uint8Array): ParsedNearLinkAdvFields {
    const warnings: string[] = [];
    let completeLocalName = '';
    let shortLocalName = '';
    const serviceUuids: string[] = [];
    const manufacturerData: NearLinkManufacturerData[] = [];
    const serviceData: NearLinkServiceData[] = [];
    const unknownTlvs: NearLinkUnknownTlv[] = [];
    let discoveryLevel = -1;
    let deviceInfoNameByteLength = -1;
    let cursor = 0;
    while (cursor < bytes.length) {
      if (cursor + 2 > bytes.length) {
        warnings.push(`TLV header overflow at offset ${cursor}`);
        break;
      }
      const typeCode = bytes[cursor];
      const valueLength = bytes[cursor + 1];
      const valueStart = cursor + 2;
      const valueEnd = valueStart + valueLength;
      if (valueLength === 0) {
        break;
      }
      if (valueEnd > bytes.length) {
        warnings.push(`TLV length overflow at offset ${cursor}`);
        break;
      }
      const value = bytes.subarray(valueStart, valueEnd);
      if (typeCode === NearLinkConstants.ADV_DISCOVERY_LEVEL) {
        discoveryLevel = value[0];
      } else if (typeCode === NearLinkConstants.ADV_COMPLETE_NAME) {
        completeLocalName = NearLinkAdvParser.decodeUtf8(value);
      } else if (typeCode === NearLinkConstants.ADV_SHORT_NAME) {
        shortLocalName = NearLinkAdvParser.decodeUtf8(value);
      } else if (typeCode === NearLinkConstants.ADV_SERVICE_DATA_16) {
        const parsed = NearLinkAdvParser.readServiceData(value, 2, 16);
        if (parsed !== undefined) {
          serviceData.push(parsed);
          if (NearLinkAdvParser.isDeviceInfoUuid(parsed.serviceUuid)) {
            deviceInfoNameByteLength = parsed.dataHex.length / 2;
          }
        }
      } else if (typeCode === NearLinkConstants.ADV_SERVICE_DATA_128) {
        const parsed = NearLinkAdvParser.readServiceData(value, 16, 128);
        if (parsed !== undefined) {
          serviceData.push(parsed);
        }
      } else if (typeCode === NearLinkConstants.ADV_UUID_LIST_16_COMPLETE ||
        typeCode === NearLinkConstants.ADV_UUID_LIST_16_INCOMPLETE) {
        NearLinkAdvParser.pushUuidList(serviceUuids, value, 2);
      } else if (typeCode === NearLinkConstants.ADV_UUID_LIST_128_COMPLETE ||
        typeCode === NearLinkConstants.ADV_UUID_LIST_128_INCOMPLETE) {
        NearLinkAdvParser.pushUuidList(serviceUuids, value, 16);
      } else if (typeCode === NearLinkConstants.ADV_MANUFACTURER && value.length >= 2) {
        const manufacturerId = value[0] | (value[1] << 8);
        manufacturerData.push(new NearLinkManufacturerData(
          manufacturerId,
          NearLinkAdvParser.toHex(value.subarray(2))
        ));
      } else {
        unknownTlvs.push(new NearLinkUnknownTlv(typeCode, NearLinkAdvParser.toHex(value)));
      }
      cursor = valueEnd;
    }
    let nameSource = DeviceNameSource.UNKNOWN;
    if (completeLocalName.length > 0) {
      nameSource = DeviceNameSource.COMPLETE;
    } else if (shortLocalName.length > 0) {
      nameSource = DeviceNameSource.SHORT;
    }
    return new ParsedNearLinkAdvFields(
      completeLocalName,
      shortLocalName,
      nameSource,
      serviceUuids,
      manufacturerData,
      serviceData,
      unknownTlvs,
      discoveryLevel,
      deviceInfoNameByteLength,
      warnings
    );
  }

  static parseRawData(data: ArrayBuffer | undefined, deviceName: string = ''): NearLinkAdvertisingPacket {
    if (data === undefined || data.byteLength === 0) {
      return new NearLinkAdvertisingPacket(
        '',
        0,
        [],
        [],
        [],
        '',
        DeviceNameSource.UNKNOWN,
        [],
        '',
        '',
        deviceName,
        [],
        -1,
        -1,
        true
      );
    }
    const bytes = new Uint8Array(data);
    const parsed = NearLinkAdvParser.parseBytes(bytes);
    return new NearLinkAdvertisingPacket(
      NearLinkAdvParser.toHex(bytes),
      bytes.length,
      parsed.serviceUuids,
      parsed.serviceData,
      parsed.manufacturerData,
      parsed.localName,
      parsed.nameSource,
      parsed.parseWarnings,
      parsed.completeLocalName,
      parsed.shortLocalName,
      deviceName,
      parsed.unknownTlvs,
      parsed.discoveryLevel,
      parsed.deviceInfoNameByteLength,
      false
    );
  }

  static isRssiValid(rssi: number): boolean {
    return rssi !== NearLinkConstants.INVALID_RSSI;
  }

  static expandStandardUuid(value: number): string {
    const tail = NearLinkAdvParser.toHex(new Uint8Array([
      (value >> 8) & 0xFF,
      value & 0xFF
    ]));
    return `${NearLinkConstants.UUID_BASE_TAIL}${tail}`;
  }

  static toHex(bytes: Uint8Array): string {
    const parts: string[] = [];
    for (let i = 0; i < bytes.length; i++) {
      parts.push(bytes[i].toString(16).padStart(2, '0'));
    }
    return parts.join('').toUpperCase();
  }

  private static readServiceData(value: Uint8Array, uuidLength: number, bitWidth: number): NearLinkServiceData | undefined {
    if (value.length < uuidLength) {
      return undefined;
    }
    const uuid = NearLinkAdvParser.formatUuid(value.subarray(0, uuidLength), uuidLength);
    const payload = value.subarray(uuidLength);
    return new NearLinkServiceData(uuid, NearLinkAdvParser.toHex(payload), bitWidth);
  }

  private static pushUuidList(target: string[], value: Uint8Array, uuidLength: number): void {
    for (let offset = 0; offset + uuidLength <= value.length; offset += uuidLength) {
      target.push(NearLinkAdvParser.formatUuid(value.subarray(offset, offset + uuidLength), uuidLength));
    }
  }

  private static formatUuid(bytes: Uint8Array, uuidLength: number): string {
    const reversed = NearLinkAdvParser.reverseHex(bytes);
    if (uuidLength === 2) {
      const value = parseInt(reversed, 16);
      return NearLinkAdvParser.expandStandardUuid(value);
    }
    return `${reversed.substring(0, 8)}-${reversed.substring(8, 12)}-${reversed.substring(12, 16)}-${reversed.substring(16, 20)}-${reversed.substring(20, 32)}`.toUpperCase();
  }

  private static reverseHex(bytes: Uint8Array): string {
    const parts: string[] = [];
    for (let i = bytes.length - 1; i >= 0; i--) {
      parts.push(bytes[i].toString(16).padStart(2, '0'));
    }
    return parts.join('').toUpperCase();
  }

  private static isDeviceInfoUuid(uuid: string): boolean {
    return uuid.toUpperCase().endsWith('0609');
  }

  private static decodeUtf8(bytes: Uint8Array): string {
    let result = '';
    for (let i = 0; i < bytes.length; i++) {
      result += String.fromCharCode(bytes[i]);
    }
    return result;
  }
}
