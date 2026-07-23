import { YoRadius } from '../foundation/YoRadius';
import { YoSpace } from '../foundation/YoSpace';
import { YoSize } from '../foundation/YoSize';
import { YoColor } from '../semantic/YoColor';

export class YoChipToken {
  static readonly RADIUS: number = YoRadius.LARGE;
  static readonly PILL_RADIUS: number = YoRadius.FULL;
  static readonly STATUS_RADIUS: number = YoRadius.XS;
  static readonly HORIZONTAL_PADDING: number = YoSpace.XL;
  static readonly VERTICAL_PADDING: number = YoSpace.M;
  static readonly TOUCH_HEIGHT: number = YoSize.TOUCH_TARGET_MIN;
  static readonly SELECTED_BACKGROUND: Resource = YoColor.BRAND_PRIMARY;
  static readonly SELECTED_FOREGROUND: Resource = YoColor.TEXT_ON_PRIMARY;
  static readonly DEFAULT_BACKGROUND: Resource = YoColor.SURFACE_CARD;
  static readonly DEFAULT_FOREGROUND: Resource = YoColor.TEXT_PRIMARY;
}
