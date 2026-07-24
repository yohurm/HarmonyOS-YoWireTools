import { YoSpace } from '../foundation/YoSpace';
import { YoSize } from '../foundation/YoSize';

/**
 * 特性列表表面的列表 / 滚动条装饰 Token。
 *
 * 扫描/会话列表采用「分组卡片表面」：项间无空隙，行内分割线对齐内容区。
 */
export class YoListToken {
  /** 分组列表项间距（同表面内为 0）。 */
  static readonly ITEM_GAP: number = YoSpace.NONE;
  /** 独立浮卡模式的阴影出血（兼容旧用法）。 */
  static readonly ITEM_SHADOW_BLEED: number = YoSpace.XXS;
  /** 分组行分割线粗细。 */
  static readonly DIVIDER_STROKE: number = 0.5;
  /**
   * 分割线左侧缩进 = 行内左边距 + 图标 + 图标与内容间距，
   * 使分割线从主文本列起笔（效率型列表常见做法）。
   */
  static readonly DIVIDER_INSET_LEADING: number = YoSpace.L + YoSize.ICON_M + YoSpace.L;
  /**
   * 滚动条轨道宽度（vp）。
   * 较原先 6vp 略细，适配更紧凑的设备列表。
   */
  static readonly SCROLLBAR_WIDTH: number = 4;
}
