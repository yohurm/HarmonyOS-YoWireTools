import { NearLinkConstants } from '../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';
import { Result, ResultError } from 'common_core';

export enum NearLinkScanMode {
  LOW_POWER = 'low_power',
  BALANCED = 'balanced'
}

export class NearLinkSystemFilter {
  readonly address: string;
  readonly deviceName: string;
  readonly manufacturerId: number;
  readonly manufacturerDataHex: string;
  readonly manufacturerDataMaskHex: string;
  readonly rssi: number;
  readonly hasRssi: boolean;

  constructor(
    address: string = '',
    deviceName: string = '',
    manufacturerId: number = -1,
    manufacturerDataHex: string = '',
    manufacturerDataMaskHex: string = '',
    rssi: number = 0,
    hasRssi: boolean = false
  ) {
    this.address = address;
    this.deviceName = deviceName;
    this.manufacturerId = manufacturerId;
    this.manufacturerDataHex = manufacturerDataHex;
    this.manufacturerDataMaskHex = manufacturerDataMaskHex;
    this.rssi = rssi;
    this.hasRssi = hasRssi;
  }

  isEmpty(): boolean {
    return this.address.length === 0 &&
      this.deviceName.length === 0 &&
      this.manufacturerId < 0 &&
      this.manufacturerDataHex.length === 0 &&
      !this.hasRssi;
  }
}

/**
 * Scan request. System fields and local-only fields stay apart.
 * Kit mapping does not receive a service UUID.
 */
export class NearLinkScanFilter {
  readonly groups: NearLinkSystemFilter[];
  readonly scanMode: NearLinkScanMode;
  readonly durationSec: number;
  readonly scanAll: boolean;
  readonly localServiceUuid: string;
  readonly localUuidFilterEnabled: boolean;
  readonly localRssiGate: number;
  readonly hasLocalRssiGate: boolean;

  constructor(
    groups: NearLinkSystemFilter[] = [],
    scanMode: NearLinkScanMode = NearLinkScanMode.LOW_POWER,
    durationSec: number = 0,
    scanAll: boolean = false,
    localServiceUuid: string = '',
    localUuidFilterEnabled: boolean = false,
    localRssiGate: number = 0,
    hasLocalRssiGate: boolean = false
  ) {
    this.groups = groups;
    this.scanMode = scanMode;
    this.durationSec = durationSec;
    this.scanAll = scanAll;
    this.localServiceUuid = localServiceUuid;
    this.localUuidFilterEnabled = localUuidFilterEnabled;
    this.localRssiGate = localRssiGate;
    this.hasLocalRssiGate = hasLocalRssiGate;
  }

  static named(deviceName: string): NearLinkScanFilter {
    return new NearLinkScanFilter([new NearLinkSystemFilter('', deviceName)]);
  }

  validate(): Result<void> {
    if (this.durationSec !== 0 &&
      (this.durationSec < NearLinkConstants.MIN_SCAN_DURATION_SEC ||
        this.durationSec > NearLinkConstants.MAX_SCAN_DURATION_SEC)) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.DURATION_RANGE,
        'api=startScan;field=duration',
        undefined,
        {},
        ''
      ));
    }
    for (let i = 0; i < this.groups.length; i++) {
      const group = this.groups[i];
      const groupError = NearLinkScanFilter.validateGroup(group);
      if (groupError !== undefined) {
        return Result.fail(groupError);
      }
    }
    if (!this.scanAll && !this.hasEffectiveSystemFilter()) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.EMPTY_FILTER,
        'api=startScan;native=401',
        undefined,
        { 'nativeCode': NearLinkConstants.NATIVE_INVALID },
        `${NearLinkConstants.NATIVE_INVALID}`
      ));
    }
    return Result.ok(undefined);
  }

  hasEffectiveSystemFilter(): boolean {
    for (let i = 0; i < this.groups.length; i++) {
      if (!this.groups[i].isEmpty()) {
        return true;
      }
    }
    return false;
  }

  private static validateGroup(group: NearLinkSystemFilter): ResultError | undefined {
    if (group.deviceName.length > NearLinkConstants.NAME_MAX_LENGTH) {
      return new ResultError(NearLinkErrorCodes.NAME_LENGTH, 'api=startScan;field=deviceName');
    }
    if (group.manufacturerDataHex.length > 0 && group.manufacturerId < 0) {
      return new ResultError(NearLinkErrorCodes.MANUFACTURER_DATA_NEEDS_ID, 'api=startScan;field=manufacturerId');
    }
    if (group.manufacturerId >= 0 &&
      (group.manufacturerId < NearLinkConstants.MANUFACTURER_ID_MIN ||
        group.manufacturerId > NearLinkConstants.MANUFACTURER_ID_MAX)) {
      return new ResultError(NearLinkErrorCodes.MANUFACTURER_ID_RANGE, 'api=startScan;field=manufacturerId');
    }
    if (group.manufacturerDataMaskHex.length > 0) {
      const dataLen = NearLinkScanFilter.normalizeHex(group.manufacturerDataHex).length;
      const maskLen = NearLinkScanFilter.normalizeHex(group.manufacturerDataMaskHex).length;
      if (dataLen === 0 || dataLen !== maskLen) {
        return new ResultError(NearLinkErrorCodes.MASK_LENGTH_MISMATCH, 'api=startScan;field=manufacturerDataMask');
      }
    }
    return undefined;
  }

  private static normalizeHex(value: string): string {
    return value.replace(/\s/g, '').toLowerCase();
  }
}
