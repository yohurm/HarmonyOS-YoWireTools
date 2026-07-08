import { Result } from 'common_core';
import { DeviceFavoriteRecord } from 'common_storage';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';
import { BluetoothDevice } from '../../model/BluetoothDevice';

export class SaveBluetoothFavoriteUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  async execute(device: BluetoothDevice, alias: string, protocol: string, uuid: string = ''): Promise<Result<void>> {
    return this.repository.saveFavorite(device, alias, protocol, uuid);
  }

  listFavorites(): DeviceFavoriteRecord[] {
    return this.repository.listFavorites();
  }
}

export class LoadRemoteProfileUuidsUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  async execute(deviceId: string): Promise<Result<string[]>> {
    return this.repository.getRemoteProfileUuids(deviceId);
  }
}
