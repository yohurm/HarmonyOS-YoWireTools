/**
 * WiFi/Network module error codes per architecture §15.
 * Source of truth is this class; docs under `.projectark/.../05-...§7` may drift.
 */
export class WifiNetworkErrorCodes {
  static readonly NO_INTERNET: string = 'YW-PERM-2001';
  static readonly NO_WIFI_INFO: string = 'YW-PERM-2002';
  static readonly NO_WIFI_PEERS_MAC: string = 'YW-PERM-2003';
  static readonly SCAN_LIMITED: string = 'YW-WIFI-1001';
  static readonly SCAN_COOLDOWN: string = 'YW-WIFI-1002';
  static readonly DNS_FAILED: string = 'YW-NET-1001';
  static readonly CONNECT_TIMEOUT: string = 'YW-NET-1002';
  /** Transport / socket not connected. */
  static readonly NOT_CONNECTED: string = 'YW-NET-1003';
  static readonly PORT_IN_USE: string = 'YW-NET-1004';
  static readonly HTTP_SIZE_LIMIT: string = 'YW-NET-1005';
  static readonly WS_SERVER_UNSUPPORTED: string = 'YW-CAP-2001';
  static readonly UDP_NOT_BOUND: string = 'YW-NET-2101';
  static readonly SOCKET_PORT_IN_USE: string = 'YW-NET-2102';
  static readonly SOCKET_ERRNO: string = 'YW-NET-2103';
  static readonly BACKGROUND_DISCONNECT: string = 'YW-NET-2104';
  static readonly SCAN_RANGE_TOO_LARGE: string = 'YW-NET-2201';
  static readonly TASK_CANCELLED: string = 'YW-NET-2202';
  static readonly MQTT_INVALID_CONNACK: string = 'YW-MQTT-1001';
  static readonly MQTT_CONN_REJECTED: string = 'YW-MQTT-1002';
  static readonly MQTT_INVALID_SUBACK: string = 'YW-MQTT-1003';
  static readonly MQTT_SUBSCRIBE_REJECTED: string = 'YW-MQTT-1004';
}
