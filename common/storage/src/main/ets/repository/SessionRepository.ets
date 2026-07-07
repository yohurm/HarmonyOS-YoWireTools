import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { PageQuery, PageResult, Result, ResultError } from 'common_core';
import { SessionRecord } from '../domain/SessionRecord';
import { DatabaseSchema } from '../rdb/DatabaseSchema';
import { RecordMapper } from '../rdb/RecordMapper';
import { RdbManager } from '../rdb/RdbManager';
import { RdbQueryRunner } from '../rdb/RdbQueryRunner';
import { RdbCountRunner } from '../rdb/RdbCountRunner';
import { RdbResultSetReader } from '../rdb/RdbResultSetReader';
import { SessionQuery } from '../query/SessionQuery';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';

/**
 * Session index repository per 05-§4.1.
 */
export class SessionRepository {
  private static instance: SessionRepository | undefined;

  private constructor() {
  }

  static getInstance(): SessionRepository {
    if (SessionRepository.instance === undefined) {
      SessionRepository.instance = new SessionRepository();
    }
    return SessionRepository.instance;
  }

  async create(record: SessionRecord): Promise<Result<void>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    try {
      await store.insert(DatabaseSchema.TABLE_SESSION, RecordMapper.sessionToBucket(record));
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, err.message));
    }
  }

  async update(record: SessionRecord): Promise<Result<void>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_SESSION);
      predicates.equalTo('id', record.id);
      await store.update(RecordMapper.sessionToBucket(record), predicates);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, err.message));
    }
  }

  async get(id: string): Promise<Result<SessionRecord | undefined>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_SESSION);
    predicates.equalTo('id', id);
    const queried = RdbQueryRunner.querySync(store, predicates);
    if (!queried.success || queried.value === undefined) {
      return Result.fail(queried.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Query failed'));
    }
    const set = queried.value;
    try {
      if (set.rowCount === 0) {
        return Result.ok(undefined);
      }
      set.goToFirstRow();
      return Result.ok(RecordMapper.sessionFromRow(set));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_READ_FAILED, err.message));
    } finally {
      RdbResultSetReader.closeQuietly(set);
    }
  }

  async list(query: SessionQuery): Promise<Result<PageResult<SessionRecord>>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    const countPredicates = SessionRepository.buildListPredicates(query);
    const counted = RdbCountRunner.countSync(store, countPredicates);
    if (!counted.success) {
      return Result.fail(counted.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Count failed'));
    }
    const predicates = SessionRepository.buildListPredicates(query);
    predicates.orderByDesc('start_at_ms');
    predicates.limitAs(query.limit);
    predicates.offsetAs(query.offset);
    const queried = RdbQueryRunner.querySync(store, predicates);
    if (!queried.success || queried.value === undefined) {
      return Result.fail(queried.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Query failed'));
    }
    const set = queried.value;
    try {
      const items: SessionRecord[] = [];
      if (set.rowCount > 0) {
        RdbResultSetReader.goToFirstRow(set);
        do {
          items.push(RecordMapper.sessionFromRow(set));
        } while (RdbResultSetReader.goToNextRow(set));
      }
      const pageQuery = new PageQuery(query.offset, query.limit);
      return Result.ok(new PageResult(items, counted.value ?? 0, pageQuery));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_READ_FAILED, err.message));
    } finally {
      RdbResultSetReader.closeQuietly(set);
    }
  }

  private static buildListPredicates(query: SessionQuery): relationalStore.RdbPredicates {
    const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_SESSION);
    if (query.module.length > 0) {
      predicates.equalTo('module', query.module);
    }
    if (query.state.length > 0) {
      predicates.equalTo('state', query.state);
    }
    return predicates;
  }

  async close(id: string, resultJson: string): Promise<Result<void>> {
    const existing = await this.get(id);
    if (!existing.success || existing.value === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Session not found'));
    }
    const closed = new SessionRecord(
      existing.value.id,
      existing.value.type,
      existing.value.module,
      existing.value.protocol,
      existing.value.targetId,
      existing.value.displayName,
      'COMPLETED',
      existing.value.startAtMs,
      Date.now(),
      resultJson,
      existing.value.errorJson,
      existing.value.attributesJson
    );
    return this.update(closed);
  }
}
