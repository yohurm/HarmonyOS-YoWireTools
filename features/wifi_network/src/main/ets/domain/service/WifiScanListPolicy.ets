import { WifiAccessPointSnapshot } from '../model/WifiAccessPointSnapshot';

export class WifiScanListPolicy {
  static filter(
    rows: WifiAccessPointSnapshot[],
    ssidPart: string,
    signalLevel: number,
    security: string,
    band: number
  ): WifiAccessPointSnapshot[] {
    const needle = ssidPart.trim();
    const out: WifiAccessPointSnapshot[] = [];
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      if (needle.length > 0 && row.ssid.indexOf(needle) < 0) {
        continue;
      }
      if (signalLevel >= 0 && row.signalLevel !== signalLevel) {
        continue;
      }
      if (security.length > 0 && row.securityType !== security) {
        continue;
      }
      if (band === 1 && !WifiScanListPolicy.is24Ghz(row.frequency, row.band)) {
        continue;
      }
      if (band === 2 && WifiScanListPolicy.is24Ghz(row.frequency, row.band)) {
        continue;
      }
      out.push(row);
    }
    return out;
  }

  static sortByRssiDesc(rows: WifiAccessPointSnapshot[]): WifiAccessPointSnapshot[] {
    const copy = rows.slice();
    copy.sort((a: WifiAccessPointSnapshot, b: WifiAccessPointSnapshot) => b.rssi - a.rssi);
    return copy;
  }

  static is24Ghz(frequencyMhz: number, band: number): boolean {
    if (band === 1) {
      return true;
    }
    return frequencyMhz >= 2400 && frequencyMhz < 2500;
  }

  static is5Ghz(frequencyMhz: number, band: number): boolean {
    if (band === 2) {
      return true;
    }
    return frequencyMhz >= 5000 && frequencyMhz < 5900;
  }
}
