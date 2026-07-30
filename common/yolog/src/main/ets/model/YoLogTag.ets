/**
 * Centralized HiLog tags for cross-cutting concerns (ASCII, max 31 bytes).
 * Domain tags (Bluetooth / Wi-Fi / NearLink) live in consumer HARs, not here.
 */
export class YoLogTag {
  static readonly APP: string = 'YoWire.App';
  static readonly PERM: string = 'YoWire.Perm';
  static readonly CAP: string = 'YoWire.Cap';
  static readonly LIFE: string = 'YoWire.Life';
  static readonly SESSION: string = 'YoWire.Session';
}
