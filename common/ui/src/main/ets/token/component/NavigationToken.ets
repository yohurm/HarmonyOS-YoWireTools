import { UiColor } from '../semantic/UiColor';

export class NavigationToken {
  static readonly SIDE_NAV_WIDTH: number = 240;
  static readonly TITLE_BAR_HEIGHT: number = 56;
  static readonly FLOATING_TAB_MARGIN: number = 28;
  static readonly FLOATING_TAB_BOTTOM_PADDING: number = 88;
  /** Default split ratio for list:detail panes (4:6). */
  static readonly SPLIT_LIST_WEIGHT: number = 4;
  static readonly SPLIT_DETAIL_WEIGHT: number = 6;
  /** Balanced split variant (5:5). */
  static readonly SPLIT_BALANCED_LIST_WEIGHT: number = 5;
  static readonly SPLIT_BALANCED_DETAIL_WEIGHT: number = 5;
  /** List-heavy split variant (6:4). */
  static readonly SPLIT_LIST_HEAVY_LIST_WEIGHT: number = 6;
  static readonly SPLIT_LIST_HEAVY_DETAIL_WEIGHT: number = 4;
  /** Minimum pane widths — window narrows below these should fall back to single column. */
  static readonly SPLIT_LIST_MIN_WIDTH: number = 280;
  static readonly SPLIT_DETAIL_MIN_WIDTH: number = 280;
  static readonly BACKGROUND: Resource = UiColor.BACKGROUND_PRIMARY;
}
