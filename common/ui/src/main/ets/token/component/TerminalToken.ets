import { UiRadius } from '../foundation/UiRadius';
import { UiSpace } from '../foundation/UiSpace';

export class TerminalToken {
  static readonly BACKGROUND: Resource = $r('app.color.ui_terminal_background');
  static readonly INBOUND: Resource = $r('app.color.ui_terminal_inbound');
  static readonly OUTBOUND: Resource = $r('app.color.ui_terminal_outbound');
  static readonly RADIUS: number = UiRadius.MEDIUM;
  static readonly MIN_HEIGHT: number = 120;
  static readonly ROW_PADDING_V: number = UiSpace.S;
  static readonly DIRECTION_WIDTH: number = 28;
  static readonly LOG_ROW_DIRECTION_WIDTH: number = 52;
}
