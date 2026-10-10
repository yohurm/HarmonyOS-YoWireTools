import { BluetoothRepository } from '../../data/repository/BluetoothRepository';
import { BluetoothRepositoryContract } from './BluetoothRepositoryContract';

/** The one Bluetooth repository instance, typed as the domain contract. */
export function bluetoothRepository(): BluetoothRepositoryContract {
  return BluetoothRepository.getInstance();
}
