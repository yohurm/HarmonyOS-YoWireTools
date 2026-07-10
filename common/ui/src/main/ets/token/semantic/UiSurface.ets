import { WindowWidthBreakpoint } from 'common_platform';
import { UiSpace } from '../foundation/UiSpace';

/**
 * Semantic spacing tokens with responsive page padding.
 */
export class UiSurface {
  static pageHorizontal(breakpoint: WindowWidthBreakpoint): number {
    if (breakpoint === WindowWidthBreakpoint.EXPANDED || breakpoint === WindowWidthBreakpoint.XL) {
      return UiSpace.XXXL;
    }
    if (breakpoint === WindowWidthBreakpoint.MEDIUM) {
      return UiSpace.XXL;
    }
    return UiSpace.XL;
  }

  static readonly SECTION_GAP: number = UiSpace.XL;
  static readonly CARD_GAP: number = UiSpace.L;
  static readonly CONTROL_GAP: number = UiSpace.M;
  static readonly LABEL_STACK_GAP: number = UiSpace.XXS;
  static readonly CARD_CONTENT_PADDING: number = UiSpace.XL;
  static readonly DIALOG_CONTENT_PADDING: number = UiSpace.XXL;
}
