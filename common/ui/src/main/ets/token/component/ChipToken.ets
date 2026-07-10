import { UiRadius } from '../foundation/UiRadius';
import { UiSpace } from '../foundation/UiSpace';
import { UiSize } from '../foundation/UiSize';
import { UiColor } from '../semantic/UiColor';

export class ChipToken {
  static readonly RADIUS: number = UiRadius.LARGE;
  static readonly PILL_RADIUS: number = UiRadius.FULL;
  static readonly STATUS_RADIUS: number = UiRadius.XS;
  static readonly HORIZONTAL_PADDING: number = UiSpace.XL;
  static readonly VERTICAL_PADDING: number = UiSpace.M;
  static readonly TOUCH_HEIGHT: number = UiSize.TOUCH_TARGET_MIN;
  static readonly SELECTED_BACKGROUND: Resource = UiColor.BRAND_PRIMARY;
  static readonly SELECTED_FOREGROUND: Resource = UiColor.TEXT_ON_PRIMARY;
  static readonly DEFAULT_BACKGROUND: Resource = UiColor.SURFACE_CARD;
  static readonly DEFAULT_FOREGROUND: Resource = UiColor.TEXT_PRIMARY;
}
