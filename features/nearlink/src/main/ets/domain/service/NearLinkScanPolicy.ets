import { NearLinkConstants } from '../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';
import { Result, ResultError } from 'common_core';

export class NearLinkLocalSighting {
  readonly visible: boolean;
  readonly belowLocalRssiGate: boolean;

  constructor(visible: boolean, belowLocalRssiGate: boolean) {
    this.visible = visible;
    this.belowLocalRssiGate = belowLocalRssiGate;
  }
}

export class NearLinkScanPolicy {
  static applyLocal(
    serviceUuids: string[],
    rssi: number,
    rssiValid: boolean,
    localServiceUuid: string,
    localUuidFilterEnabled: boolean,
    localRssiGate: number,
    hasLocalRssiGate: boolean,
    systemRssiFilter: boolean
  ): NearLinkLocalSighting {
    const visible = NearLinkScanPolicy.matchesLocalUuid(serviceUuids, localServiceUuid, localUuidFilterEnabled);
    const below = !systemRssiFilter && hasLocalRssiGate && rssiValid && rssi < localRssiGate;
    return new NearLinkLocalSighting(visible, below);
  }

  static matchesLocalUuid(serviceUuids: string[], localServiceUuid: string, enabled: boolean): boolean {
    if (!enabled || localServiceUuid.length === 0) {
      return true;
    }
    const needle = localServiceUuid.replace(/-/g, '').toLowerCase();
    for (let i = 0; i < serviceUuids.length; i++) {
      const hay = serviceUuids[i].replace(/-/g, '').toLowerCase();
      if (hay === needle || hay.endsWith(needle)) {
        return true;
      }
    }
    return false;
  }

  static rssiSortKey(rssi: number, rssiValid: boolean): number {
    if (!rssiValid || rssi === NearLinkConstants.INVALID_RSSI) {
      return -1000;
    }
    return rssi;
  }
}

export class NearLinkPayloadRules {
  static isEvenHex(value: string): boolean {
    const normalized = value.replace(/\s/g, '');
    if (normalized.length === 0 || normalized.length % 2 !== 0) {
      return false;
    }
    for (let i = 0; i < normalized.length; i++) {
      const code = normalized.charCodeAt(i);
      const digit = (code >= 48 && code <= 57) || (code >= 97 && code <= 102) || (code >= 65 && code <= 70);
      if (!digit) {
        return false;
      }
    }
    return true;
  }

  static hexToBytes(hex: string): Uint8Array {
    const normalized = hex.replace(/\s/g, '');
    const bytes = new Uint8Array(normalized.length / 2);
    for (let i = 0; i < bytes.length; i++) {
      bytes[i] = parseInt(normalized.substring(i * 2, i * 2 + 2), 16);
    }
    return bytes;
  }

  static validateSsapMtu(mtu: number): Result<void> {
    if (mtu < NearLinkConstants.MIN_MTU || mtu > NearLinkConstants.MAX_MTU) {
      return Result.fail(new ResultError(NearLinkErrorCodes.SSAP_MTU_RANGE, 'api=requestMtuSize;range=22-512'));
    }
    return Result.ok(undefined);
  }

  static validatePortMtu(mtu: number, provided: boolean): Result<number> {
    if (!provided) {
      return Result.ok(NearLinkConstants.PORT_MTU_DEFAULT);
    }
    if (mtu < NearLinkConstants.PORT_MTU_MIN || mtu > NearLinkConstants.PORT_MTU_MAX) {
      return Result.fail(new ResultError(NearLinkErrorCodes.DT_INVALID_PARAMS, 'api=connect;field=mtu'));
    }
    return Result.ok(mtu);
  }

  static exceedsMtu(byteLength: number, mtu: number): boolean {
    return mtu > 0 && byteLength > mtu;
  }

  static writeAllowed(operation: number, withResponse: boolean): boolean {
    if (withResponse) {
      return (operation & NearLinkConstants.OP_WRITE_WITH_RESPONSE) !== 0;
    }
    return (operation & NearLinkConstants.OP_WRITE_NO_RESPONSE) !== 0;
  }

  static readable(operation: number): boolean {
    return (operation & NearLinkConstants.OP_READABLE) !== 0;
  }

  static notifiable(operation: number): boolean {
    return (operation & NearLinkConstants.OP_NOTIFY) !== 0;
  }

  static canNotify(operation: number, hasClientConfig: boolean): boolean {
    return NearLinkPayloadRules.notifiable(operation) && hasClientConfig;
  }

  static validateAdvertisingInterval(interval: number): Result<void> {
    if (interval < NearLinkConstants.ADV_INTERVAL_MIN || interval > NearLinkConstants.ADV_INTERVAL_MAX) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.VALIDATION,
        'api=startAdvertising;field=interval'
      ));
    }
    return Result.ok(undefined);
  }

  static shouldRespondToWrite(writeTypeValue: number): boolean {
    return writeTypeValue === 1;
  }
}
