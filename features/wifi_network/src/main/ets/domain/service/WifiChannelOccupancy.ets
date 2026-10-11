import { WifiAccessPointSnapshot } from '../model/WifiAccessPointSnapshot';
import { WifiChannelOccupancyRow } from '../model/WifiDebugFacts';
import { WifiChannelCalculator } from './WifiChannelCalculator';

/**
 * Overlap estimate. The connected AP is excluded from the strongest-interference RSSI.
 */
export class WifiChannelOccupancy {
  static readonly RECOMMEND_MAX_INTENSITY: number = 1;

  static rate(rows: WifiAccessPointSnapshot[], connectedBssid: string): WifiChannelOccupancyRow[] {
    const result: WifiChannelOccupancyRow[] = [];
    for (let channel = 1; channel <= 13; channel++) {
      const center = WifiChannelCalculator.fromChannel24(channel);
      let count = 0;
      let strongest = -200;
      for (let i = 0; i < rows.length; i++) {
        const row = rows[i];
        if (row.frequency < 2400 || row.frequency >= 2500) {
          continue;
        }
        if (Math.abs(row.frequency - center) > 10) {
          continue;
        }
        count++;
        const sameConnected = connectedBssid.length > 0 && row.bssid === connectedBssid;
        if (!sameConnected && row.rssi > strongest) {
          strongest = row.rssi;
        }
      }
      const intensity = WifiChannelOccupancy.intensityFor(count);
      result.push(new WifiChannelOccupancyRow(channel, count, strongest === -200 ? 0 : strongest, intensity));
    }
    return result;
  }

  static recommend(rows: WifiChannelOccupancyRow[]): WifiChannelOccupancyRow[] {
    const out: WifiChannelOccupancyRow[] = [];
    for (let i = 0; i < rows.length; i++) {
      if (rows[i].intensity <= WifiChannelOccupancy.RECOMMEND_MAX_INTENSITY) {
        out.push(rows[i]);
      }
    }
    return out;
  }

  private static intensityFor(count: number): number {
    if (count <= 0) {
      return 0;
    }
    if (count === 1) {
      return 1;
    }
    if (count === 2) {
      return 2;
    }
    if (count === 3) {
      return 3;
    }
    return 4;
  }
}
