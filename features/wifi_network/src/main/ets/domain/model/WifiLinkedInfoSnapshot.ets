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
  readonly txLinkSpeedMbps: number;
  readonly rxLinkSpeedMbps: number;
  readonly maxTxMbps: number;
  readonly maxRxMbps: number;
  readonly channelWidthLabel: string;
  readonly wifiStandardLabel: string;
  readonly connStateLabel: string;
  readonly hiddenLabel: string;
  readonly restrictedLabel: string;
  readonly linkTypeLabel: string;
  readonly macAddress: string;
  readonly addressKind: string;
  readonly nativeCode: string;

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
    dnsServers: string[] = [],
    txLinkSpeedMbps: number = 0,
    rxLinkSpeedMbps: number = 0,
    maxTxMbps: number = 0,
    maxRxMbps: number = 0,
    channelWidthLabel: string = '',
    wifiStandardLabel: string = '',
    connStateLabel: string = '',
    hiddenLabel: string = '',
    restrictedLabel: string = '',
    linkTypeLabel: string = '',
    macAddress: string = '',
    addressKind: string = '',
    nativeCode: string = ''
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
    this.txLinkSpeedMbps = txLinkSpeedMbps;
    this.rxLinkSpeedMbps = rxLinkSpeedMbps;
    this.maxTxMbps = maxTxMbps;
    this.maxRxMbps = maxRxMbps;
    this.channelWidthLabel = channelWidthLabel;
    this.wifiStandardLabel = wifiStandardLabel;
    this.connStateLabel = connStateLabel;
    this.hiddenLabel = hiddenLabel;
    this.restrictedLabel = restrictedLabel;
    this.linkTypeLabel = linkTypeLabel;
    this.macAddress = macAddress;
    this.addressKind = addressKind;
    this.nativeCode = nativeCode;
  }
}
