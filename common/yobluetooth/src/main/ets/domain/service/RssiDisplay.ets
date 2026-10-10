/**
 * Unknown RSSI stays blank. A missing callback is not shown as 0 dBm.
 */
export class RssiDisplay {
  static format(rssiKnown: boolean, rssi: number): string {
    if (!rssiKnown) {
      return '';
    }
    return `${rssi} dBm`;
  }
}
