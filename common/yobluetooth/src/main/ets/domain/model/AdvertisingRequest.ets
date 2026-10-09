import { Result, ResultError } from 'common_core';
import { BluetoothConstants } from '../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';

/**
 * Editable advertising fields. There is no custom AD Type.
 * Fixed types only: service UUID, service data 0x16, manufacturer 0xFF, name 0x09.
 */
export class AdvertisingRequest {
  readonly serviceUuids: string[];
  readonly serviceDataUuid: string;
  readonly serviceDataHex: string;
  readonly manufacturerId: number;
  readonly manufacturerHex: string;
  readonly includeDeviceName: boolean;
  readonly deviceName: string;
  readonly extended: boolean;
  readonly connectable: boolean;
  readonly scanResponseHex: string;
  readonly durationMs: number;

  constructor(
    serviceUuids: string[] = [],
    serviceDataUuid: string = '',
    serviceDataHex: string = '',
    manufacturerId: number = -1,
    manufacturerHex: string = '',
    includeDeviceName: boolean = false,
    deviceName: string = '',
    extended: boolean = false,
    connectable: boolean = true,
    scanResponseHex: string = '',
    durationMs: number = 0
  ) {
    this.serviceUuids = serviceUuids;
    this.serviceDataUuid = serviceDataUuid;
    this.serviceDataHex = serviceDataHex;
    this.manufacturerId = manufacturerId;
    this.manufacturerHex = manufacturerHex;
    this.includeDeviceName = includeDeviceName;
    this.deviceName = deviceName;
    this.extended = extended;
    this.connectable = connectable;
    this.scanResponseHex = scanResponseHex;
    this.durationMs = durationMs;
  }
}

export class AdvertisingRequestPolicy {
  static legacyPayloadBytes(request: AdvertisingRequest): number {
    let total = 0;
    if (request.includeDeviceName && request.deviceName.length > 0) {
      total += 2 + request.deviceName.length;
    }
    for (let i = 0; i < request.serviceUuids.length; i++) {
      const compact = request.serviceUuids[i].replace(/-/g, '');
      total += 2 + Math.floor(compact.length / 2);
    }
    if (request.serviceDataHex.length > 0) {
      total += 2 + 2 + Math.floor(request.serviceDataHex.replace(/\s/g, '').length / 2);
    }
    if (request.manufacturerHex.length > 0) {
      total += 2 + 2 + Math.floor(request.manufacturerHex.replace(/\s/g, '').length / 2);
    }
    return total;
  }

  static validate(request: AdvertisingRequest): Result<void> {
    if (request.extended && request.connectable && request.scanResponseHex.trim().length > 0) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.ADV_REJECTED,
        'Extended connectable advertising cannot include a scan response'
      ));
    }
    if (!request.extended &&
      AdvertisingRequestPolicy.legacyPayloadBytes(request) > BluetoothConstants.ADV_LEGACY_MAX_BYTES) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.ADV_TOO_LONG,
        'Legacy advertising payload exceeds 31 bytes'
      ));
    }
    return Result.ok(undefined);
  }
}
