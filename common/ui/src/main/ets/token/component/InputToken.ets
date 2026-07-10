import { UiRadius } from '../foundation/UiRadius';
import { UiSize } from '../foundation/UiSize';
import { UiSpace } from '../foundation/UiSpace';
import { UiStroke } from '../foundation/UiStroke';
import { UiColor } from '../semantic/UiColor';

export class InputToken {
  static readonly RADIUS: number = UiRadius.LARGE;
  static readonly HEIGHT: number = UiSize.BUTTON_HEIGHT;
  static readonly HEIGHT_COMPACT: number = UiSize.BUTTON_HEIGHT_COMPACT;
  static readonly HORIZONTAL_PADDING: number = UiSpace.M;
  static readonly BACKGROUND: Resource = UiColor.SURFACE_INPUT;
  static readonly FOREGROUND: Resource = UiColor.TEXT_PRIMARY;
  static readonly BORDER: Resource = UiColor.BORDER_PRIMARY;
  static readonly BORDER_FOCUSED: Resource = UiColor.BORDER_FOCUSED;
  static readonly BORDER_WIDTH: number = UiStroke.THIN;
  static readonly BORDER_WIDTH_FOCUSED: number = UiStroke.FOCUS;
}
