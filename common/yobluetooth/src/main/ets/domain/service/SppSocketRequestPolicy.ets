import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';
import { SppSocketKind } from '../model/SppSocketKind';

/**
 * RFCOMM does not take a PSM. L2CAP kinds require a positive PSM before the socket call.
 */
export class SppSocketRequestPolicy {
  static psmRequired(kind: SppSocketKind): boolean {
    return kind !== SppSocketKind.RFCOMM;
  }

  static acceptPsm(kind: SppSocketKind, psm: number): Result<number> {
    if (!SppSocketRequestPolicy.psmRequired(kind)) {
      return Result.ok(0);
    }
    if (Number.isNaN(psm) || psm <= 0) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.L2CAP_PSM_REQUIRED,
        'L2CAP connect requires a PSM'
      ));
    }
    return Result.ok(Math.floor(psm));
  }
}
