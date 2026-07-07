import { NearLinkConstants } from '../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';
import { Result, ResultError } from 'common_core';

export enum NearLinkScanMode {
  LOW_POWER = 'low_power',
  BALANCED = 'balanced',
  LOW_LATENCY = 'low_latency'
}

/**
 * NearLink scan filter. Platform mapping lives in data/mapper/NearLinkScanPlatformMapper.
 */
export class NearLinkScanFilter {
  readonly address: string;
  readonly deviceName: string;
  readonly manufacturerId: number;
  readonly manufacturerDataHex: string;
  readonly manufacturerDataMaskHex: string;
  readonly allowNullFilter: boolean;
  readonly scanMode: NearLinkScanMode;
  readonly durationSec: number;
  readonly minRssi: number;

  constructor(
    address: string = '',
    deviceName: string = '',
    manufacturerId: number = -1,
    manufacturerDataHex: string = '',
    manufacturerDataMaskHex: string = '',
    allowNullFilter: boolean = false,
    scanMode: NearLinkScanMode = NearLinkScanMode.BALANCED,
    durationSec: number = 0,
    minRssi: number = -128
  ) {
    this.address = address;
    this.deviceName = deviceName;
    this.manufacturerId = manufacturerId;
    this.manufacturerDataHex = manufacturerDataHex;
    this.manufacturerDataMaskHex = manufacturerDataMaskHex;
    this.allowNullFilter = allowNullFilter;
    this.scanMode = scanMode;
    this.durationSec = durationSec;
    this.minRssi = minRssi;
  }

  validate(): Result<void> {
    if (this.manufacturerDataHex.length > 0 && this.manufacturerId < 0) {
      return Result.fail(new ResultError(NearLinkErrorCodes.EMPTY_FILTER, 'manufacturerId required'));
    }
    if (this.manufacturerDataMaskHex.length > 0) {
      if (this.manufacturerDataHex.length === 0) {
        return Result.fail(new ResultError(NearLinkErrorCodes.MASK_LENGTH_MISMATCH, 'manufacturerData required'));
      }
      if (this.normalizeHex(this.manufacturerDataHex).length !==
        this.normalizeHex(this.manufacturerDataMaskHex).length) {
        return Result.fail(new ResultError(NearLinkErrorCodes.MASK_LENGTH_MISMATCH, 'mask length mismatch'));
      }
    }
    if (this.durationSec > 0 &&
      (this.durationSec < NearLinkConstants.MIN_SCAN_DURATION_SEC ||
        this.durationSec > NearLinkConstants.MAX_SCAN_DURATION_SEC)) {
      return Result.fail(new ResultError(NearLinkErrorCodes.DT_INVALID_PARAMS, 'duration out of range'));
    }
    if (!this.allowNullFilter && !this.hasEffectiveFilter()) {
      return Result.fail(new ResultError(NearLinkErrorCodes.EMPTY_FILTER, 'At least one filter required on API 13+'));
    }
    return Result.ok(undefined);
  }

  hasEffectiveFilter(): boolean {
    return this.address.length > 0 ||
      this.deviceName.length > 0 ||
      this.manufacturerId >= 0;
  }

  matchesPostFilter(name: string, rssi: number, rssiValid: boolean): boolean {
    if (this.minRssi > -128 && rssiValid && rssi < this.minRssi) {
      return false;
    }
    if (this.deviceName.length > 0 && !name.includes(this.deviceName)) {
      return false;
    }
    return true;
  }

  private normalizeHex(value: string): string {
    return value.replace(/\s/g, '').toLowerCase();
  }
}
