import { Result } from 'common_core';
import { SettingsSnapshot } from '../domain/model/SettingsSnapshot';
import { SettingsRepositoryContract } from '../domain/repository/SettingsRepositoryContract';
import { SettingsRepository } from '../data/repository/SettingsRepository';

export class LoadSettingsUseCase {
  private readonly repository: SettingsRepositoryContract;

  constructor(repository: SettingsRepositoryContract = new SettingsRepository()) {
    this.repository = repository;
  }

  execute(): Promise<Result<SettingsSnapshot>> {
    return this.repository.load();
  }
}

export class UpdateSettingUseCase {
  private readonly repository: SettingsRepositoryContract;

  constructor(repository: SettingsRepositoryContract = new SettingsRepository()) {
    this.repository = repository;
  }

  saveTheme(mode: string): Promise<Result<void>> {
    return this.repository.saveTheme(mode);
  }

  saveAppMode(mode: string): Promise<Result<void>> {
    return this.repository.saveAppMode(mode);
  }

  saveLogRetentionDays(days: number): Promise<Result<void>> {
    return this.repository.saveLogRetentionDays(days);
  }

  saveRepeatAllowed(allowed: boolean): Promise<Result<void>> {
    return this.repository.saveRepeatAllowed(allowed);
  }

  saveBackgroundConnection(allowed: boolean): Promise<Result<void>> {
    return this.repository.saveBackgroundConnection(allowed);
  }

  saveLineEnding(value: string): Promise<Result<void>> {
    return this.repository.saveLineEnding(value);
  }

  saveLogDisplay(value: string): Promise<Result<void>> {
    return this.repository.saveLogDisplay(value);
  }

  saveBluetoothAutoStop(enabled: boolean): Promise<Result<void>> {
    return this.repository.saveBluetoothAutoStop(enabled);
  }

  saveWifiScanCooldown(ms: number): Promise<Result<void>> {
    return this.repository.saveWifiScanCooldown(ms);
  }

  saveNearLinkRequireFilter(enabled: boolean): Promise<Result<void>> {
    return this.repository.saveNearLinkRequireFilter(enabled);
  }

  saveMaskAddress(enabled: boolean): Promise<Result<void>> {
    return this.repository.saveMaskAddress(enabled);
  }

  saveMaskHeaders(enabled: boolean): Promise<Result<void>> {
    return this.repository.saveMaskHeaders(enabled);
  }
}

export class ClearLocalDataUseCase {
  private readonly repository: SettingsRepositoryContract;

  constructor(repository: SettingsRepositoryContract = new SettingsRepository()) {
    this.repository = repository;
  }

  execute(): Promise<Result<number>> {
    return this.repository.clearLocalData();
  }
}
