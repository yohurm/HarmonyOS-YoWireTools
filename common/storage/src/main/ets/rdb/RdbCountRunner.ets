import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';
import { RdbQueryRunner } from './RdbQueryRunner';
import { RdbResultSetReader } from './RdbResultSetReader';

/**
 * Count rows matching predicates without fetching full result sets.
 */
export class RdbCountRunner {
  static countSync(store: relationalStore.RdbStore, predicates: relationalStore.RdbPredicates): Result<number> {
    const queried = RdbQueryRunner.querySync(store, predicates);
    if (!queried.success || queried.value === undefined) {
      return Result.fail(queried.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Count failed'));
    }
    const set = queried.value;
    try {
      return Result.ok(set.rowCount);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_READ_FAILED, err.message));
    } finally {
      RdbResultSetReader.closeQuietly(set);
    }
  }
}
