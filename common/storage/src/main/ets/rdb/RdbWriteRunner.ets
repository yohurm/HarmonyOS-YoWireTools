import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';

/**
 * Wraps RDB write operations with explicit exception handling at the throw site.
 */
export class RdbWriteRunner {
  static async insert(
    store: relationalStore.RdbStore,
    table: string,
    values: relationalStore.ValuesBucket
  ): Promise<Result<number>> {
    try {
      const rowId = await store.insert(table, values);
      return Result.ok(rowId);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, err.message));
    }
  }
}
