import { YoMotion } from '../foundation/YoMotion';
import { YoSize } from '../foundation/YoSize';
import { YoSpace } from '../foundation/YoSpace';

/**
 * Toast 组件级尺寸与时长 Token。
 * 视觉对齐 Android youi_kit YoToast；默认位置由 YoToast 设为居中。
 */
export class YoToastToken {
  static readonly MIN_WIDTH: number = 100;
  static readonly MAX_WIDTH: number = 280;
  /** 对齐 Android ToastDimens.CORNER_RADIUS (12)。 */
  static readonly CORNER_RADIUS: number = 12;
  static readonly PADDING_HORIZONTAL: number = YoSpace.XL;
  static readonly PADDING_VERTICAL: number = YoSpace.L;
  static readonly ICON_SIZE: number = YoSize.ICON_M;
  static readonly ICON_TEXT_SPACING: number = YoSpace.M;
  static readonly MAX_LINES: number = 2;
  static readonly EDGE_MARGIN: number = YoSpace.MAX;
  static readonly HORIZONTAL_MARGIN: number = YoSpace.XXL;
  static readonly DURATION_SHORT_MS: number = 2000;
  static readonly DURATION_LONG_MS: number = 3500;
  static readonly ANIMATION_MS: number = YoMotion.DURATION_SHORT;
}
