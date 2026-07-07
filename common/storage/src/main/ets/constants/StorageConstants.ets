/**
 * Storage layer constants.
 */
export class StorageConstants {
  static readonly DB_NAME: string = 'yowire_debug.db';
  static readonly DB_VERSION: number = 1;
  static readonly PREFERENCES_NAME: string = 'yowire_settings';
  static readonly INLINE_PAYLOAD_THRESHOLD_BYTES: number = 4096;
  static readonly PAYLOAD_CHUNK_MAX_BYTES: number = 1024 * 1024;
  static readonly DEFAULT_RETENTION_DAYS: number = 30;
  static readonly DEFAULT_MAX_SIZE_MB: number = 512;
}
