import { WindowWidthBreakpoint } from 'common_platform';
import { YoSpace } from '../foundation/YoSpace';

/**
 * 响应式语义间距与布局 Token。
 */
export class YoResponsive {
  static pageHorizontal(breakpoint: WindowWidthBreakpoint): number {
    if (breakpoint === WindowWidthBreakpoint.EXPANDED || breakpoint === WindowWidthBreakpoint.XL) {
      return YoSpace.XXXL;
    }
    if (breakpoint === WindowWidthBreakpoint.MEDIUM) {
      return YoSpace.XXL;
    }
    return YoSpace.XL;
  }

  static readonly SECTION_GAP: number = YoSpace.XL;
  static readonly CARD_GAP: number = YoSpace.L;
  static readonly CONTROL_GAP: number = YoSpace.M;
  static readonly LABEL_STACK_GAP: number = YoSpace.XXS;
  static readonly CARD_CONTENT_PADDING: number = YoSpace.XL;
  static readonly DIALOG_CONTENT_PADDING: number = YoSpace.XXL;
  static readonly FORM_GAP: number = YoSpace.XL;
  static readonly CONTENT_MAX_WIDTH: number = 2220;
}
