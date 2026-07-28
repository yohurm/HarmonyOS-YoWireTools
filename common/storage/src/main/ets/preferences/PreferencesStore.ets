import { common } from '@kit.AbilityKit';
import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { YoLog, YoLogTag } from 'yolog';
import { PreferenceKeys } from '../constants/PreferenceKeys';
import { StorageConstants } from '../constants/StorageConstants';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';
import { PreferencesAccess } from './PreferencesAccess';

const logger = YoLog.tag(YoLogTag.APP);

/**
 * Typed Preferences wrapper per architecture §12.1.
 * Reads use getSync via PreferencesAccess — instance is memory-cached after initialize().
 */
export class PreferencesStore {
  private static instance: PreferencesStore | undefined;
  private prefs: preferences.Preferences | undefined;

  private constructor() {
  }

  static getInstance(): PreferencesStore {
    if (PreferencesStore.instance === undefined) {
      PreferencesStore.instance = new PreferencesStore();
    }
    return PreferencesStore.instance;
  }

  async initialize(context: common.Context): Promise<Result<void>> {
    try {
      this.prefs = await preferences.getPreferences(context, StorageConstants.PREFERENCES_NAME);
      await this.ensureDefaults();
      logger.info('preferences_initialize successful');
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      logger.error(`preferences_initialize failed, code=${err.code}, message=${err.message}`);
      return Result.fail(new ResultError(StoreErrorCodes.PREFERENCES_FAILED, err.message));
    }
  }

  async getString(key: string, defaultValue: string = ''): Promise<string> {
    if (this.prefs === undefined) {
      return defaultValue;
    }
    return PreferencesAccess.readString(this.prefs, key, defaultValue);
  }

  async putString(key: string, value: string): Promise<Result<void>> {
    if (this.prefs === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.PREFERENCES_FAILED, 'Preferences not initialized'));
    }
    const putResult = await PreferencesAccess.putValue(this.prefs, key, value);
    if (!putResult.success) {
      return putResult;
    }
    return PreferencesAccess.flush(this.prefs);
  }

  async getNumber(key: string, defaultValue: number): Promise<number> {
    if (this.prefs === undefined) {
      return defaultValue;
    }
    return PreferencesAccess.readNumber(this.prefs, key, defaultValue);
  }

  async putNumber(key: string, value: number): Promise<Result<void>> {
    if (this.prefs === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.PREFERENCES_FAILED, 'Preferences not initialized'));
    }
    const putResult = await PreferencesAccess.putValue(this.prefs, key, value);
    if (!putResult.success) {
      return putResult;
    }
    return PreferencesAccess.flush(this.prefs);
  }

  async getBoolean(key: string, defaultValue: boolean): Promise<boolean> {
    if (this.prefs === undefined) {
      return defaultValue;
    }
    return PreferencesAccess.readBoolean(this.prefs, key, defaultValue);
  }

  async putBoolean(key: string, value: boolean): Promise<Result<void>> {
    if (this.prefs === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.PREFERENCES_FAILED, 'Preferences not initialized'));
    }
    const putResult = await PreferencesAccess.putValue(this.prefs, key, value);
    if (!putResult.success) {
      return putResult;
    }
    return PreferencesAccess.flush(this.prefs);
  }

  async getAppMode(): Promise<string> {
    return this.getString(PreferenceKeys.APP_MODE, 'expert');
  }

  async getLogRetentionDays(): Promise<number> {
    return this.getNumber(PreferenceKeys.LOG_RETENTION_DAYS, StorageConstants.DEFAULT_RETENTION_DAYS);
  }

  async getLogMaxSizeMb(): Promise<number> {
    return this.getNumber(PreferenceKeys.LOG_MAX_SIZE_MB, StorageConstants.DEFAULT_MAX_SIZE_MB);
  }

  async isBackgroundConnectionAllowed(): Promise<boolean> {
    return this.getBoolean(PreferenceKeys.BACKGROUND_ALLOW_CONNECTION, true);
  }

  async isBackgroundRepeatAllowed(): Promise<boolean> {
    return this.getBoolean(PreferenceKeys.BACKGROUND_ALLOW_REPEAT_COMMAND, false);
  }

  async isExportMaskAddressEnabled(): Promise<boolean> {
    return this.getBoolean(PreferenceKeys.PRIVACY_EXPORT_MASK_ADDRESS, false);
  }

  async isExportMaskHeadersEnabled(): Promise<boolean> {
    return this.getBoolean(PreferenceKeys.PRIVACY_EXPORT_MASK_HEADERS, true);
  }

  async setExportMaskAddressEnabled(enabled: boolean): Promise<Result<void>> {
    return this.putBoolean(PreferenceKeys.PRIVACY_EXPORT_MASK_ADDRESS, enabled);
  }

  async setExportMaskHeadersEnabled(enabled: boolean): Promise<Result<void>> {
    return this.putBoolean(PreferenceKeys.PRIVACY_EXPORT_MASK_HEADERS, enabled);
  }

  async isBluetoothAutoStopDiscoveryEnabled(): Promise<boolean> {
    return this.getBoolean(PreferenceKeys.BLUETOOTH_AUTO_STOP_DISCOVERY, true);
  }

  async setBluetoothAutoStopDiscoveryEnabled(enabled: boolean): Promise<Result<void>> {
    return this.putBoolean(PreferenceKeys.BLUETOOTH_AUTO_STOP_DISCOVERY, enabled);
  }

  async setWifiScanCooldownMs(ms: number): Promise<Result<void>> {
    return this.putNumber(PreferenceKeys.WIFI_SCAN_COOLDOWN_MS, ms);
  }

  async isNearlinkRequireFilterEnabled(): Promise<boolean> {
    return this.getBoolean(PreferenceKeys.NEARLINK_REQUIRE_FILTER, true);
  }

  async setNearlinkRequireFilterEnabled(enabled: boolean): Promise<Result<void>> {
    return this.putBoolean(PreferenceKeys.NEARLINK_REQUIRE_FILTER, enabled);
  }

  async getCommandDefaultLineEnding(): Promise<string> {
    return this.getString(PreferenceKeys.COMMAND_DEFAULT_LINE_ENDING, 'lf');
  }

  async setCommandDefaultLineEnding(value: string): Promise<Result<void>> {
    return this.putString(PreferenceKeys.COMMAND_DEFAULT_LINE_ENDING, value);
  }

  private async ensureDefaults(): Promise<void> {
    if (this.prefs === undefined) {
      return;
    }
    const defaults: Array<[string, string | number | boolean]> = [
      [PreferenceKeys.APP_MODE, 'expert'],
      [PreferenceKeys.LOG_DEFAULT_DISPLAY, 'mixed'],
      [PreferenceKeys.LOG_RETENTION_DAYS, StorageConstants.DEFAULT_RETENTION_DAYS],
      [PreferenceKeys.LOG_MAX_SIZE_MB, StorageConstants.DEFAULT_MAX_SIZE_MB],
      [PreferenceKeys.COMMAND_DEFAULT_LINE_ENDING, 'lf'],
      [PreferenceKeys.BACKGROUND_ALLOW_CONNECTION, true],
      [PreferenceKeys.BACKGROUND_ALLOW_REPEAT_COMMAND, false],
      [PreferenceKeys.PRIVACY_EXPORT_MASK_ADDRESS, false],
      [PreferenceKeys.PRIVACY_EXPORT_MASK_HEADERS, true],
      [PreferenceKeys.WIFI_SCAN_COOLDOWN_MS, 3000],
      [PreferenceKeys.BLUETOOTH_AUTO_STOP_DISCOVERY, true],
      [PreferenceKeys.NEARLINK_REQUIRE_FILTER, true]
    ];
    for (let i = 0; i < defaults.length; i++) {
      const key = defaults[i][0];
      const hasKey = await PreferencesAccess.hasKey(this.prefs, key);
      if (!hasKey) {
        const putResult = await PreferencesAccess.putValue(this.prefs, key, defaults[i][1]);
        if (!putResult.success) {
          return;
        }
      }
    }
    await PreferencesAccess.flush(this.prefs);
  }
}
