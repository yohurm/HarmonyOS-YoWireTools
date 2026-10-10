import { ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { deviceInfo } from '@kit.BasicServicesKit';
import { PlatformColorToken } from './PlatformColorToken';

/**
 * System bar colors for Window API (must be #AARRGGBB strings).
 * Values sourced from PlatformColorToken / common_platform color.json.
 */
export class SystemBarThemeCoordinator {
  /** Status/navigation bar icon color for the active color mode (#AARRGGBB). */
  static resolveContentColor(colorMode: number): string {
    const isDark = colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    return isDark ?
      PlatformColorToken.SYSTEM_BAR_CONTENT_DARK :
      PlatformColorToken.SYSTEM_BAR_CONTENT_LIGHT;
  }

  /**
   * Status bar content over hero/primary imagery (font_on_primary).
   * Used by HdsNavigation.systemBarStyle originalStyle in immersive图文 scenes.
   */
  static resolveOnPrimaryContentColor(): string {
    return PlatformColorToken.SYSTEM_BAR_CONTENT_DARK;
  }

  static resolveWindowBackgroundColor(colorMode: number): string {
    const isDark = colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK;
    return isDark ?
      PlatformColorToken.WINDOW_BACKGROUND_DARK :
      PlatformColorToken.WINDOW_BACKGROUND_LIGHT;
  }

  static buildProperties(colorMode: number): window.SystemBarProperties {
    const content = SystemBarThemeCoordinator.resolveContentColor(colorMode);
    return {
      statusBarColor: PlatformColorToken.SYSTEM_BAR_BACKGROUND,
      statusBarContentColor: content,
      navigationBarColor: PlatformColorToken.SYSTEM_BAR_BACKGROUND,
      navigationBarContentColor: content
    };
  }

  static applyToWindow(mainWindow: window.Window, colorMode: number): void {
    const deviceType = deviceInfo.deviceType;
    // Phone and tablet keep setWindowSystemBarProperties. It is unavailable on 2in1.
    if (deviceType === 'phone' || deviceType === 'tablet') {
      try {
        void mainWindow.setWindowSystemBarProperties(SystemBarThemeCoordinator.buildProperties(colorMode));
      } catch (_error) {
        // Window may not be ready during lifecycle transitions.
      }
    }
    // setWindowBackgroundColor is unavailable on phone, tablet, and 2in1.
    // This product covers those devices, so it is not called.
    // Phone system-bar colors stay on setWindowSystemBarProperties.
    // setWindowLayoutFullScreen is already applied by EntryAbility.
  }
}
