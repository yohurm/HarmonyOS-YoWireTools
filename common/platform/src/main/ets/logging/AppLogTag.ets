/**
 * Centralized HiLog tags (ASCII, max 31 bytes per HarmonyOS spec).
 */
export class AppLogTag {
  static readonly APP: string = 'YoWire.App';
  static readonly PERM: string = 'YoWire.Perm';
  static readonly CAP: string = 'YoWire.Cap';
  static readonly LIFE: string = 'YoWire.Life';
  static readonly SESSION: string = 'YoWire.Session';
}
