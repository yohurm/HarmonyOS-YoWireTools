import { YoRadius } from '../foundation/YoRadius';
import { YoSpace } from '../foundation/YoSpace';

/**
 * 菜单表面 Token（PromptAction.openMenu + Menu / MenuItem）。
 *
 * 依据 ArkUI Menu 文档：
 * - 不设置 width → 系统约 2 栅格默认，再随内容扩展
 * - 设置 width → MenuItem 被强制为该宽度（减去 padding）— 短标签场景避免
 * - 最小宽度 64vp；手机默认圆角 20vp（YoRadius.LARGE）
 *
 * 勿为标题栏「更多」菜单硬编码过宽宽度（如 224）。
 */
export class YoMenuToken {
  static readonly RADIUS: number = YoRadius.LARGE;
  /** 系统最小值；仅在需要时作为 constraintSize.minWidth。 */
  static readonly MIN_WIDTH: number = 64;
  /** 紧凑操作菜单的软上限（设置占位等）。 */
  static readonly COMPACT_MAX_WIDTH: number = 168;
  static readonly ITEM_HORIZONTAL_PADDING: number = YoSpace.XL;
}
