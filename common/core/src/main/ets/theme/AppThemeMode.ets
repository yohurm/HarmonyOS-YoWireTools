/**

 * Global appearance preference for V2 ThemeModeSelect.

 */

export enum AppThemeMode {

  SYSTEM = 'system',

  LIGHT = 'light',

  DARK = 'dark'

}



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



  static label(mode: AppThemeMode): string {

    if (mode === AppThemeMode.LIGHT) {

      return '浅色模式';

    }

    if (mode === AppThemeMode.DARK) {

      return '深色模式';

    }

    return '跟随系统';

  }



  static subtitle(mode: AppThemeMode): string {

    if (mode === AppThemeMode.LIGHT) {

      return '强制使用浅色 Token，适合日间配置';

    }

    if (mode === AppThemeMode.DARK) {

      return '强制使用深色 Token，适合终端与夜间调试';

    }

    return '读取系统浅色/深色设置并实时更新';

  }



  static all(): AppThemeMode[] {

    return [AppThemeMode.SYSTEM, AppThemeMode.LIGHT, AppThemeMode.DARK];

  }

}

