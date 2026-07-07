import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';

/**
 * Wraps RDB querySync with explicit exception handling at the throw site.
 */
export class RdbQueryRunner {
  static querySync(
    store: relationalStore.RdbStore,
    predicates: relationalStore.RdbPredicates
  ): Result<relationalStore.ResultSet> {
    try {
      return Result.ok(store.querySync(predicates));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_READ_FAILED, err.message));
    }
  }
}
