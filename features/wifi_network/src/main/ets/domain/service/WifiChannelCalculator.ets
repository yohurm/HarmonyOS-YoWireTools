/**
 * Maps WiFi frequency to channel number per architecture wifi_network/01-§8.
 */
export class WifiChannelCalculator {
  static fromFrequency(frequencyMhz: number): number {
    if (frequencyMhz >= 2412 && frequencyMhz <= 2484) {
      return Math.round((frequencyMhz - 2407) / 5);
    }
    if (frequencyMhz >= 5170 && frequencyMhz <= 5825) {
      return Math.round((frequencyMhz - 5000) / 5);
    }
    if (frequencyMhz >= 5955 && frequencyMhz <= 7115) {
      return Math.round((frequencyMhz - 5950) / 5);
    }
    return 0;
  }

  static fromChannel24(channel: number): number {
    if (channel === 14) {
      return 2484;
    }
    return 2407 + (5 * channel);
  }

  static bandLabel(band: number): string {
    if (band === 1) {
      return '2.4GHz';
    }
    if (band === 2) {
      return '5GHz';
    }
    if (band === 3) {
      return '6GHz';
    }
    return 'Unknown';
  }
}
