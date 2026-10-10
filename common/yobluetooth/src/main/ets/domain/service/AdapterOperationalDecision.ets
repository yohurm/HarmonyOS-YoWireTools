import { BluetoothConstants } from '../../constants/BluetoothConstants';

/**
 * Only STATE_ON (code 2) is operational. Turning and BLE-only states are not.
 */
export class AdapterOperationalDecision {
  static isOperational(stateCode: number): boolean {
    return stateCode === BluetoothConstants.ADAPTER_STATE_ON;
  }
}
