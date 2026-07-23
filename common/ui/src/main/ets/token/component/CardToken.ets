import { UiRadius } from '../foundation/UiRadius';
import { UiSpace } from '../foundation/UiSpace';
import { UiSize } from '../foundation/UiSize';
import { UiColor } from '../semantic/UiColor';

/**
 * Card surface tokens — radius driven by UiRadius hierarchy.
 *
 * - RADIUS (16vp): overview / session / content cards
 * - RADIUS_DEVICE_ROW (8vp): dense device list rows（设计指南「列表内模块」）
 * - RADIUS_SMALL: alias of RADIUS_DEVICE_ROW（兼容旧调用）
 */
export class CardToken {
  static readonly RADIUS: number = UiRadius.MEDIUM;
  /** Dense device / settings-style list row（设计指南 8vp 列表内模块）. */
  static readonly RADIUS_DEVICE_ROW: number = UiRadius.SMALL;
  /** Alias of RADIUS_DEVICE_ROW for existing YoListRow call sites. */
  static readonly RADIUS_SMALL: number = UiRadius.SMALL;
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
  /** Vertical bleed so List does not clip card shadow. */
  static readonly SHADOW_BLEED: number = UiSpace.XS;
}
