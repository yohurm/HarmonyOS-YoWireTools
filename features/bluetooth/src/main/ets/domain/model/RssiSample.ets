export class RssiSample {
  readonly timestampMs: number;
  readonly rssi: number;

  constructor(timestampMs: number, rssi: number) {
    this.timestampMs = timestampMs;
    this.rssi = rssi;
  }
}
