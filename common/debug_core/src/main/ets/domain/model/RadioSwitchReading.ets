/**
 * Workbench capsule reading. The page state turns these codes into sentences.
 * Failure stays unread. Denied and unsupported are not reported as off.
 */
export class RadioSwitchReading {
  static readonly UNREAD: string = 'unread';
  static readonly DENIED: string = 'denied';
  static readonly UNSUPPORTED: string = 'unsupported';
  static readonly OFF: string = 'off';
  static readonly ON: string = 'on';
}
