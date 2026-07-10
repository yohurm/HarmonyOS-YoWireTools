import { UiRadius } from '../foundation/UiRadius';
import { UiSpace } from '../foundation/UiSpace';
import { UiSize } from '../foundation/UiSize';
import { UiColor } from '../semantic/UiColor';

export class CardToken {
  static readonly RADIUS: number = UiRadius.MEDIUM;
  static readonly RADIUS_SMALL: number = UiRadius.SMALL;
  static readonly PADDING: number = UiSpace.XL;
  static readonly PADDING_COMPACT: number = UiSpace.L;
  static readonly HEIGHT_LIST: number = UiSize.LIST_CARD_HEIGHT;
  static readonly BACKGROUND: Resource = UiColor.SURFACE_CARD;
  static readonly SELECTED_BORDER_WIDTH: number = 1;
}
