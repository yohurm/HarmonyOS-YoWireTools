import { preferences } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';

/**
 * Preferences read/write with try/catch at each SDK throw site (getSync/has/put/flush).
 */
export class PreferencesAccess {
  static readString(store: preferences.Preferences, key: string, defaultValue: string): string {
    try {
      const value = store.getSync(key, defaultValue);
      return typeof value === 'string' ? value : defaultValue;
    } catch (_error) {
      return defaultValue;
    }
  }

  static readNumber(store: preferences.Preferences, key: string, defaultValue: number): number {
    try {
      const value = store.getSync(key, defaultValue);
      return typeof value === 'number' ? value : defaultValue;
    } catch (_error) {
      return defaultValue;
    }
  }

  static readBoolean(store: preferences.Preferences, key: string, defaultValue: boolean): boolean {
    try {
      const value = store.getSync(key, defaultValue);
      return typeof value === 'boolean' ? value : defaultValue;
    } catch (_error) {
      return defaultValue;
    }
  }

  static async hasKey(store: preferences.Preferences, key: string): Promise<boolean> {
    try {
      return await store.has(key);
    } catch (_error) {
      return false;
    }
  }

  static async putValue(
    store: preferences.Preferences,
    key: string,
    value: string | number | boolean
  ): Promise<Result<void>> {
    try {
      await store.put(key, value);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.PREFERENCES_FAILED, err.message));
    }
  }

  static async flush(store: preferences.Preferences): Promise<Result<void>> {
    try {
      await store.flush();
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.PREFERENCES_FAILED, err.message));
    }
  }
}
