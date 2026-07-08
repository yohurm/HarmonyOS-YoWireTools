/**
 * Root navigation route names per UI design 01 + architecture 00-§7.2.
 */
export class AppRoutes {
  static readonly WORKBENCH: string = '/home/workbench';
  static readonly BLUETOOTH: string = '/bluetooth/overview';
  static readonly WIFI: string = '/wifi/overview';
  static readonly NEARLINK: string = '/nearlink/overview';
  static readonly MORE_HUB: string = '/more/hub';

  static readonly TAB_INDEX_WORKBENCH: number = 0;
  static readonly TAB_INDEX_BLUETOOTH: number = 1;
  static readonly TAB_INDEX_NETWORK: number = 2;
  static readonly TAB_INDEX_NEARLINK: number = 3;
  static readonly TAB_INDEX_MORE: number = 4;
}
