import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { PageQuery, PageResult, Result, ResultError } from 'common_core';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';
import { LogIndexRecord } from '../domain/LogIndexRecord';
import { LogQuery } from '../query/LogQuery';
import { DatabaseSchema } from '../rdb/DatabaseSchema';
import { RecordMapper } from '../rdb/RecordMapper';
import { RdbCountRunner } from '../rdb/RdbCountRunner';
import { RdbManager } from '../rdb/RdbManager';
import { RdbQueryRunner } from '../rdb/RdbQueryRunner';
import { RdbResultSetReader } from '../rdb/RdbResultSetReader';

/**
 * Single reader for table debug_log_index.
 */
export class LogIndexDataSource {
  static async list(query: LogQuery): Promise<Result<PageResult<LogIndexRecord>>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    let set: relationalStore.ResultSet | undefined;
    try {
      const predicates = LogIndexDataSource.buildPredicates(query);
      const counted = RdbCountRunner.countSync(store, predicates);
      if (!counted.success) {
        return Result.fail(counted.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Count failed'));
      }
      predicates.orderByDesc('timestamp_ms');
      predicates.limitAs(query.limit);
      predicates.offsetAs(query.offset);
      const queried = RdbQueryRunner.querySync(store, predicates);
      if (!queried.success || queried.value === undefined) {
        return Result.fail(queried.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Query failed'));
      }
      set = queried.value;
      const items: LogIndexRecord[] = [];
      if (set.rowCount > 0) {
        RdbResultSetReader.goToFirstRow(set);
        do {
          items.push(RecordMapper.logFromRow(set));
        } while (RdbResultSetReader.goToNextRow(set));
      }
      const total = counted.value ?? items.length;
      return Result.ok(new PageResult(items, total, new PageQuery(query.offset, query.limit)));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_READ_FAILED, err.message));
    } finally {
      if (set !== undefined) {
        RdbResultSetReader.closeQuietly(set);
      }
    }
  }

  private static buildPredicates(query: LogQuery): relationalStore.RdbPredicates {
    const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_LOG_INDEX);
    if (query.sessionId.length > 0) {
      predicates.equalTo('session_id', query.sessionId);
    }
    if (query.direction.length > 0) {
      predicates.equalTo('direction', query.direction);
    }
    if (query.recordType.length > 0) {
      predicates.equalTo('record_type', query.recordType);
    }
    if (query.startMs > 0) {
      predicates.greaterThanOrEqualTo('timestamp_ms', query.startMs);
    }
    if (query.endMs > 0) {
      predicates.lessThanOrEqualTo('timestamp_ms', query.endMs);
    }
    if (query.module.length > 0) {
      predicates.equalTo('module', query.module);
    }
    if (query.protocol.length > 0) {
      predicates.equalTo('protocol', query.protocol);
    }
    if (query.keyword.length > 0) {
      predicates.like('summary', `%${LogIndexDataSource.escapeLike(query.keyword)}%`);
    }
    return predicates;
  }

  private static escapeLike(raw: string): string {
    return raw.replace(/\\/g, '\\\\').replace(/%/g, '\\%').replace(/_/g, '\\_');
  }
}
