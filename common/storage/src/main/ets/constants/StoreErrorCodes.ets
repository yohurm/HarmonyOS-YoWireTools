/**
 * Storage error codes per 05-§7.5.
 */
export class StoreErrorCodes {
  static readonly RDB_OPEN_FAILED: string = 'YW-STORE-1001';
  static readonly RDB_WRITE_FAILED: string = 'YW-STORE-1002';
  static readonly RDB_READ_FAILED: string = 'YW-STORE-1003';
  static readonly FILE_WRITE_FAILED: string = 'YW-STORE-1004';
  static readonly FILE_READ_FAILED: string = 'YW-STORE-1005';
  static readonly EXPORT_FAILED: string = 'YW-EXPORT-1001';
  static readonly PREFERENCES_FAILED: string = 'YW-STORE-1006';
}
