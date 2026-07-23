import { YoSpace } from '../foundation/YoSpace';

/**
 * SegmentButton 门面默认值（系统 Options — 不可挂通用属性）。
 * selectedFontColor：选中底为白时的深色字（暗色模式下仍可读）。
 * 高度：V1 SegmentButton 无 height 属性；通过 buttonPadding 增高（文档默认 V=4）。
 */
export class YoSegmentToken {
  /** 浅色主题主文本 / 白底选中板的静态默认色。 */
  static readonly SELECTED_FONT_COLOR: string = '#ff182431';
  /** 按钮垂直内边距（vp）— 高于系统默认 4。 */
  static readonly BUTTON_PADDING_V: number = YoSpace.L; // 12
  /** 按钮水平内边距（vp）— 系统默认 8。 */
  static readonly BUTTON_PADDING_H: number = YoSpace.XL; // 16
}
