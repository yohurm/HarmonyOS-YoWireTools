export enum BleScanDutyPreset {
  LOW_POWER = 'low_power',
  BALANCED = 'balanced',
  LOW_LATENCY = 'low_latency'
}

/**
 * BLE scan filter per architecture bluetooth/03-§3.1 and PRD §7.2.
 * Platform mapping lives in data/mapper/BleScanPlatformMapper.
 */
export class BleScanFilter {
  readonly namePrefix: string;
  readonly deviceId: string;
  readonly serviceUuid: string;
  readonly manufacturerId: number;
  readonly manufacturerData: string;
  readonly manufacturerMask: string;
  readonly minRssi: number;
  readonly favoritesOnly: boolean;
  readonly dutyPreset: BleScanDutyPreset;

  constructor(
    namePrefix: string = '',
    deviceId: string = '',
    serviceUuid: string = '',
    manufacturerId: number = -1,
    manufacturerData: string = '',
    manufacturerMask: string = '',
    minRssi: number = -127,
    favoritesOnly: boolean = false,
    dutyPreset: BleScanDutyPreset = BleScanDutyPreset.BALANCED
  ) {
    this.namePrefix = namePrefix;
    this.deviceId = deviceId;
    this.serviceUuid = serviceUuid;
    this.manufacturerId = manufacturerId;
    this.manufacturerData = manufacturerData;
    this.manufacturerMask = manufacturerMask;
    this.minRssi = minRssi;
    this.favoritesOnly = favoritesOnly;
    this.dutyPreset = dutyPreset;
  }

  matchesPostFilter(deviceName: string, rssi: number, favorite: boolean): boolean {
    if (this.favoritesOnly && !favorite) {
      return false;
    }
    if (rssi < this.minRssi) {
      return false;
    }
    if (this.namePrefix.length > 0 && !deviceName.includes(this.namePrefix)) {
      return false;
    }
    return true;
  }
}
