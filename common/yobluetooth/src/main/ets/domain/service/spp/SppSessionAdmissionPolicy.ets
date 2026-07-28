import { Result, ResultError } from 'common_core';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { SppSessionKey } from '../../model/SppSessionKey';
import { SppSessionLedger } from './SppSessionLedger';

/**
 * Domain admission gate for multi-SPP (architecture bluetooth/02 v1.2).
 * Delegates slot truth to {@link SppSessionLedger} — no parallel counters.
 */
export class SppSessionAdmissionPolicy {
  private readonly ledger: SppSessionLedger;

  constructor(ledger: SppSessionLedger = SppSessionLedger.getInstance()) {
    this.ledger = ledger;
  }

  ensureCanConnect(sessionKey: SppSessionKey, _excludingSessionId: string = ''): Result<void> {
    if (!sessionKey.isValid()) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.SPP_INVALID_PARAMS,
        'classicDeviceId and serviceUuid required'
      ));
    }
    if (this.ledger.hasKey(sessionKey)) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.SPP_DUPLICATE_SESSION,
        `SPP session already active for ${sessionKey.compositeKey()}`
      ));
    }
    if (this.ledger.getActiveCount() >= BluetoothConstants.SPP_MAX_SESSIONS) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.SPP_SESSION_LIMIT,
        `SPP session limit ${BluetoothConstants.SPP_MAX_SESSIONS}`
      ));
    }
    return Result.ok(undefined);
  }

  hasActiveKey(sessionKey: SppSessionKey): boolean {
    return this.ledger.hasKey(sessionKey);
  }

  getActiveCount(): number {
    return this.ledger.getActiveCount();
  }
}
