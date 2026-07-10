/**
 * Global appearance preference for V2 ThemeModeSelect.
 */

export enum AppThemeMode {
  SYSTEM = 'system',
  LIGHT = 'light',
  DARK = 'dark'
}

/**
 * Display labels/subtitles for theme modes live in common_ui resources
 * (ui_theme_system, ui_theme_light, ui_theme_dark and *_subtitle variants).
 * Do not add hardcoded user-visible strings here.
 */
export class AppThemeModeUtil {
  static parse(raw: string | undefined): AppThemeMode {
    if (raw === AppThemeMode.LIGHT) {
      return AppThemeMode.LIGHT;
    }
    if (raw === AppThemeMode.DARK) {
      return AppThemeMode.DARK;
    }
    return AppThemeMode.SYSTEM;
  }

  static all(): AppThemeMode[] {
    return [AppThemeMode.SYSTEM, AppThemeMode.LIGHT, AppThemeMode.DARK];
  }
}
