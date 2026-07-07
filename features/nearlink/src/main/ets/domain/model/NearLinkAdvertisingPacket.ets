export enum DeviceNameSource {
  SYSTEM = 'system',
  ADV_LOCAL_NAME = 'adv_local_name',
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

  constructor(serviceUuid: string, dataHex: string) {
    this.serviceUuid = serviceUuid;
    this.dataHex = dataHex;
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

  constructor(
    rawHex: string = '',
    rawSize: number = 0,
    serviceUuids: string[] = [],
    serviceData: NearLinkServiceData[] = [],
    manufacturerData: NearLinkManufacturerData[] = [],
    localName: string = '',
    nameSource: DeviceNameSource = DeviceNameSource.UNKNOWN,
    parseWarnings: string[] = []
  ) {
    this.rawHex = rawHex;
    this.rawSize = rawSize;
    this.serviceUuids = serviceUuids;
    this.serviceData = serviceData;
    this.manufacturerData = manufacturerData;
    this.localName = localName;
    this.nameSource = nameSource;
    this.parseWarnings = parseWarnings;
  }
}
