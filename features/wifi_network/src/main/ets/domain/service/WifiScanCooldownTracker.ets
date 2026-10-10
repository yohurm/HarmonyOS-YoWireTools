import { WifiNetworkConstants } from '../../constants/WifiNetworkConstants';

/**
 * Foreground limit is 4 startScan calls per 2 minutes.
 * Background limit is 1 startScan per 30 minutes.
 * The 30-second getScanInfoList cache is not a startScan gate.
 */
export class WifiScanCooldownTracker {
  private readonly foregroundTimestampsMs: number[] = [];
  private lastBackgroundScanAtMs: number = 0;

  canScanNow(nowMs: number = Date.now()): boolean {
    return this.foregroundSlotsLeft(nowMs) > 0;
  }

  foregroundSlotsLeft(nowMs: number = Date.now()): number {
    this.pruneForeground(nowMs);
    const left = WifiNetworkConstants.FOREGROUND_SCAN_MAX_COUNT - this.foregroundTimestampsMs.length;
    return left > 0 ? left : 0;
  }

  remainingCooldownMs(nowMs: number = Date.now()): number {
    this.pruneForeground(nowMs);
    if (this.foregroundTimestampsMs.length < WifiNetworkConstants.FOREGROUND_SCAN_MAX_COUNT) {
      return 0;
    }
    const oldest = this.foregroundTimestampsMs[0];
    const left = WifiNetworkConstants.FOREGROUND_SCAN_WINDOW_MS - (nowMs - oldest);
    return left > 0 ? left : 0;
  }

  canScanInBackground(nowMs: number = Date.now()): boolean {
    if (this.lastBackgroundScanAtMs === 0) {
      return true;
    }
    return nowMs - this.lastBackgroundScanAtMs >= WifiNetworkConstants.BACKGROUND_SCAN_WINDOW_MS;
  }

  recordScan(nowMs: number = Date.now()): void {
    this.foregroundTimestampsMs.push(nowMs);
    this.pruneForeground(nowMs);
  }

  recordBackgroundScan(nowMs: number = Date.now()): void {
    this.lastBackgroundScanAtMs = nowMs;
  }

  private pruneForeground(nowMs: number): void {
    const windowStart = nowMs - WifiNetworkConstants.FOREGROUND_SCAN_WINDOW_MS;
    while (this.foregroundTimestampsMs.length > 0 && this.foregroundTimestampsMs[0] < windowStart) {
      this.foregroundTimestampsMs.shift();
    }
  }
}
