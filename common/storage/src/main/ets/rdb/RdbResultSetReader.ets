import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';

/**
 * Centralizes ResultSet access with explicit try/catch per ArkTS throw-site rules.
 */
export class RdbResultSetReader {
  static readString(set: relationalStore.ResultSet, column: string): string {
    try {
      return set.getString(set.getColumnIndex(column));
    } catch (error) {
      throw RdbResultSetReader.toReadError(error, column);
    }
  }

  static readLong(set: relationalStore.ResultSet, column: string): number {
    try {
      return set.getLong(set.getColumnIndex(column));
    } catch (error) {
      throw RdbResultSetReader.toReadError(error, column);
    }
  }

  static goToFirstRow(set: relationalStore.ResultSet): boolean {
    try {
      return set.goToFirstRow();
    } catch (error) {
      throw RdbResultSetReader.toReadError(error, 'cursor');
    }
  }

  static goToNextRow(set: relationalStore.ResultSet): boolean {
    try {
      return set.goToNextRow();
    } catch (error) {
      throw RdbResultSetReader.toReadError(error, 'cursor');
    }
  }

  static closeQuietly(set: relationalStore.ResultSet | undefined): void {
    if (set === undefined) {
      return;
    }
    try {
      set.close();
    } catch (_error) {
      // Best-effort close on read/query paths.
    }
  }

  private static toReadError(error: Object, column: string): Error {
    const err = error as BusinessError;
    return new Error(`${StoreErrorCodes.RDB_READ_FAILED}:${column}:${err.message}`);
  }
}
