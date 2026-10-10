import { Result, ResultError } from 'common_core';
import { SettingsRepository } from '../data/repository/SettingsRepository';
import { SettingsRepositoryContract } from '../domain/repository/SettingsRepositoryContract';

export class LoadWifiModuleSettingsUseCase {
  private readonly repository: SettingsRepositoryContract;

  constructor(repository: SettingsRepositoryContract = new SettingsRepository()) {
    this.repository = repository;
  }

  async execute(): Promise<Result<number>> {
    const loaded = await this.repository.load();
    if (!loaded.success || loaded.value === undefined) {
      return Result.fail(loaded.error ?? new ResultError('YW-SET-1004', 'WiFi settings unread'));
    }
    return Result.ok(loaded.value.wifiScanCooldownMs);
  }
}

export class SaveWifiScanCooldownUseCase {
  private readonly repository: SettingsRepositoryContract;

  constructor(repository: SettingsRepositoryContract = new SettingsRepository()) {
    this.repository = repository;
  }

  execute(ms: number): Promise<Result<void>> {
    return this.repository.saveWifiScanCooldown(ms);
  }
}
