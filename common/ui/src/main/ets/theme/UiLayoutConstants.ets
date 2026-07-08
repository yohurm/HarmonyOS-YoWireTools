/**
 * Layout constants aligned with HarmonyOS design guide (navigation bar, tabs, grid).
 */
export class UiLayoutConstants {
  /** System navigation bar avoid height (vp). */
  static readonly NAV_BAR_AVOID: number = 28;
  /** Floating HdsTabs bar bottom margin (vp). */
  static readonly FLOATING_TAB_BAR_MARGIN: number = 28;
  /** Floating HdsTabs bar + bottom safe spacing for scroll content. */
  static readonly FLOATING_TAB_BOTTOM_PADDING: number = 88;
  /** Title bar height (vp). */
  static readonly TITLE_BAR_HEIGHT: number = 56;
  /** List card / device card height (vp). */
  static readonly LIST_CARD_HEIGHT: number = 72;
  /** Settings / efficiency list row (vp). */
  static readonly LIST_ROW_HEIGHT: number = 56;
  /** Minimum touch target (vp). UX must. */
  static readonly TOUCH_TARGET: number = 48;
  /** Card corner radius (vp) — V2 medium cards. */
  static readonly CARD_RADIUS: number = 16;
  /** V2 default card/surface radius. */
  static readonly CARD_RADIUS_SMALL: number = 8;
  /** Dialog max width (vp). */
  static readonly DIALOG_MAX_WIDTH: number = 400;
  /** Sheet max width on phone (vp). */
  static readonly SHEET_MAX_WIDTH: number = 480;
  /** DataTerminal minimum height (vp). */
  static readonly TERMINAL_MIN_HEIGHT: number = 120;
  /** CommandDock inner padding (vp). */
  static readonly COMMAND_DOCK_PADDING: number = 16;
  /** TX/RX direction label column width in DataTerminal (vp). */
  static readonly TERMINAL_DIRECTION_WIDTH: number = 28;
  /** Trailing chevron glyph size in select/list rows (vp). */
  static readonly CHEVRON_GLYPH_SIZE: number = 16;
  /** Disabled button opacity (Material disabled emphasis). */
  static readonly DISABLED_BUTTON_OPACITY: number = 0.38;
  /** Disabled list/select row opacity. */
  static readonly DISABLED_ROW_OPACITY: number = 0.4;
  /** Selected card border width (vp). */
  static readonly SELECTED_BORDER_WIDTH: number = 1;
  /** Pill/chip corner radius (vp). */
  static readonly CHIP_PILL_RADIUS: number = 20;
  /** Log row direction/time column width (vp). */
  static readonly LOG_ROW_DIRECTION_WIDTH: number = 52;
}
