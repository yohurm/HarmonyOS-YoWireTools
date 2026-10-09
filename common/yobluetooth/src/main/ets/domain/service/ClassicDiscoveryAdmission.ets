import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';
import { ClassicScanPhase } from '../model/ClassicScanPhase';

/**
 * Classic discovery may not overlap, and a new start waits until stop has finished.
 * The platform call itself has no filter arguments.
 */
export class ClassicDiscoveryAdmission {
  static admit(phase: ClassicScanPhase, platformDiscovering: boolean): Result<void> {
    if (phase === ClassicScanPhase.STOPPING) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.SCAN_STOP_PENDING,
        'Previous discovery stop has not finished'
      ));
    }
    if (phase === ClassicScanPhase.SCANNING || platformDiscovering) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.SCAN_ALREADY_RUNNING,
        'Discovery already running'
      ));
    }
    return Result.ok(undefined);
  }
}
