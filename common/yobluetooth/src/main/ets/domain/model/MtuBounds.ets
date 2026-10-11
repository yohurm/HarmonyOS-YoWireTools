import { Result, ResultError } from 'common_core';
import { BluetoothConstants } from '../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';

export class MtuBounds {
  static accept(mtu: number): Result<void> {
    if (mtu < BluetoothConstants.BLE_MTU_MIN || mtu > BluetoothConstants.BLE_MTU_MAX) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.MTU_OUT_OF_RANGE,
        'MTU must be between 23 and 517'
      ));
    }
    return Result.ok(undefined);
  }
}
