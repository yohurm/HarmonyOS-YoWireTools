import { YoRadius } from '../foundation/YoRadius';
import { YoSize } from '../foundation/YoSize';
import { YoSpace } from '../foundation/YoSpace';
import { YoOpacity } from '../foundation/YoOpacity';
import { YoColor } from '../semantic/YoColor';

export class YoButtonToken {
  static readonly RADIUS: number = YoRadius.LARGE;
  static readonly HEIGHT: number = YoSize.BUTTON_HEIGHT;
  static readonly HEIGHT_COMPACT: number = YoSize.BUTTON_HEIGHT_COMPACT;
  static readonly HORIZONTAL_PADDING: number = YoSpace.XL;
  static readonly DISABLED_OPACITY: number = YoOpacity.DISABLED_CONTENT;
  static readonly PRIMARY_BACKGROUND: Resource = YoColor.BRAND_PRIMARY;
  static readonly PRIMARY_FOREGROUND: Resource = YoColor.TEXT_ON_PRIMARY;
  static readonly SECONDARY_BACKGROUND: Resource = YoColor.SURFACE_CARD;
  static readonly SECONDARY_FOREGROUND: Resource = YoColor.TEXT_PRIMARY;
  static readonly DANGER_BACKGROUND: Resource = YoColor.ERROR;
  static readonly DANGER_FOREGROUND: Resource = YoColor.TEXT_ON_PRIMARY;
}
