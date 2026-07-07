export class WifiLinkedInfoSnapshot {
  readonly capturedAtMs: number;
  readonly wifiActive: boolean;
  readonly connected: boolean;
  readonly ssid: string;
  readonly bssid: string;
  readonly bssidVisible: boolean;
  readonly rssi: number;
  readonly signalLevel: number;
  readonly band: number;
  readonly frequency: number;
  readonly linkSpeed: number;
  readonly ipAddress: string;
  readonly gateway: string;
  readonly dnsServers: string[];

  constructor(
    capturedAtMs: number,
    wifiActive: boolean,
    connected: boolean,
    ssid: string = '',
    bssid: string = '',
    bssidVisible: boolean = false,
    rssi: number = 0,
    signalLevel: number = 0,
    band: number = 0,
    frequency: number = 0,
    linkSpeed: number = 0,
    ipAddress: string = '',
    gateway: string = '',
    dnsServers: string[] = []
  ) {
    this.capturedAtMs = capturedAtMs;
    this.wifiActive = wifiActive;
    this.connected = connected;
    this.ssid = ssid;
    this.bssid = bssid;
    this.bssidVisible = bssidVisible;
    this.rssi = rssi;
    this.signalLevel = signalLevel;
    this.band = band;
    this.frequency = frequency;
    this.linkSpeed = linkSpeed;
    this.ipAddress = ipAddress;
    this.gateway = gateway;
    this.dnsServers = dnsServers;
  }
}
