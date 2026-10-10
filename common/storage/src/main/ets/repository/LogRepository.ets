import { common } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { AsyncSerialQueue, PageQuery, PageResult, Result, ResultError, TimeUtil } from 'common_core';
import { CleanupResult } from '../cleanup/CleanupResult';
import { LogCleanupPolicy } from '../cleanup/LogCleanupPolicy';
import { LogIndexRecord } from '../domain/LogIndexRecord';
import { PayloadChunkRecord } from '../domain/PayloadChunkRecord';
import { StoragePayloadRef } from '../domain/StoragePayloadRef';
import { PayloadChunkWriter } from '../file/PayloadChunkWriter';
import { PayloadFileDeleter } from '../file/PayloadFileDeleter';
import { PayloadFileReader } from '../file/PayloadFileReader';
import { LogQuery } from '../query/LogQuery';
import { LogIndexDataSource } from '../datasource/LogIndexDataSource';
import { DatabaseSchema } from '../rdb/DatabaseSchema';
import { RecordMapper } from '../rdb/RecordMapper';
import { RdbManager } from '../rdb/RdbManager';
import { RdbQueryRunner } from '../rdb/RdbQueryRunner';
import { RdbCountRunner } from '../rdb/RdbCountRunner';
import { RdbResultSetReader } from '../rdb/RdbResultSetReader';
import { RdbWriteRunner } from '../rdb/RdbWriteRunner';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';

/**
 * Log index + payload repository per 05-§4.2.
 */
export class LogRepository {
  private static instance: LogRepository | undefined;
  private readonly writeQueue: AsyncSerialQueue = new AsyncSerialQueue();
  private context: common.Context | undefined;
  private chunkWriter: PayloadChunkWriter | undefined;
  private payloadReader: PayloadFileReader = new PayloadFileReader();

  private constructor() {
  }

  static getInstance(): LogRepository {
    if (LogRepository.instance === undefined) {
      LogRepository.instance = new LogRepository();
    }
    return LogRepository.instance;
  }

  bindContext(context: common.Context): void {
    this.context = context;
    this.chunkWriter = new PayloadChunkWriter(context);
  }

  async append(record: LogIndexRecord, payload?: Uint8Array): Promise<Result<void>> {
    return this.writeQueue.enqueue(async () => {
      return this.appendInternal(record, payload);
    });
  }

  async list(query: LogQuery): Promise<Result<PageResult<LogIndexRecord>>> {
    return LogIndexDataSource.list(query);
  }

  async getPayload(ref: StoragePayloadRef): Promise<Result<Uint8Array>> {
    return this.payloadReader.read(ref);
  }

  async deleteBySession(sessionId: string): Promise<Result<void>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    try {
      const logs = await this.listAllForSession(store, sessionId);
      const chunks = LogRepository.listChunksForSession(store, sessionId);
      let freedBytes = 0;
      for (let i = 0; i < logs.length; i++) {
        freedBytes += PayloadFileDeleter.deleteRef(logs[i].payloadRef);
      }
      for (let i = 0; i < chunks.length; i++) {
        freedBytes += PayloadFileDeleter.deleteChunk(chunks[i]);
      }
      const logPredicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_LOG_INDEX);
      logPredicates.equalTo('session_id', sessionId);
      await store.delete(logPredicates);
      const chunkPredicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_PAYLOAD_CHUNK);
      chunkPredicates.equalTo('session_id', sessionId);
      await store.delete(chunkPredicates);
      return Result.ok();
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, err.message));
    }
  }

  async cleanup(policy: LogCleanupPolicy): Promise<Result<CleanupResult>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    try {
      const cutoffMs = policy.beforeTimestampMs > 0 ?
        policy.beforeTimestampMs :
        TimeUtil.nowMs() - policy.retentionDays * 24 * 60 * 60 * 1000;
      const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_LOG_INDEX);
      predicates.lessThan('timestamp_ms', cutoffMs);
      const staleLogs = LogRepository.queryLogs(store, predicates);
      let deletedFiles = 0;
      let freedBytes = 0;
      for (let i = 0; i < staleLogs.length; i++) {
        const bytes = PayloadFileDeleter.deleteRef(staleLogs[i].payloadRef);
        if (bytes > 0) {
          deletedFiles++;
          freedBytes += bytes;
        }
      }
      const deletedLogs = await store.delete(predicates);
      return Result.ok(new CleanupResult(deletedLogs, deletedFiles, freedBytes));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, err.message));
    }
  }

  private async appendInternal(record: LogIndexRecord, payload?: Uint8Array): Promise<Result<void>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    let finalRecord = record;
    if (payload !== undefined && payload.length > 0 && this.chunkWriter !== undefined) {
      const stored = await this.chunkWriter.store(record.sessionId, payload);
      if (!stored.success) {
        return Result.fail(stored.error ?? new ResultError(StoreErrorCodes.FILE_WRITE_FAILED, 'Payload store failed'));
      }
      const storeResult = stored.getOrThrow();
      if (storeResult.chunkRecord !== undefined) {
        const chunkInsert = await RdbWriteRunner.insert(
          store,
          DatabaseSchema.TABLE_PAYLOAD_CHUNK,
          RecordMapper.chunkToBucket(storeResult.chunkRecord)
        );
        if (!chunkInsert.success) {
          return Result.fail(chunkInsert.error ??
            new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, 'Chunk insert failed'));
        }
      }
      finalRecord = new LogIndexRecord(
        record.id,
        record.sessionId,
        record.module,
        record.protocol,
        record.direction,
        record.recordType,
        record.timestampMs,
        payload.length,
        record.summary,
        record.displayHint,
        storeResult.payloadRef,
        record.appCode,
        record.nativeCode,
        record.attributesJson
      );
    }
    const logInsert = await RdbWriteRunner.insert(
      store,
      DatabaseSchema.TABLE_LOG_INDEX,
      RecordMapper.logToBucket(finalRecord)
    );
    if (!logInsert.success) {
      return Result.fail(logInsert.error ??
        new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, 'Log insert failed'));
    }
    return Result.ok();
  }

  private async listAllForSession(store: relationalStore.RdbStore, sessionId: string): Promise<LogIndexRecord[]> {
    const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_LOG_INDEX);
    predicates.equalTo('session_id', sessionId);
    return LogRepository.queryLogs(store, predicates);
  }

  private static countMatching(store: relationalStore.RdbStore, predicates: relationalStore.RdbPredicates): number {
    const counted = RdbCountRunner.countSync(store, predicates);
    if (!counted.success) {
      return 0;
    }
    return counted.value ?? 0;
  }

  private static queryLogs(store: relationalStore.RdbStore, predicates: relationalStore.RdbPredicates): LogIndexRecord[] {
    const queried = RdbQueryRunner.querySync(store, predicates);
    if (!queried.success || queried.value === undefined) {
      return [];
    }
    const set = queried.value;
    const items: LogIndexRecord[] = [];
    try {
      if (set.rowCount > 0) {
        RdbResultSetReader.goToFirstRow(set);
        do {
          items.push(RecordMapper.logFromRow(set));
        } while (RdbResultSetReader.goToNextRow(set));
      }
      return items;
    } catch (_error) {
      return [];
    } finally {
      RdbResultSetReader.closeQuietly(set);
    }
  }

  private static listChunksForSession(store: relationalStore.RdbStore, sessionId: string): PayloadChunkRecord[] {
    const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_PAYLOAD_CHUNK);
    predicates.equalTo('session_id', sessionId);
    const queried = RdbQueryRunner.querySync(store, predicates);
    if (!queried.success || queried.value === undefined) {
      return [];
    }
    const set = queried.value;
    const items: PayloadChunkRecord[] = [];
    try {
      if (set.rowCount > 0) {
        RdbResultSetReader.goToFirstRow(set);
        do {
          items.push(RecordMapper.chunkFromRow(set));
        } while (RdbResultSetReader.goToNextRow(set));
      }
      return items;
    } catch (_error) {
      return [];
    } finally {
      RdbResultSetReader.closeQuietly(set);
    }
  }
}
