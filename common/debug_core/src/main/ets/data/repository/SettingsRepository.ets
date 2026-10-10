import { Result, ResultError } from 'common_core';
import {
  AppSettingRepository,
  PreferenceKeys,
  PreferencesStore,
  StorageConstants,
  StoreErrorCodes
} from 'common_storage';
import { SettingsSnapshot } from '../../domain/model/SettingsSnapshot';
import { SettingsRepositoryContract } from '../../domain/repository/SettingsRepositoryContract';
import { SessionLogRepository } from './SessionLogRepository';

export class SettingsRepository implements SettingsRepositoryContract {
  private readonly preferences: PreferencesStore;
  private readonly appSettings: AppSettingRepository;
  private readonly sessionLogs: SessionLogRepository;

  constructor(
    preferences: PreferencesStore = PreferencesStore.getInstance(),
    appSettings: AppSettingRepository = AppSettingRepository.getInstance(),
    sessionLogs: SessionLogRepository = new SessionLogRepository()
  ) {
    this.preferences = preferences;
    this.appSettings = appSettings;
    this.sessionLogs = sessionLogs;
  }

  async load(): Promise<Result<SettingsSnapshot>> {
    const theme = await this.appSettings.get(PreferenceKeys.THEME_MODE);
    if (!theme.success) {
      return Result.fail(theme.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Theme read failed'));
    }
    const snapshot = new SettingsSnapshot(
      theme.value ?? 'system',
      await this.preferences.getAppMode(),
      await this.preferences.getLogRetentionDays(),
      await this.preferences.getLogMaxSizeMb(),
      await this.preferences.getLogDefaultDisplay(),
      await this.preferences.isBackgroundConnectionAllowed(),
      await this.preferences.isBackgroundRepeatAllowed(),
      await this.preferences.getCommandDefaultLineEnding(),
      await this.preferences.isBluetoothAutoStopDiscoveryEnabled(),
      await this.preferences.getWifiScanCooldownMs(),
      await this.preferences.isNearlinkRequireFilterEnabled(),
      await this.preferences.isExportMaskAddressEnabled(),
      await this.preferences.isExportMaskHeadersEnabled(),
      true
    );
    return Result.ok(snapshot);
  }

  saveTheme(mode: string): Promise<Result<void>> {
    return this.appSettings.put(PreferenceKeys.THEME_MODE, mode);
  }

  saveAppMode(mode: string): Promise<Result<void>> {
    return this.preferences.setAppMode(mode);
  }

  saveLogRetentionDays(days: number): Promise<Result<void>> {
    return this.preferences.setLogRetentionDays(days);
  }

  saveRepeatAllowed(allowed: boolean): Promise<Result<void>> {
    return this.preferences.setBackgroundRepeatAllowed(allowed);
  }

  saveBackgroundConnection(allowed: boolean): Promise<Result<void>> {
    return this.preferences.setBackgroundConnectionAllowed(allowed);
  }

  saveLineEnding(value: string): Promise<Result<void>> {
    return this.preferences.setCommandDefaultLineEnding(value);
  }

  saveLogDisplay(value: string): Promise<Result<void>> {
    return this.preferences.setLogDefaultDisplay(value);
  }

  saveBluetoothAutoStop(enabled: boolean): Promise<Result<void>> {
    return this.preferences.setBluetoothAutoStopDiscoveryEnabled(enabled);
  }

  saveWifiScanCooldown(ms: number): Promise<Result<void>> {
    return this.preferences.setWifiScanCooldownMs(ms);
  }

  saveNearLinkRequireFilter(enabled: boolean): Promise<Result<void>> {
    return this.preferences.setNearlinkRequireFilterEnabled(enabled);
  }

  saveMaskAddress(enabled: boolean): Promise<Result<void>> {
    return this.preferences.setExportMaskAddressEnabled(enabled);
  }

  saveMaskHeaders(enabled: boolean): Promise<Result<void>> {
    return this.preferences.setExportMaskHeadersEnabled(enabled);
  }

  async clearLocalData(): Promise<Result<number>> {
    const cleaned = await this.sessionLogs.cleanup(0);
    if (!cleaned.success) {
      return cleaned;
    }
    const days = cleaned.value ?? 0;
    if (days < 0) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, 'Cleanup failed'));
    }
    return Result.ok(days);
  }
}

export class SettingsRetention {
  static readonly DEFAULT_DAYS: number = StorageConstants.DEFAULT_RETENTION_DAYS;
}
