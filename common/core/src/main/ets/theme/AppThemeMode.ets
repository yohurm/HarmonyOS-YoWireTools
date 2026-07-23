/**
 * Global appearance preference.
 */

export enum AppThemeMode {
  SYSTEM = 'system',
  LIGHT = 'light',
  DARK = 'dark'
}

/**
 * Theme mode labels belong in product/entry resources when a settings UI is present.
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
