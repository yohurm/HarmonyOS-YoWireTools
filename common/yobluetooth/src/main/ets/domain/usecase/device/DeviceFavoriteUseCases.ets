import { Result } from 'common_core';
import { DeviceFavoriteRecord } from 'common_storage';
import { BluetoothRepositoryContract } from '../../repository/BluetoothRepositoryContract';
import { bluetoothRepository } from '../../repository/BluetoothRepositories';
import { BluetoothDevice } from '../../model/BluetoothDevice';

export class SaveBluetoothFavoriteUseCase {
  private readonly repository: BluetoothRepositoryContract;

  constructor(repository: BluetoothRepositoryContract = bluetoothRepository()) {
    this.repository = repository;
  }

  /**
   * Local bookmark only. Does not call addPersistentDeviceId and must not be shown as 已固化.
   */
  async execute(device: BluetoothDevice, alias: string, protocol: string, uuid: string = ''): Promise<Result<void>> {
    return this.repository.saveFavorite(device, alias, protocol, uuid);
  }

  listFavorites(): DeviceFavoriteRecord[] {
    return this.repository.listFavorites();
  }
}

export class LoadRemoteProfileUuidsUseCase {
  private readonly repository: BluetoothRepositoryContract;

  constructor(repository: BluetoothRepositoryContract = bluetoothRepository()) {
    this.repository = repository;
  }

  async execute(deviceId: string): Promise<Result<string[]>> {
    return this.repository.getRemoteProfileUuids(deviceId);
  }
}
