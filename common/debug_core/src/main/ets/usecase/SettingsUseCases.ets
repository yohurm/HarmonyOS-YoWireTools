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

  saveBackgroundConnection(allowed: boolean): Promise<Result<void>> {
    return this.repository.saveBackgroundConnection(allowed);
  }

  saveLogDisplay(value: string): Promise<Result<void>> {
    return this.repository.saveLogDisplay(value);
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
