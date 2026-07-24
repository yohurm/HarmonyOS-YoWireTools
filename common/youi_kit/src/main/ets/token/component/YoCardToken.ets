import { YoRadius } from '../foundation/YoRadius';
import { YoSpace } from '../foundation/YoSpace';
import { YoSize } from '../foundation/YoSize';
import { YoColor } from '../semantic/YoColor';

/**
 * 卡片表面 Token — 圆角由 YoRadius 层级驱动。
 *
 * RADIUS（16vp / YoRadius.MEDIUM）：所有卡片表面，含设备列表行。
 */
export class YoCardToken {
  static readonly RADIUS: number = YoRadius.MEDIUM;
  static readonly PADDING: number = YoSpace.XL;
  static readonly PADDING_COMPACT: number = YoSpace.L;
  static readonly HEIGHT_LIST: number = YoSize.LIST_CARD_HEIGHT;
  /** 效率型设备行目标高度（鸿蒙列表 48/56 档，取 56）。 */
  static readonly HEIGHT_DEVICE_ROW: number = YoSize.LIST_ROW_HEIGHT;
  /** 行内右操作区与主内容间距（列表规范 12vp）。 */
  static readonly TRAILING_GAP: number = YoSpace.L;
  /** 行垂直内边距（主次文本已紧凑，外圈 6vp）。 */
  static readonly PADDING_ROW_V: number = YoSpace.S;
  static readonly BACKGROUND: Resource = YoColor.SURFACE_CARD;
  static readonly SELECTED_BORDER_WIDTH: number = 1;
  /** 抬升卡片阴影（概览 / 会话表面）。 */
  static readonly SHADOW: ShadowStyle = ShadowStyle.OUTER_DEFAULT_SM;
  /** 高密度列表行抬升。 */
  static readonly SHADOW_COMPACT: ShadowStyle = ShadowStyle.OUTER_DEFAULT_XS;
}
