import { WindowWidthBreakpoint } from 'common_platform';
import { UiSpace } from '../foundation/UiSpace';
import { UiResponsive } from '../semantic/UiResponsive';

/**
 * Page layout tokens — single entry for shell / feature page composition.
 *
 * Layering:
 * 1. UiSpace     — raw spacing scale
 * 2. UiResponsive — breakpoint-aware semantics
 * 3. PageLayoutToken — page skeleton (padding / section / list chrome)
 *
 * Pages should prefer PageLayoutToken + CardToken over raw numbers.
 */
export class PageLayoutToken {
  static pageHorizontalPadding(breakpoint: WindowWidthBreakpoint): number {
    return UiResponsive.pageHorizontal(breakpoint);
  }

  static readonly SECTION_GAP: number = UiResponsive.SECTION_GAP;
  static readonly CARD_GAP: number = UiResponsive.CARD_GAP;
  static readonly CONTROL_GAP: number = UiResponsive.CONTROL_GAP;
  static readonly LABEL_STACK_GAP: number = UiResponsive.LABEL_STACK_GAP;
  static readonly CONTENT_MAX_WIDTH: number = UiResponsive.CONTENT_MAX_WIDTH;
  /** Edge inset between page padding and list cards. */
  static readonly LIST_EDGE_INSET: number = UiSpace.NONE;
}
