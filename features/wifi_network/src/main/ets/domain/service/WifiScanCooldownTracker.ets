import { WifiNetworkConstants } from '../../constants/WifiNetworkConstants';

/**
 * Tracks foreground scan rate limits and app cooldown per architecture wifi_network/01-§5.
 */
export class WifiScanCooldownTracker {
  private readonly scanTimestampsMs: number[] = [];
  private lastScanAtMs: number = 0;

  canScanNow(nowMs: number = Date.now()): boolean {
    const elapsed = nowMs - this.lastScanAtMs;
    if (elapsed < WifiNetworkConstants.DEFAULT_SCAN_COOLDOWN_MS) {
      return false;
    }
    this.pruneOld(nowMs);
    return this.scanTimestampsMs.length < WifiNetworkConstants.FOREGROUND_SCAN_MAX_COUNT;
  }

  remainingCooldownMs(nowMs: number = Date.now()): number {
    const appCooldown = WifiNetworkConstants.DEFAULT_SCAN_COOLDOWN_MS - (nowMs - this.lastScanAtMs);
    if (appCooldown > 0) {
      return appCooldown;
    }
    this.pruneOld(nowMs);
    if (this.scanTimestampsMs.length >= WifiNetworkConstants.FOREGROUND_SCAN_MAX_COUNT) {
      const oldest = this.scanTimestampsMs[0];
      return WifiNetworkConstants.FOREGROUND_SCAN_WINDOW_MS - (nowMs - oldest);
    }
    return 0;
  }

  recordScan(nowMs: number = Date.now()): void {
    this.lastScanAtMs = nowMs;
    this.scanTimestampsMs.push(nowMs);
    this.pruneOld(nowMs);
  }

  private pruneOld(nowMs: number): void {
    const windowStart = nowMs - WifiNetworkConstants.FOREGROUND_SCAN_WINDOW_MS;
    while (this.scanTimestampsMs.length > 0 && this.scanTimestampsMs[0] < windowStart) {
      this.scanTimestampsMs.shift();
    }
  }
}
