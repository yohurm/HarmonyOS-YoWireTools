import { Result, AppThemeMode, AppThemeModeUtil } from 'common_core';
import { CapabilityRegistry, PlatformBootstrap, ThemeModeCoordinator } from 'common_platform';
import { AppSettingRepository, PreferenceKeys, StorageBootstrap } from 'common_storage';
import { common } from '@kit.AbilityKit';
import { AppLogger, AppLogTag } from 'common_platform';
import { CapabilityId } from './capability/CapabilityId';
import { SessionManager } from './service/SessionManager';

const logger = new AppLogger(AppLogTag.APP);

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
    const themeResult = await AppSettingRepository.getInstance().get(PreferenceKeys.THEME_MODE);
    const themeMode = AppThemeModeUtil.parse(themeResult.success ? themeResult.value : undefined);
    ThemeModeCoordinator.apply(context, themeMode);
  }
}
