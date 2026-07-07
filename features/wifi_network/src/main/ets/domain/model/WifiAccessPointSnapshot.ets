import { BssidMaskReason, WifiScanSource } from './WifiScanState';

export class WifiAccessPointSnapshot {
  readonly id: string;
  readonly ssid: string;
  readonly bssid: string;
  readonly bssidVisible: boolean;
  readonly bssidMaskReason: string;
  readonly rssi: number;
  readonly signalLevel: number;
  readonly band: number;
  readonly frequency: number;
  readonly channel: number;
  readonly securityType: string;
  readonly source: WifiScanSource;
  readonly capturedAtMs: number;

  constructor(
    id: string,
    ssid: string,
    bssid: string,
    bssidVisible: boolean,
    bssidMaskReason: string,
    rssi: number,
    signalLevel: number,
    band: number,
    frequency: number,
    channel: number,
    securityType: string,
    source: WifiScanSource,
    capturedAtMs: number
  ) {
    this.id = id;
    this.ssid = ssid;
    this.bssid = bssid;
    this.bssidVisible = bssidVisible;
    this.bssidMaskReason = bssidMaskReason;
    this.rssi = rssi;
    this.signalLevel = signalLevel;
    this.band = band;
    this.frequency = frequency;
    this.channel = channel;
    this.securityType = securityType;
    this.source = source;
    this.capturedAtMs = capturedAtMs;
  }

  static maskedBssid(raw: string, visible: boolean, reason: BssidMaskReason): string {
    if (visible && raw.length > 0) {
      return raw;
    }
    if (reason === BssidMaskReason.PERMISSION_DENIED) {
      return '**:**:**:**:**:**';
    }
    return 'unavailable';
  }
}
