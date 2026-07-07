/**
 * App setting row per DatabaseSchema TABLE_APP_SETTING.
 */
export class AppSettingRecord {
  readonly key: string;
  readonly value: string;
  readonly updatedAtMs: number;

  constructor(key: string, value: string, updatedAtMs: number) {
    this.key = key;
    this.value = value;
    this.updatedAtMs = updatedAtMs;
  }
}
