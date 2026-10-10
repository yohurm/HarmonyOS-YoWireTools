import { Result, AppThemeMode, AppThemeModeUtil } from 'common_core';
import { CapabilityRegistry, PlatformBootstrap, ThemeModeCoordinator } from 'common_platform';
import { StorageBootstrap } from 'common_storage';
import { LoadSettingsUseCase } from './usecase/SettingsUseCases';
import { common } from '@kit.AbilityKit';
import { YoLog, YoLogTag } from 'yolog';
import { CapabilityId } from './capability/CapabilityId';
import { SessionManager } from './service/SessionManager';

const logger = YoLog.tag(YoLogTag.APP);

/**
 * Initializes debug core layer after platform and storage bootstrap.
 */
export class DebugCoreBootstrap {
  static async initialize(context: common.UIAbilityContext): Promise<Result<void>> {
    PlatformBootstrap.initialize(context);
    CapabilityRegistry.getInstance().configureCatalog(CapabilityId.all());
    const storageResult = await StorageBootstrap.initialize(context);
    if (!storageResult.success) {
      return storageResult;
    }
    await DebugCoreBootstrap.applyPersistedTheme(context);
    SessionManager.getInstance().bindLifecycle();
    logger.info('debug_core_bootstrap successful');
    return Result.ok();
  }

  private static async applyPersistedTheme(context: common.UIAbilityContext): Promise<void> {
    const themeResult = await new LoadSettingsUseCase().execute();
    const raw = themeResult.success && themeResult.value !== undefined ? themeResult.value.themeMode : undefined;
    const themeMode = AppThemeModeUtil.parse(raw);
    ThemeModeCoordinator.apply(context, themeMode);
  }
}
