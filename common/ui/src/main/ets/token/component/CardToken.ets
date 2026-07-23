import { UiRadius } from '../foundation/UiRadius';
import { UiSpace } from '../foundation/UiSpace';
import { UiSize } from '../foundation/UiSize';
import { UiColor } from '../semantic/UiColor';

/**
 * Card surface tokens — radius driven by UiRadius hierarchy.
 *
 * RADIUS (16vp / UiRadius.MEDIUM): all card surfaces including device list rows.
 */
export class CardToken {
  static readonly RADIUS: number = UiRadius.MEDIUM;
  static readonly PADDING: number = UiSpace.XL;
  static readonly PADDING_COMPACT: number = UiSpace.L;
  /** Vertical padding for compact device rows (nRF / settings density). */
  static readonly PADDING_ROW_V: number = UiSpace.M;
  static readonly HEIGHT_LIST: number = UiSize.LIST_CARD_HEIGHT;
  /** Compact device list row target height. */
  static readonly HEIGHT_DEVICE_ROW: number = UiSize.LIST_ROW_HEIGHT;
  static readonly BACKGROUND: Resource = UiColor.SURFACE_CARD;
  static readonly SELECTED_BORDER_WIDTH: number = 1;
  /** Elevated card shadow (overview / session surfaces). */
  static readonly SHADOW: ShadowStyle = ShadowStyle.OUTER_DEFAULT_SM;
  /** Dense list-row elevation. */
  static readonly SHADOW_COMPACT: ShadowStyle = ShadowStyle.OUTER_DEFAULT_XS;
}
