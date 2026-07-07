import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import {
  Result,
  ResultError,
  TaskExecutionPolicy,
  TaskExecutorRegistry,
  TaskSubmitOptions,
  TimeUtil
} from 'common_core';
import { AppSettingRecord } from '../domain/AppSettingRecord';
import { DatabaseSchema } from '../rdb/DatabaseSchema';
import { RdbManager } from '../rdb/RdbManager';
import { RdbQueryRunner } from '../rdb/RdbQueryRunner';
import { RdbResultSetReader } from '../rdb/RdbResultSetReader';
import { RdbWriteRunner } from '../rdb/RdbWriteRunner';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';

/**
 * Persistent app settings repository for features/settings module.
 */
export class AppSettingRepository {
  private static instance: AppSettingRepository | undefined;

  private constructor() {
  }

  static getInstance(): AppSettingRepository {
    if (AppSettingRepository.instance === undefined) {
      AppSettingRepository.instance = new AppSettingRepository();
    }
    return AppSettingRepository.instance;
  }

  async get(key: string): Promise<Result<string | undefined>> {
    return TaskExecutorRegistry.get().execute(async () => {
      const store = RdbManager.getInstance().getStore();
      if (store === undefined) {
        return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
      }
      const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_APP_SETTING);
      predicates.equalTo('key', key);
      const queried = RdbQueryRunner.querySync(store, predicates);
      if (!queried.success || queried.value === undefined) {
        return Result.fail(queried.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Query failed'));
      }
      const set = queried.value;
      try {
        if (set.rowCount === 0) {
          return Result.ok(undefined);
        }
        RdbResultSetReader.goToFirstRow(set);
        const valueIndex = set.getColumnIndex('value');
        return Result.ok(set.getString(valueIndex));
      } catch (error) {
        const err = error as BusinessError;
        return Result.fail(new ResultError(StoreErrorCodes.RDB_READ_FAILED, err.message));
      } finally {
        RdbResultSetReader.closeQuietly(set);
      }
    }, new TaskSubmitOptions(TaskExecutionPolicy.IO_BOUND, 'app_setting_get'));
  }

  async put(key: string, value: string): Promise<Result<void>> {
    return TaskExecutorRegistry.get().execute(async () => {
      const store = RdbManager.getInstance().getStore();
      if (store === undefined) {
        return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
      }
      const now = TimeUtil.nowMs();
      const bucket: relationalStore.ValuesBucket = {
        key: key,
        value: value,
        updated_at_ms: now
      };
      const existing = await this.get(key);
      if (existing.success && existing.value !== undefined) {
        try {
          const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_APP_SETTING);
          predicates.equalTo('key', key);
          await store.update(bucket, predicates);
          return Result.ok(undefined);
        } catch (error) {
          const err = error as BusinessError;
          return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, err.message));
        }
      }
      const inserted = await RdbWriteRunner.insert(store, DatabaseSchema.TABLE_APP_SETTING, bucket);
      if (!inserted.success) {
        return Result.fail(inserted.error ?? new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, 'Insert failed'));
      }
      return Result.ok(undefined);
    }, new TaskSubmitOptions(TaskExecutionPolicy.IO_BOUND, 'app_setting_put'));
  }

  async delete(key: string): Promise<Result<void>> {
    return TaskExecutorRegistry.get().execute(async () => {
      const store = RdbManager.getInstance().getStore();
      if (store === undefined) {
        return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
      }
      try {
        const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_APP_SETTING);
        predicates.equalTo('key', key);
        await store.delete(predicates);
        return Result.ok(undefined);
      } catch (error) {
        const err = error as BusinessError;
        return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, err.message));
      }
    }, new TaskSubmitOptions(TaskExecutionPolicy.IO_BOUND, 'app_setting_delete'));
  }

  async listAll(): Promise<Result<AppSettingRecord[]>> {
    return TaskExecutorRegistry.get().execute(async () => {
      const store = RdbManager.getInstance().getStore();
      if (store === undefined) {
        return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
      }
      const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_APP_SETTING);
      predicates.orderByAsc('key');
      const queried = RdbQueryRunner.querySync(store, predicates);
      if (!queried.success || queried.value === undefined) {
        return Result.fail(queried.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Query failed'));
      }
      const set = queried.value;
      const items: AppSettingRecord[] = [];
      try {
        if (set.rowCount > 0) {
          RdbResultSetReader.goToFirstRow(set);
          do {
            items.push(new AppSettingRecord(
              set.getString(set.getColumnIndex('key')),
              set.getString(set.getColumnIndex('value')),
              set.getLong(set.getColumnIndex('updated_at_ms'))
            ));
          } while (RdbResultSetReader.goToNextRow(set));
        }
        return Result.ok(items);
      } catch (error) {
        const err = error as BusinessError;
        return Result.fail(new ResultError(StoreErrorCodes.RDB_READ_FAILED, err.message));
      } finally {
        RdbResultSetReader.closeQuietly(set);
      }
    }, new TaskSubmitOptions(TaskExecutionPolicy.IO_BOUND, 'app_setting_list'));
  }
}
