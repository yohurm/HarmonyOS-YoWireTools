import { UiRadius } from '../foundation/UiRadius';
import { UiSize } from '../foundation/UiSize';
import { UiSpace } from '../foundation/UiSpace';
import { UiOpacity } from '../foundation/UiOpacity';
import { UiColor } from '../semantic/UiColor';

export class ButtonToken {
  static readonly RADIUS: number = UiRadius.LARGE;
  static readonly HEIGHT: number = UiSize.BUTTON_HEIGHT;
  static readonly HEIGHT_COMPACT: number = UiSize.BUTTON_HEIGHT_COMPACT;
  static readonly HORIZONTAL_PADDING: number = UiSpace.XL;
  static readonly DISABLED_OPACITY: number = UiOpacity.DISABLED_CONTENT;
  static readonly PRIMARY_BACKGROUND: Resource = UiColor.BRAND_PRIMARY;
  static readonly PRIMARY_FOREGROUND: Resource = UiColor.TEXT_ON_PRIMARY;
  static readonly SECONDARY_BACKGROUND: Resource = UiColor.SURFACE_CARD;
  static readonly SECONDARY_FOREGROUND: Resource = UiColor.TEXT_PRIMARY;
  static readonly DANGER_BACKGROUND: Resource = UiColor.ERROR;
  static readonly DANGER_FOREGROUND: Resource = UiColor.TEXT_ON_PRIMARY;
}
