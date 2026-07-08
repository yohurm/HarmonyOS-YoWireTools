import { WifiLinkedInfoSnapshot } from './WifiLinkedInfoSnapshot';

export class WifiOverviewSnapshot {
  readonly wifiActive: boolean;
  readonly linkedInfo: WifiLinkedInfoSnapshot | undefined;
  readonly scanApCount: number;
  readonly lastScanAtMs: number;
  readonly scanFromCache: boolean;
  readonly warnings: string[];

  constructor(
    wifiActive: boolean,
    linkedInfo: WifiLinkedInfoSnapshot | undefined,
    scanApCount: number,
    lastScanAtMs: number,
    scanFromCache: boolean,
    warnings: string[]
  ) {
    this.wifiActive = wifiActive;
    this.linkedInfo = linkedInfo;
    this.scanApCount = scanApCount;
    this.lastScanAtMs = lastScanAtMs;
    this.scanFromCache = scanFromCache;
    this.warnings = warnings;
  }
}
