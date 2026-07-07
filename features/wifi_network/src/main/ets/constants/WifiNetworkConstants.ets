export class WifiNetworkConstants {
  static readonly DEFAULT_SCAN_COOLDOWN_MS: number = 30000;
  static readonly FOREGROUND_SCAN_WINDOW_MS: number = 120000;
  static readonly FOREGROUND_SCAN_MAX_COUNT: number = 4;
  static readonly DEFAULT_CONNECT_TIMEOUT_MS: number = 10000;
  static readonly DEFAULT_HTTP_TIMEOUT_MS: number = 30000;
  static readonly DEFAULT_HTTP_MAX_BYTES: number = 5 * 1024 * 1024;
  static readonly DEFAULT_PORT_SCAN_CONCURRENCY: number = 32;
  static readonly MAX_PORT_SCAN_CONCURRENCY: number = 64;
  static readonly DEFAULT_LAN_PROBE_PORTS: number[] = [80, 443, 22, 8080];
  static readonly DEFAULT_PING_COUNT: number = 4;
  static readonly MAX_UDP_DATAGRAM_BYTES: number = 65507;
  static readonly DEFAULT_MULTICAST_GROUP: string = '224.0.0.1';
  static readonly DEFAULT_MDNS_SERVICE_TYPE: string = '_http._tcp';
}
