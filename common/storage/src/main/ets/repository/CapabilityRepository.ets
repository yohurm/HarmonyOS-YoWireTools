import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { CapabilityResultRecord } from '../domain/CapabilityResultRecord';
import { DatabaseSchema } from '../rdb/DatabaseSchema';
import { RecordMapper } from '../rdb/RecordMapper';
import { RdbManager } from '../rdb/RdbManager';
import { RdbQueryRunner } from '../rdb/RdbQueryRunner';
import { RdbResultSetReader } from '../rdb/RdbResultSetReader';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';

/**
 * Capability probe persistence per 05-§4.5.
 */
export class CapabilityRepository {
  private static instance: CapabilityRepository | undefined;

  private constructor() {
  }

  static getInstance(): CapabilityRepository {
    if (CapabilityRepository.instance === undefined) {
      CapabilityRepository.instance = new CapabilityRepository();
    }
    return CapabilityRepository.instance;
  }

  async save(record: CapabilityResultRecord): Promise<Result<void>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    try {
      await store.insert(DatabaseSchema.TABLE_CAPABILITY_RESULT, {
        capability_id: record.capabilityId,
        module: record.module,
        status: record.status,
        reason: record.reason,
        required_permission: record.requiredPermission,
        api_level: record.apiLevel,
        native_code: record.nativeCode,
        verified_at_ms: record.verifiedAtMs
      });
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, err.message));
    }
  }

  async get(capabilityId: string): Promise<Result<CapabilityResultRecord | undefined>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_CAPABILITY_RESULT);
    predicates.equalTo('capability_id', capabilityId);
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
      return Result.ok(RecordMapper.capabilityFromRow(set));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.RDB_READ_FAILED, err.message));
    } finally {
      RdbResultSetReader.closeQuietly(set);
    }
  }

  async list(module: string = ''): Promise<Result<CapabilityResultRecord[]>> {
    const store = RdbManager.getInstance().getStore();
    if (store === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, 'Database not ready'));
    }
    const predicates = new relationalStore.RdbPredicates(DatabaseSchema.TABLE_CAPABILITY_RESULT);
    if (module.length > 0) {
      predicates.equalTo('module', module);
    }
    const queried = RdbQueryRunner.querySync(store, predicates);
    if (!queried.success || queried.value === undefined) {
      return Result.fail(queried.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'Query failed'));
    }
    const set = queried.value;
    try {
      const items: CapabilityResultRecord[] = [];
      if (set.rowCount > 0) {
        set.goToFirstRow();
        do {
          items.push(RecordMapper.capabilityFromRow(set));
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
