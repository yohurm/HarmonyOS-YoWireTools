import { Result } from 'common_core';
import { SettingsSnapshot } from '../model/SettingsSnapshot';

export interface SettingsRepositoryContract {
  load(): Promise<Result<SettingsSnapshot>>;
  saveTheme(mode: string): Promise<Result<void>>;
  saveAppMode(mode: string): Promise<Result<void>>;
  saveLogRetentionDays(days: number): Promise<Result<void>>;
  saveRepeatAllowed(allowed: boolean): Promise<Result<void>>;
  saveBackgroundConnection(allowed: boolean): Promise<Result<void>>;
  saveLineEnding(value: string): Promise<Result<void>>;
  saveLogDisplay(value: string): Promise<Result<void>>;
  saveBluetoothAutoStop(enabled: boolean): Promise<Result<void>>;
  saveWifiScanCooldown(ms: number): Promise<Result<void>>;
  saveNearLinkRequireFilter(enabled: boolean): Promise<Result<void>>;
  saveMaskAddress(enabled: boolean): Promise<Result<void>>;
  saveMaskHeaders(enabled: boolean): Promise<Result<void>>;
  clearLocalData(): Promise<Result<number>>;
}
