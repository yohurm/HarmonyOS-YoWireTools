import { ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { PlatformColorToken } from './PlatformColorToken';

/**
 * System bar colors for Window API (must be #AARRGGBB strings).
 * Values sourced from PlatformColorToken / common_platform color.json.
 */
export class SystemBarThemeCoordinator {
  static buildProperties(colorMode: number): window.SystemBarProperties {
    const isDark = colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    const content = isDark ?
      PlatformColorToken.SYSTEM_BAR_CONTENT_DARK :
      PlatformColorToken.SYSTEM_BAR_CONTENT_LIGHT;
    return {
      statusBarColor: PlatformColorToken.SYSTEM_BAR_BACKGROUND,
      statusBarContentColor: content,
      navigationBarColor: PlatformColorToken.SYSTEM_BAR_BACKGROUND,
      navigationBarContentColor: content
    };
  }

  static applyToWindow(mainWindow: window.Window, colorMode: number): void {
    try {
      void mainWindow.setWindowSystemBarProperties(SystemBarThemeCoordinator.buildProperties(colorMode));
    } catch (_error) {
      // Window may not be ready during lifecycle transitions.
    }
  }
}
