import { Result, ResultError } from 'common_core';
import { SettingsRepository } from '../data/repository/SettingsRepository';
import { SettingsRepositoryContract } from '../domain/repository/SettingsRepositoryContract';

export class LoadBluetoothModuleSettingsUseCase {
  private readonly repository: SettingsRepositoryContract;

  constructor(repository: SettingsRepositoryContract = new SettingsRepository()) {
    this.repository = repository;
  }

  async execute(): Promise<Result<boolean>> {
    const loaded = await this.repository.load();
    if (!loaded.success || loaded.value === undefined) {
      return Result.fail(loaded.error ?? new ResultError('YW-SET-1002', 'Bluetooth settings unread'));
    }
    return Result.ok(loaded.value.bluetoothAutoStopDiscovery);
  }
}

export class SaveBluetoothAutoStopUseCase {
  private readonly repository: SettingsRepositoryContract;

  constructor(repository: SettingsRepositoryContract = new SettingsRepository()) {
    this.repository = repository;
  }

  execute(enabled: boolean): Promise<Result<void>> {
    return this.repository.saveBluetoothAutoStop(enabled);
  }
}
