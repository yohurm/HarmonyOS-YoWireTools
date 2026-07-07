export enum DeviceNameSource {
  SYSTEM = 'system',
  ADV_LOCAL_NAME = 'advertising_local_name',
  SCAN_RESPONSE = 'scan_response',
  USER_ALIAS = 'user_alias',
  UNKNOWN = 'unknown'
}

export class BleServiceDataEntry {
  readonly serviceUuid: string;
  readonly hexPayload: string;

  constructor(serviceUuid: string, hexPayload: string) {
    this.serviceUuid = serviceUuid;
    this.hexPayload = hexPayload;
  }
}

export class BleManufacturerDataEntry {
  readonly manufacturerId: number;
  readonly hexPayload: string;
  readonly maskMatch: boolean;

  constructor(manufacturerId: number, hexPayload: string, maskMatch: boolean = false) {
    this.manufacturerId = manufacturerId;
    this.hexPayload = hexPayload;
    this.maskMatch = maskMatch;
  }
}

/**
 * Parsed BLE advertising packet per architecture bluetooth/03-§3.4.
 */
export class BleAdvertisingPacket {
  readonly deviceId: string;
  readonly rssi: number;
  readonly connectable: boolean;
  readonly rawHex: string;
  readonly localName: string;
  readonly nameSource: DeviceNameSource;
  readonly serviceUuids: string[];
  readonly serviceData: BleServiceDataEntry[];
  readonly manufacturerData: BleManufacturerDataEntry[];
  readonly txPower: number;
  readonly flags: number;
  readonly parseWarnings: string[];
  readonly discoveredAtMs: number;
  readonly discoveryCount: number;

  constructor(
    deviceId: string,
    rssi: number,
    connectable: boolean,
    rawHex: string,
    localName: string = '',
    nameSource: DeviceNameSource = DeviceNameSource.UNKNOWN,
    serviceUuids: string[] = [],
    serviceData: BleServiceDataEntry[] = [],
    manufacturerData: BleManufacturerDataEntry[] = [],
    txPower: number = 0,
    flags: number = 0,
    parseWarnings: string[] = [],
    discoveredAtMs: number = Date.now(),
    discoveryCount: number = 1
  ) {
    this.deviceId = deviceId;
    this.rssi = rssi;
    this.connectable = connectable;
    this.rawHex = rawHex;
    this.localName = localName;
    this.nameSource = nameSource;
    this.serviceUuids = serviceUuids;
    this.serviceData = serviceData;
    this.manufacturerData = manufacturerData;
    this.txPower = txPower;
    this.flags = flags;
    this.parseWarnings = parseWarnings;
    this.discoveredAtMs = discoveredAtMs;
    this.discoveryCount = discoveryCount;
  }

  withUpdate(rssi: number, discoveredAtMs: number, discoveryCount: number): BleAdvertisingPacket {
    return new BleAdvertisingPacket(
      this.deviceId,
      rssi,
      this.connectable,
      this.rawHex,
      this.localName,
      this.nameSource,
      this.serviceUuids,
      this.serviceData,
      this.manufacturerData,
      this.txPower,
      this.flags,
      this.parseWarnings,
      discoveredAtMs,
      discoveryCount
    );
  }
}
