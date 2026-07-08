/** User-visible SPP terminal status codes for view-layer string resolution. */
export enum SppTerminalStatusKind {
  NONE = 'none',
  CONNECTED = 'connected',
  CONNECT_FAILED = 'connect_failed',
  PAIRING_STARTED = 'pairing_started',
  PAIR_FAILED = 'pair_failed',
  UUID_SAVED = 'uuid_saved',
  SAVE_FAILED = 'save_failed',
  DISCONNECTED = 'disconnected',
  TRANSPORT_MISSING = 'transport_missing',
  SENT = 'sent',
  SEND_FAILED = 'send_failed',
  ERROR = 'error'
}

/** User-visible classic scan status codes for view-layer string resolution. */
export enum ClassicScanStatusKind {
  NONE = 'none',
  SCAN_COMPLETED = 'scan_completed',
  IDLE_SUMMARY = 'idle_summary',
  REFRESHING_PAIRED = 'refreshing_paired',
  REFRESH_PAIRED_SUCCESS = 'refresh_paired_success',
  REFRESH_FAILED = 'refresh_failed',
  PERMISSION_DENIED = 'permission_denied',
  ADAPTER_OFF = 'adapter_off',
  SCAN_START_FAILED = 'scan_start_failed',
  SCANNING = 'scanning',
  SCAN_STOPPED = 'scan_stopped',
  PAIR_STARTED = 'pair_started',
  PAIR_FAILED = 'pair_failed',
  STOPPING_FOR_CONNECT = 'stopping_for_connect',
  ERROR = 'error'
}

/** User-visible BLE scan status codes for view-layer string resolution. */
export enum BleScanStatusKind {
  NONE = 'none',
  SCAN_FAILED = 'scan_failed',
  SCANNING = 'scanning',
  SCANNING_LEGACY = 'scanning_legacy',
  ERROR = 'error'
}

/** User-visible GATT detail status codes for view-layer string resolution. */
export enum GattDetailStatusKind {
  NONE = 'none',
  CONNECT_FAILED = 'connect_failed',
  CONNECTED = 'connected',
  BROWSER_CONNECT_FAILED = 'browser_connect_failed',
  BROWSER_CONNECTED = 'browser_connected',
  NOTIFY_SUBSCRIBE_FAILED = 'notify_subscribe_failed',
  DISCONNECTED = 'disconnected',
  MTU_UPDATED = 'mtu_updated',
  MTU_FAILED = 'mtu_failed',
  SUBSCRIBED = 'subscribed',
  UNSUBSCRIBED = 'unsubscribed',
  NOTIFY_FAILED = 'notify_failed',
  INVALID_PAYLOAD = 'invalid_payload',
  DESCRIPTOR_READ_FAILED = 'descriptor_read_failed',
  DESCRIPTOR_WRITE_OK = 'descriptor_write_ok',
  DESCRIPTOR_WRITE_FAILED = 'descriptor_write_failed',
  WRITE_OK = 'write_ok',
  WRITE_FAILED = 'write_failed',
  READ_FAILED = 'read_failed',
  ERROR = 'error'
}

/** User-visible bluetooth module settings status codes. */
export enum BluetoothModuleSettingsStatusKind {
  NONE = 'none',
  LOADED = 'loaded',
  AUTO_STOP_ENABLED = 'auto_stop_enabled',
  AUTO_STOP_DISABLED = 'auto_stop_disabled',
  LINE_ENDING_SAVED = 'line_ending_saved',
  SAVE_FAILED = 'save_failed',
  ERROR = 'error'
}
