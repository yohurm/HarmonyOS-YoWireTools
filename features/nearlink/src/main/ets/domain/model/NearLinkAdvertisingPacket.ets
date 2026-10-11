export enum DeviceNameSource {
  SYSTEM = 'system',
  COMPLETE = 'complete',
  SHORT = 'short',
  UNKNOWN = 'unknown'
}

export class NearLinkManufacturerData {
  readonly manufacturerId: number;
  readonly dataHex: string;

  constructor(manufacturerId: number, dataHex: string) {
    this.manufacturerId = manufacturerId;
    this.dataHex = dataHex;
  }
}

export class NearLinkServiceData {
  readonly serviceUuid: string;
  readonly dataHex: string;
  readonly bitWidth: number;

  constructor(serviceUuid: string, dataHex: string, bitWidth: number = 16) {
    this.serviceUuid = serviceUuid;
    this.dataHex = dataHex;
    this.bitWidth = bitWidth;
  }
}

export class NearLinkUnknownTlv {
  readonly typeCode: number;
  readonly valueHex: string;

  constructor(typeCode: number, valueHex: string) {
    this.typeCode = typeCode;
    this.valueHex = valueHex;
  }
}

export class NearLinkAdvertisingPacket {
  readonly rawHex: string;
  readonly rawSize: number;
  readonly serviceUuids: string[];
  readonly serviceData: NearLinkServiceData[];
  readonly manufacturerData: NearLinkManufacturerData[];
  readonly localName: string;
  readonly nameSource: DeviceNameSource;
  readonly parseWarnings: string[];
  readonly completeLocalName: string;
  readonly shortLocalName: string;
  readonly reportedDeviceName: string;
  readonly unknownTlvs: NearLinkUnknownTlv[];
  readonly discoveryLevel: number;
  readonly deviceInfoNameByteLength: number;
  readonly isEmpty: boolean;

  constructor(
    rawHex: string = '',
    rawSize: number = 0,
    serviceUuids: string[] = [],
    serviceData: NearLinkServiceData[] = [],
    manufacturerData: NearLinkManufacturerData[] = [],
    localName: string = '',
    nameSource: DeviceNameSource = DeviceNameSource.UNKNOWN,
    parseWarnings: string[] = [],
    completeLocalName: string = '',
    shortLocalName: string = '',
    reportedDeviceName: string = '',
    unknownTlvs: NearLinkUnknownTlv[] = [],
    discoveryLevel: number = -1,
    deviceInfoNameByteLength: number = -1,
    isEmpty: boolean = false
  ) {
    this.rawHex = rawHex;
    this.rawSize = rawSize;
    this.serviceUuids = serviceUuids;
    this.serviceData = serviceData;
    this.manufacturerData = manufacturerData;
    this.localName = localName;
    this.nameSource = nameSource;
    this.parseWarnings = parseWarnings;
    this.completeLocalName = completeLocalName;
    this.shortLocalName = shortLocalName;
    this.reportedDeviceName = reportedDeviceName;
    this.unknownTlvs = unknownTlvs;
    this.discoveryLevel = discoveryLevel;
    this.deviceInfoNameByteLength = deviceInfoNameByteLength;
    this.isEmpty = isEmpty;
  }
}
