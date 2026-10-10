import { NearLinkConstants } from '../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';
import { NearLinkGap } from '../model/NearLinkScreenCategory';
import { NearLinkPayloadRules } from './NearLinkScanPolicy';

export class NearLinkScreenRules {
  static sentenceKey(code: string): string {
    if (code === NearLinkErrorCodes.EMPTY_FILTER) {
      return 'need_filter';
    }
    if (code === NearLinkErrorCodes.DURATION_RANGE) {
      return 'duration_range';
    }
    if (code === NearLinkErrorCodes.NAME_LENGTH) {
      return 'name_length';
    }
    if (code === NearLinkErrorCodes.MANUFACTURER_DATA_NEEDS_ID) {
      return 'mfg_need_id';
    }
    if (code === NearLinkErrorCodes.MASK_LENGTH_MISMATCH) {
      return 'mask_len';
    }
    if (code === NearLinkErrorCodes.MANUFACTURER_ID_RANGE) {
      return 'mfg_id_range';
    }
    if (code === NearLinkErrorCodes.ADV_INTERVAL_RANGE) {
      return 'adv_interval';
    }
    if (code === NearLinkErrorCodes.DT_UUID_REGISTERED) {
      return 'port_registered';
    }
    if (code === NearLinkErrorCodes.DT_PORT_LIMIT) {
      return 'port_limit';
    }
    if (code === NearLinkErrorCodes.DT_UUID_NOT_REGISTERED) {
      return 'port_missing';
    }
    if (code === NearLinkErrorCodes.NOTIFY_UNSUPPORTED) {
      return 'notify_undeclared';
    }
    return '';
  }

  static blocksApi(api: number, required: number): boolean {
    return api < required;
  }

  static localNameCodeWhenOff(radioOff: boolean): string {
    if (!radioOff) {
      return '';
    }
    return `${NearLinkConstants.NATIVE_RADIO_OFF}`;
  }

  static durationElapsed(durationSec: number, elapsedSec: number): boolean {
    return durationSec >= NearLinkConstants.MIN_SCAN_DURATION_SEC &&
      durationSec <= NearLinkConstants.MAX_SCAN_DURATION_SEC &&
      elapsedSec >= durationSec;
  }

  static readEnabled(operation: number): boolean {
    return NearLinkPayloadRules.readable(operation);
  }

  static discoverAllowed(connected: boolean): boolean {
    return connected;
  }

  static portIsConnected(state: number): boolean {
    return state === 1;
  }

  static rejectBluetoothMtu(code: string): string {
    if (code === '2900099') {
      return `${NearLinkConstants.NATIVE_OPERATION_FAILED}`;
    }
    return code;
  }

  static addressDiffers(saved: string, current: string): boolean {
    return saved.length > 0 && current.length > 0 && saved !== current;
  }

  static gapHasSuccess(gapId: string): boolean {
    return NearLinkGap.hasSuccessPath(gapId);
  }

  static notifyLine(connected: boolean, armed: boolean, invalidated: boolean): string {
    if (!connected && invalidated) {
      return 'reenable';
    }
    if (connected && !armed) {
      return 'not_enabled';
    }
    return '';
  }
}
