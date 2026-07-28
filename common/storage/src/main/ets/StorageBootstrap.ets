import { common } from '@kit.AbilityKit';
import { Result } from 'common_core';
import { YoLog, YoLogTag } from 'yolog';
import { LogRepository } from './repository/LogRepository';
import { PreferencesStore } from './preferences/PreferencesStore';
import { RdbManager } from './rdb/RdbManager';

const logger = YoLog.tag(YoLogTag.APP);

/**
 * Initializes storage layer from EntryAbility.onCreate.
 */
export class StorageBootstrap {
  static async initialize(context: common.Context): Promise<Result<void>> {
    const rdbResult = await RdbManager.getInstance().initialize(context);
    if (!rdbResult.success) {
      return rdbResult;
    }
    const prefResult = await PreferencesStore.getInstance().initialize(context);
    if (!prefResult.success) {
      return prefResult;
    }
    LogRepository.getInstance().bindContext(context);
    logger.info('storage_bootstrap successful');
    return Result.ok(undefined);
  }
}
