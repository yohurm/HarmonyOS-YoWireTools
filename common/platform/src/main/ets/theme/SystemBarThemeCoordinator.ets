import { ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';

/**
 * System bar colors for Window API (must be #AARRGGBB strings).
 * Values align with common_ui color.json ui_text_primary (light/dark).
 */
export class SystemBarThemeCoordinator {
  /** Transparent status/navigation bar — ui_system_bar_background semantic. */
  private static readonly BAR_BACKGROUND: string = '#00000000';
  /** Light mode content — matches base ui_text_primary (#E5000000). */
  private static readonly CONTENT_LIGHT: string = '#E5000000';
  /** Dark mode content — matches dark ui_text_primary (#E5FFFFFF). */
  private static readonly CONTENT_DARK: string = '#E5FFFFFF';

  static buildProperties(colorMode: number): window.SystemBarProperties {
    const isDark = colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    const content = isDark ?
      SystemBarThemeCoordinator.CONTENT_DARK :
      SystemBarThemeCoordinator.CONTENT_LIGHT;
    return {
      statusBarColor: SystemBarThemeCoordinator.BAR_BACKGROUND,
      statusBarContentColor: content,
      navigationBarColor: SystemBarThemeCoordinator.BAR_BACKGROUND,
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
