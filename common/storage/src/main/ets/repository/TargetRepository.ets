import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { DeviceFavoriteRecord } from '../domain/DeviceFavoriteRecord';
import { DatabaseSchema } from '../rdb/DatabaseSchema';
import { RecordMapper } from '../rdb/RecordMapper';
import { RdbManager } from '../rdb/RdbManager';
import { RdbQueryRunner } from '../rdb/RdbQueryRunner';
import { RdbResultSetReader } from '../rdb/RdbResultSetReader';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';

/**
 * Device favorite repository per 05-§4.4.
 */
export class TargetRepository {
  private static instance: TargetRepository | undefined;

  private constructor() {
  }

  static getInstance(): TargetRepository {
    if (TargetRepository.instance === undefined) {
      TargetRepository.instance = new TargetRepository();
    }
    return TargetRepository.instance;
  }

  async saveFavorite(record: DeviceFavoriteRecord): Promise<Result<void>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    try {
      await store.insert(DatabaseSchema.TABLE_DEVICE_FAVORITE, {
        id: record.id,
        module: record.module,
        protocol: record.protocol,
        display_name: record.displayName,
        alias: record.alias,
        address: record.address,
        address_type: record.addressType,
        host: record.host,
        port: record.port,
        uuid: record.uuid,
        attributes: record.attributesJson,
        updated_at_ms: record.updatedAtMs
      });
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, err.message));
    }
  }

  async removeFavorite(id: string): Promise<Result<void>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    try {
      const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_DEVICE_FAVORITE);
      predicates.equalTo('id', id);
      await store.delete(predicates);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, err.message));
    }
  }

  async listFavorites(module: string = ''): Promise<Result<DeviceFavoriteRecord[]>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_DEVICE_FAVORITE);
    if (module.length > 0) {
      predicates.equalTo('module', module);
    }
    predicates.orderByDesc('updated_at_ms');
    const queried = RdbQueryRunner.querySync(store, predicates);
    if (!queried.success || queried.value === undefined) {
      return Result.fail(queried.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Query failed'));
    }
    const set = queried.value;
    try {
      const items: DeviceFavoriteRecord[] = [];
      if (set.rowCount > 0) {
        set.goToFirstRow();
        do {
          items.push(RecordMapper.deviceFavoriteFromRow(set));
        } while (set.goToNextRow());
      }
      return Result.ok(items);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_READ_FAILED, err.message));
    } finally {
      RdbResultSetReader.closeQuietly(set);
    }
  }
}
