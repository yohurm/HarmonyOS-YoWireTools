import { DebugSessionSummary } from 'feature_debug_core';
import { DeviceFavoriteRecord } from 'common_storage';
import { BluetoothAdapterSnapshot } from './BluetoothDevice';
import { BluetoothRecentConnection } from './BluetoothRecentConnection';

export enum PermissionState {
  GRANTED = 'granted',
  DENIED = 'denied',
  UNKNOWN = 'unknown'
}

/**
 * Overview page state per architecture 02-§4.1 ViewModel state block.
 */
export class BluetoothOverviewUiState {
  readonly permissionState: PermissionState;
  readonly adapterState: BluetoothAdapterSnapshot;
  readonly classicSupported: boolean;
  readonly bleSupported: boolean;
  readonly recentDevices: BluetoothRecentConnection[];
  readonly favoriteDevices: DeviceFavoriteRecord[];
  readonly activeSessions: DebugSessionSummary[];
  readonly warnings: string[];

  constructor(
    permissionState: PermissionState,
    adapterState: BluetoothAdapterSnapshot,
    classicSupported: boolean,
    bleSupported: boolean,
    recentDevices: BluetoothRecentConnection[],
    favoriteDevices: DeviceFavoriteRecord[],
    activeSessions: DebugSessionSummary[],
    warnings: string[] = []
  ) {
    this.permissionState = permissionState;
    this.adapterState = adapterState;
    this.classicSupported = classicSupported;
    this.bleSupported = bleSupported;
    this.recentDevices = recentDevices;
    this.favoriteDevices = favoriteDevices;
    this.activeSessions = activeSessions;
    this.warnings = warnings;
  }
}
