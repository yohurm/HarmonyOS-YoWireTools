import { Result, ResultError, TimeUtil } from 'common_core';
import { PreferenceKeys, PreferencesStore } from 'common_storage';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { SppUuidFavoriteEntry } from '../../../domain/model/SppUuidFavoriteEntry';

/**
 * Preferences-backed SPP UUID favorites (architecture filesystem plan).
 * First load seeds HS01 AT when the key is absent.
 */
export class SppUuidFavoriteDataSource {
  private static instance: SppUuidFavoriteDataSource | undefined;
  private static readonly MAX_FAVORITES: number = 20;
  private entries: SppUuidFavoriteEntry[] = [];
  private loaded: boolean = false;

  private constructor() {
  }

  static getInstance(): SppUuidFavoriteDataSource {
    if (SppUuidFavoriteDataSource.instance === undefined) {
      SppUuidFavoriteDataSource.instance = new SppUuidFavoriteDataSource();
    }
    return SppUuidFavoriteDataSource.instance;
  }

  async ensureLoaded(): Promise<SppUuidFavoriteEntry[]> {
    if (this.loaded) {
      return this.list();
    }
    const store = PreferencesStore.getInstance();
    const hasKey = await this.hasFavoritesKey();
    if (!hasKey) {
      const seeded = [
        new SppUuidFavoriteEntry(
          SppUuidFavoriteEntry.normalizeUuid(BluetoothConstants.HS01_AT_SPP_UUID),
          'HS01 AT',
          TimeUtil.nowMs()
        )
      ];
      this.entries = seeded;
      this.loaded = true;
      await this.persist();
      return this.list();
    }
    const raw = await store.getString(PreferenceKeys.BLUETOOTH_SPP_UUID_FAVORITES, '');
    this.entries = SppUuidFavoriteDataSource.parseLines(raw);
    this.loaded = true;
    return this.list();
  }

  list(): SppUuidFavoriteEntry[] {
    const copy: SppUuidFavoriteEntry[] = [];
    for (let i = 0; i < this.entries.length; i++) {
      copy.push(this.entries[i]);
    }
    return copy;
  }

  contains(uuid: string): boolean {
    const normalized = SppUuidFavoriteEntry.normalizeUuid(uuid);
    if (normalized.length === 0) {
      return false;
    }
    for (let i = 0; i < this.entries.length; i++) {
      if (this.entries[i].uuid === normalized) {
        return true;
      }
    }
    return false;
  }

  async toggle(uuid: string, label: string = ''): Promise<Result<boolean>> {
    await this.ensureLoaded();
    const normalized = SppUuidFavoriteEntry.normalizeUuid(uuid);
    if (!SppUuidFavoriteEntry.isPlausibleUuid(normalized)) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'Invalid UUID'));
    }
    if (this.contains(normalized)) {
      return this.remove(normalized).then((removed: Result<void>) => {
        if (!removed.success) {
          return Result.fail(removed.error ?? new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'persist failed'));
        }
        return Result.ok(false);
      });
    }
    const added = await this.add(normalized, label);
    if (!added.success) {
      return Result.fail(added.error ?? new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'add failed'));
    }
    return Result.ok(true);
  }

  async add(uuid: string, label: string = ''): Promise<Result<void>> {
    await this.ensureLoaded();
    const normalized = SppUuidFavoriteEntry.normalizeUuid(uuid);
    if (!SppUuidFavoriteEntry.isPlausibleUuid(normalized)) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'Invalid UUID'));
    }
    if (this.contains(normalized)) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'Duplicate UUID'));
    }
    if (this.entries.length >= SppUuidFavoriteDataSource.MAX_FAVORITES) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'Favorite limit reached'));
    }
    const resolvedLabel = label.trim().length > 0 ? label.trim() : SppUuidFavoriteEntry.shortUuid(normalized);
    const next: SppUuidFavoriteEntry[] = [
      new SppUuidFavoriteEntry(normalized, resolvedLabel, TimeUtil.nowMs())
    ];
    for (let i = 0; i < this.entries.length; i++) {
      next.push(this.entries[i]);
    }
    this.entries = next;
    return this.persist();
  }

  async update(uuid: string, nextUuid: string, label: string = ''): Promise<Result<void>> {
    await this.ensureLoaded();
    const current = SppUuidFavoriteEntry.normalizeUuid(uuid);
    const normalizedNext = SppUuidFavoriteEntry.normalizeUuid(nextUuid);
    if (!SppUuidFavoriteEntry.isPlausibleUuid(current) || !SppUuidFavoriteEntry.isPlausibleUuid(normalizedNext)) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'Invalid UUID'));
    }
    let index = -1;
    for (let i = 0; i < this.entries.length; i++) {
      if (this.entries[i].uuid === current) {
        index = i;
        break;
      }
    }
    if (index < 0) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'Favorite not found'));
    }
    if (normalizedNext !== current && this.contains(normalizedNext)) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'Duplicate UUID'));
    }
    const resolvedLabel = label.trim().length > 0 ? label.trim() : SppUuidFavoriteEntry.shortUuid(normalizedNext);
    const next: SppUuidFavoriteEntry[] = [];
    for (let i = 0; i < this.entries.length; i++) {
      if (i === index) {
        next.push(new SppUuidFavoriteEntry(normalizedNext, resolvedLabel, TimeUtil.nowMs()));
      } else {
        next.push(this.entries[i]);
      }
    }
    this.entries = next;
    return this.persist();
  }

  async remove(uuid: string): Promise<Result<void>> {
    await this.ensureLoaded();
    const normalized = SppUuidFavoriteEntry.normalizeUuid(uuid);
    if (normalized.length === 0) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'Invalid UUID'));
    }
    const next: SppUuidFavoriteEntry[] = [];
    let found = false;
    for (let i = 0; i < this.entries.length; i++) {
      if (this.entries[i].uuid === normalized) {
        found = true;
        continue;
      }
      next.push(this.entries[i]);
    }
    if (!found) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_INVALID_PARAMS, 'Favorite not found'));
    }
    this.entries = next;
    return this.persist();
  }

  private async hasFavoritesKey(): Promise<boolean> {
    // Seed only when key is absent. Empty list after user clears still has the key → no re-seed.
    return PreferencesStore.getInstance().hasKey(PreferenceKeys.BLUETOOTH_SPP_UUID_FAVORITES);
  }

  private async persist(): Promise<Result<void>> {
    const lines: string[] = [];
    for (let i = 0; i < this.entries.length; i++) {
      lines.push(this.entries[i].toLine());
    }
    return PreferencesStore.getInstance().putString(
      PreferenceKeys.BLUETOOTH_SPP_UUID_FAVORITES,
      lines.join('\n')
    );
  }

  private static parseLines(raw: string): SppUuidFavoriteEntry[] {
    if (raw.length === 0) {
      return [];
    }
    const lines = raw.split('\n');
    const next: SppUuidFavoriteEntry[] = [];
    for (let i = 0; i < lines.length; i++) {
      const item = SppUuidFavoriteEntry.fromLine(lines[i]);
      if (item !== undefined) {
        next.push(item);
      }
    }
    return next;
  }
}
