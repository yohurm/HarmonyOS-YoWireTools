/**
 * Window-width breakpoints per HarmonyOS responsive design guide:
 * COMPACT <600vp, MEDIUM 600–839vp, EXPANDED 840–1439vp, XL >=1440vp.
 */
export enum WindowWidthBreakpoint {
  COMPACT = 'compact',
  MEDIUM = 'medium',
  EXPANDED = 'expanded',
  XL = 'xl'
}

export class WindowWidthBreakpointUtil {
  static readonly MEDIUM_MIN_VP: number = 600;
  static readonly EXPANDED_MIN_VP: number = 840;
  static readonly XL_MIN_VP: number = 1440;

  static resolve(widthVp: number): WindowWidthBreakpoint {
    if (widthVp >= WindowWidthBreakpointUtil.XL_MIN_VP) {
      return WindowWidthBreakpoint.XL;
    }
    if (widthVp >= WindowWidthBreakpointUtil.EXPANDED_MIN_VP) {
      return WindowWidthBreakpoint.EXPANDED;
    }
    if (widthVp >= WindowWidthBreakpointUtil.MEDIUM_MIN_VP) {
      return WindowWidthBreakpoint.MEDIUM;
    }
    return WindowWidthBreakpoint.COMPACT;
  }

  /** >=600vp: list + detail split (分栏布局). */
  static isSplitCapable(breakpoint: WindowWidthBreakpoint): boolean {
    return breakpoint !== WindowWidthBreakpoint.COMPACT;
  }

  /** >=840vp: side navigation replaces bottom tabs (响应式应用架构). */
  static isSideNavCapable(breakpoint: WindowWidthBreakpoint): boolean {
    return breakpoint === WindowWidthBreakpoint.EXPANDED || breakpoint === WindowWidthBreakpoint.XL;
  }

  static usesBottomTabShell(breakpoint: WindowWidthBreakpoint): boolean {
    return !WindowWidthBreakpointUtil.isSideNavCapable(breakpoint);
  }

  /** Compact 16vp / Medium 24vp / Expanded+ 32vp — aligned with UiResponsive.pageHorizontal. */
  static pagePaddingVp(breakpoint: WindowWidthBreakpoint): number {
    if (breakpoint === WindowWidthBreakpoint.EXPANDED || breakpoint === WindowWidthBreakpoint.XL) {
      return 32;
    }
    if (breakpoint === WindowWidthBreakpoint.MEDIUM) {
      return 24;
    }
    return 16;
  }

  /** >=600vp: centered sheet; <600vp: bottom sheet. */
  static usesCenterSheet(breakpoint: WindowWidthBreakpoint): boolean {
    return WindowWidthBreakpointUtil.isSplitCapable(breakpoint);
  }
}
