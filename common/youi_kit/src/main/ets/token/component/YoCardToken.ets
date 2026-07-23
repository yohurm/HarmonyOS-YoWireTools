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
  /** 紧凑设备行的垂直内边距（nRF / 设置页密度）。 */
  static readonly PADDING_ROW_V: number = YoSpace.M;
  static readonly HEIGHT_LIST: number = YoSize.LIST_CARD_HEIGHT;
  /** 紧凑设备列表行目标高度。 */
  static readonly HEIGHT_DEVICE_ROW: number = YoSize.LIST_ROW_HEIGHT;
  static readonly BACKGROUND: Resource = YoColor.SURFACE_CARD;
  static readonly SELECTED_BORDER_WIDTH: number = 1;
  /** 抬升卡片阴影（概览 / 会话表面）。 */
  static readonly SHADOW: ShadowStyle = ShadowStyle.OUTER_DEFAULT_SM;
  /** 高密度列表行抬升。 */
  static readonly SHADOW_COMPACT: ShadowStyle = ShadowStyle.OUTER_DEFAULT_XS;
}
