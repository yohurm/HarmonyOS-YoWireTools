import { common, ConfigurationConstant } from '@kit.AbilityKit';

import { AppThemeMode } from 'common_core';



/**

 * Applies persisted or user-selected theme mode to the application context.

 */

export class ThemeModeCoordinator {

  static apply(context: common.UIAbilityContext, mode: AppThemeMode): void {

    try {

      const appContext = context.getApplicationContext();

      if (mode === AppThemeMode.LIGHT) {

        appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT);

        return;

      }

      if (mode === AppThemeMode.DARK) {

        appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_DARK);

        return;

      }

      appContext.setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);

    } catch (_error) {

      // Best-effort; UI tokens still follow system when apply fails.

    }

  }

}

