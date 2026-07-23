import { YoColor } from '../semantic/YoColor';

export class YoNavigationToken {
  static readonly SIDE_NAV_WIDTH: number = 240;
  static readonly TITLE_BAR_HEIGHT: number = 56;
  static readonly FLOATING_TAB_MARGIN: number = 28;
  static readonly FLOATING_TAB_BOTTOM_PADDING: number = 88;
  /** 列表:详情分栏默认比例（4:6）。 */
  static readonly SPLIT_LIST_WEIGHT: number = 4;
  static readonly SPLIT_DETAIL_WEIGHT: number = 6;
  /** 均衡分栏变体（5:5）。 */
  static readonly SPLIT_BALANCED_LIST_WEIGHT: number = 5;
  static readonly SPLIT_BALANCED_DETAIL_WEIGHT: number = 5;
  /** 列表侧重分栏变体（6:4）。 */
  static readonly SPLIT_LIST_HEAVY_LIST_WEIGHT: number = 6;
  static readonly SPLIT_LIST_HEAVY_DETAIL_WEIGHT: number = 4;
  /** 分栏最小宽度 — 窗口窄于该值时应回退为单列。 */
  static readonly SPLIT_LIST_MIN_WIDTH: number = 280;
  static readonly SPLIT_DETAIL_MIN_WIDTH: number = 280;
  static readonly BACKGROUND: Resource = YoColor.BACKGROUND_PRIMARY;
}
