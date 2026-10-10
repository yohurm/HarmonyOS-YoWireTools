export class NearLinkConstants {
  static readonly DEFAULT_MTU: number = 256;
  static readonly MIN_MTU: number = 22;
  static readonly MAX_MTU: number = 512;
  static readonly INVALID_RSSI: number = 127;
  static readonly MIN_SCAN_DURATION_SEC: number = 10;
  static readonly MAX_SCAN_DURATION_SEC: number = 60;
  static readonly CONGESTION_NATIVE_CODE: number = 1009700023;
  static readonly CONGESTION_INITIAL_BACKOFF_MS: number = 50;
  static readonly CONGESTION_MAX_BACKOFF_MS: number = 500;
  static readonly CONGESTION_MAX_RETRY: number = 5;
  static readonly GAP_UNPAIR: string = 'unpair';
  static readonly GAP_CDSM_UNSUPPORTED: string = 'cdsm_unsupported';
  static readonly CDSM_UNSUPPORTED_CODE: string = '1009700050';
}
