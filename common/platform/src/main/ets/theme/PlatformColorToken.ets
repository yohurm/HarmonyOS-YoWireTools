/**
 * Platform semantic colors. Window API requires #AARRGGBB strings — values mirror
 * common_platform color.json and align with common_ui ui_text_primary (light/dark).
 */
export class PlatformColorToken {
  /** Transparent status/navigation bar — ui_system_bar_background. */
  static readonly SYSTEM_BAR_BACKGROUND: string = '#00000000';
  /** Window background aligned with common_ui ui_background in light mode. */
  static readonly WINDOW_BACKGROUND_LIGHT: string = '#FFF1F3F5';
  /** Window background aligned with common_ui ui_background in dark mode. */
  static readonly WINDOW_BACKGROUND_DARK: string = '#FF191A1C';
  /** Light mode bar content — ui_system_bar_content_light / ui_text_primary base. */
  static readonly SYSTEM_BAR_CONTENT_LIGHT: string = '#E5000000';
  /** Dark mode bar content — ui_system_bar_content_dark / ui_text_primary dark. */
  static readonly SYSTEM_BAR_CONTENT_DARK: string = '#E5FFFFFF';
}
