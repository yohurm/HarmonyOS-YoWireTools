import { UiRadius } from '../foundation/UiRadius';
import { UiSpace } from '../foundation/UiSpace';

/**
 * Menu surface tokens (PromptAction.openMenu + Menu / MenuItem).
 *
 * Per ArkUI Menu docs:
 * - Unset width → system applies ~2-grid default, then grows with content
 * - Set width → MenuItem forced to that width (minus padding) — avoid for short labels
 * - Min width 64vp; radius default 20vp on phone (UiRadius.LARGE)
 *
 * Do NOT hardcode wide widths (e.g. 224) for title-bar more menus.
 */
export class MenuToken {
  static readonly RADIUS: number = UiRadius.LARGE;
  /** System minimum; use only as constraintSize.minWidth when needed. */
  static readonly MIN_WIDTH: number = 64;
  /** Soft upper bound for compact action menus (settings stub, etc.). */
  static readonly COMPACT_MAX_WIDTH: number = 168;
  static readonly ITEM_HORIZONTAL_PADDING: number = UiSpace.XL;
}
