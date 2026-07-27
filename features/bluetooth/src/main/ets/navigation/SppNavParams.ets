/**
 * NavPathStack param for SPP terminal page.
 */
export class SppTerminalNavParams {
  sessionId: string = '';

  constructor(sessionId: string = '') {
    this.sessionId = sessionId;
  }
}
