import { DeviceFavoriteRecord } from 'common_storage';
import { DebugSessionSummary } from 'feature_debug_core';
import { NearLinkAdapterSnapshot } from './NearLinkDevice';
import { NearLinkRecentConnection } from './NearLinkRecentConnection';

export enum PermissionState {
  GRANTED = 'granted',
  DENIED = 'denied'
}

export class NearLinkOverviewUiState {
  readonly permissionState: PermissionState;
  readonly adapter: NearLinkAdapterSnapshot;
  readonly recentConnections: NearLinkRecentConnection[];
  readonly favorites: DeviceFavoriteRecord[];
  readonly activeSessions: DebugSessionSummary[];
  readonly warnings: string[];

  constructor(
    permissionState: PermissionState,
    adapter: NearLinkAdapterSnapshot,
    recentConnections: NearLinkRecentConnection[],
    favorites: DeviceFavoriteRecord[],
    activeSessions: DebugSessionSummary[],
    warnings: string[] = []
  ) {
    this.permissionState = permissionState;
    this.adapter = adapter;
    this.recentConnections = recentConnections;
    this.favorites = favorites;
    this.activeSessions = activeSessions;
    this.warnings = warnings;
  }
}
