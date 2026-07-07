import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';

/**
 * Executes RDB SQL with explicit exception handling at the throw site.
 */
export class RdbSqlRunner {
  static async executeAll(store: relationalStore.RdbStore, statements: string[]): Promise<Result<void>> {
    for (let i = 0; i < statements.length; i++) {
      const executed = await RdbSqlRunner.executeOne(store, statements[i]);
      if (!executed.success) {
        return executed;
      }
    }
    return Result.ok(undefined);
  }

  static async executeOne(store: relationalStore.RdbStore, sql: string): Promise<Result<void>> {
    try {
      await store.executeSql(sql);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, err.message));
    }
  }
}
