import { common } from '@kit.AbilityKit';
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { AppLogger, AppLogTag } from 'common_platform';
import { StorageConstants } from '../constants/StorageConstants';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';
import { DatabaseSchema } from './DatabaseSchema';
import { RdbSqlRunner } from './RdbSqlRunner';

const logger = new AppLogger(AppLogTag.APP);

/**
 * RDB lifecycle manager: open, migrate, expose store.
 */
export class RdbManager {
  private static instance: RdbManager | undefined;
  private store: relationalStore.RdbStore | undefined;
  private context: common.Context | undefined;

  private constructor() {
  }

  static getInstance(): RdbManager {
    if (RdbManager.instance === undefined) {
      RdbManager.instance = new RdbManager();
    }
    return RdbManager.instance;
  }

  async initialize(context: common.Context): Promise<Result<void>> {
    this.context = context;
    try {
      const config: relationalStore.StoreConfig = {
        name: StorageConstants.DB_NAME,
        securityLevel: relationalStore.SecurityLevel.S3
      };
      this.store = await relationalStore.getRdbStore(context, config);
      const migrationResult = await this.runMigrations();
      if (!migrationResult.success) {
        return migrationResult;
      }
      logger.info('rdb_initialize successful');
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      logger.error(`rdb_initialize failed, code=${err.code}, message=${err.message}`);
      return Result.fail(new ResultError(StoreErrorCodes.RDB_OPEN_FAILED, err.message));
    }
  }

  getStore(): relationalStore.RdbStore | undefined {
    return this.store;
  }

  isReady(): boolean {
    return this.store !== undefined;
  }

  private async runMigrations(): Promise<Result<void>> {
    if (this.store === undefined) {
      return Result.ok(undefined);
    }
    return RdbSqlRunner.executeAll(this.store, DatabaseSchema.migrationStatements());
  }
}
