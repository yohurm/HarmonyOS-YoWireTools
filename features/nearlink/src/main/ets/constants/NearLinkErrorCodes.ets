/**
 * NearLink module error codes per architecture nearlink docs §9.
 */
export class NearLinkErrorCodes {
  static readonly UNSUPPORTED: string = 'YW-NL-1001';
  static readonly SWITCH_OFF: string = 'YW-NL-1002';
  static readonly EMPTY_FILTER: string = 'YW-NL-1003';
  static readonly MASK_LENGTH_MISMATCH: string = 'YW-NL-1004';
  static readonly RSSI_INVALID: string = 'YW-NL-1005';
  static readonly SCAN_FAILED: string = 'YW-NL-1099';
  static readonly SSAP_CREATE_FAILED: string = 'YW-NL-2101';
  static readonly SSAP_CONNECT_FAILED: string = 'YW-NL-2102';
  static readonly SSAP_DISCOVER_FAILED: string = 'YW-NL-2103';
  static readonly SSAP_READ_FAILED: string = 'YW-NL-2201';
  static readonly SSAP_WRITE_FAILED: string = 'YW-NL-2202';
  static readonly SSAP_NOTIFY_FAILED: string = 'YW-NL-2301';
  static readonly SSAP_MTU_RANGE: string = 'YW-NL-2401';
  static readonly SSAP_MTU_FAILED: string = 'YW-NL-2402';
  static readonly DT_INVALID_PARAMS: string = 'YW-NL-3101';
  static readonly DT_GENERIC_FAILED: string = 'YW-NL-3099';
  static readonly DT_UUID_REGISTERED: string = 'YW-NL-3201';
  static readonly DT_PORT_LIMIT: string = 'YW-NL-3202';
  static readonly DT_UUID_NOT_REGISTERED: string = 'YW-NL-3203';
  static readonly DT_WRITE_CONGESTED: string = 'YW-NL-3301';
  static readonly PERMISSION_DENIED: string = 'YW-PERM-3001';
  static readonly NOT_CONNECTED: string = 'YW-NL-1006';
  static readonly ENCRYPTION_UNVERIFIED: string = 'YW-NL-4001';
  static readonly OPERATION_BUSY: string = 'YW-NL-1010';
}
