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

export enum PermissionState {
  GRANTED = 'granted',
  DENIED = 'denied',
  PARTIAL = 'partial'
}

export class WifiOverviewUiState {
  readonly wifiInfoPermission: PermissionState;
  readonly peersMacPermission: PermissionState;
  readonly networkPermission: PermissionState;
  readonly overview: WifiOverviewSnapshot;
  readonly activeSessionCount: number;

  constructor(
    wifiInfoPermission: PermissionState,
    peersMacPermission: PermissionState,
    networkPermission: PermissionState,
    overview: WifiOverviewSnapshot,
    activeSessionCount: number
  ) {
    this.wifiInfoPermission = wifiInfoPermission;
    this.peersMacPermission = peersMacPermission;
    this.networkPermission = networkPermission;
    this.overview = overview;
    this.activeSessionCount = activeSessionCount;
  }
}
