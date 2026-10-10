/**
 * Free-space path loss estimate. Not a Kit measurement.
 */
export class WifiDistanceEstimator {
  static meters(rssiDbm: number, frequencyMhz: number): number {
    if (frequencyMhz <= 0) {
      return 0;
    }
    const exponent = (27.55 - (20 * Math.log10(frequencyMhz)) + Math.abs(rssiDbm)) / 20;
    const meters = Math.pow(10, exponent);
    if (!isFinite(meters)) {
      return 0;
    }
    return Math.round(meters * 10) / 10;
  }
}
