import { YoRadius } from '../foundation/YoRadius';
import { YoSpace } from '../foundation/YoSpace';

/**
 * 弹出框 Token — 对齐 HarmonyOS 设计指南「弹出框」：
 * 最大宽 400vp、圆角 32vp、内容可滚、按钮区固定、双按钮间距 12vp。
 */
export class YoDialogToken {
  static readonly RADIUS: number = YoRadius.XLARGE;
  static readonly CONTENT_PADDING: number = YoSpace.XXL;
  static readonly MAX_WIDTH: number = 400;
  /** 内容区可滚动最大高度（标题/按钮区由系统 CustomContentDialog 承担）。 */
  static readonly CONTENT_SCROLL_MAX_HEIGHT: number = 320;
  /** 双按钮水平间距（设计指南：12vp）。 */
  static readonly BUTTON_GAP: number = YoSpace.L;
  /** 弹窗外侧水平边距（设计指南：手机约 16vp）。 */
  static readonly SIDE_MARGIN: number = YoSpace.XL;
  static readonly SHEET_MAX_WIDTH: number = 480;
  static readonly SHEET_CENTER_WIDTH: number = 480;
  static readonly SHEET_CENTER_HEIGHT: number = 560;
}
