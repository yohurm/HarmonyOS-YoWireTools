/**
 * Responsive breakpoints aligned with HarmonyOS design guide and V2 layout spec.
 */
export class YoBreakpointUtil {
  static readonly SPLIT_MIN_VP: number = 600;
  static readonly SIDE_NAV_MIN_VP: number = 840;
  static readonly WIDE_INSPECTOR_MIN_VP: number = 1200;

  static isCompact(widthVp: number): boolean {
    return widthVp < YoBreakpointUtil.SPLIT_MIN_VP;
  }

  static isMedium(widthVp: number): boolean {
    return widthVp >= YoBreakpointUtil.SPLIT_MIN_VP && widthVp < YoBreakpointUtil.SIDE_NAV_MIN_VP;
  }

  static isExpanded(widthVp: number): boolean {
    return widthVp >= YoBreakpointUtil.SIDE_NAV_MIN_VP;
  }

  static pagePadding(widthVp: number): number {
    if (YoBreakpointUtil.isExpanded(widthVp)) {
      return 32;
    }
    if (YoBreakpointUtil.isMedium(widthVp)) {
      return 24;
    }
    return 16;
  }

  static shouldUseSideNavigation(widthVp: number): boolean {
    return YoBreakpointUtil.isExpanded(widthVp);
  }
}
