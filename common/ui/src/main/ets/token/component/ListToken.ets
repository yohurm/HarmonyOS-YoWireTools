import { UiSpace } from '../foundation/UiSpace';

/**
 * List / scroll chrome tokens for feature list surfaces.
 */
export class ListToken {
  /** Vertical gap between list items (dense device lists). */
  static readonly ITEM_GAP: number = UiSpace.XXS;
  /** Vertical margin per item so card shadow is not clipped, without large visual gaps. */
  static readonly ITEM_SHADOW_BLEED: number = UiSpace.XXS;
  /**
   * Scrollbar track width (vp).
   * Slightly thinner than prior 6vp for denser device lists.
   */
  static readonly SCROLLBAR_WIDTH: number = 4;
}
