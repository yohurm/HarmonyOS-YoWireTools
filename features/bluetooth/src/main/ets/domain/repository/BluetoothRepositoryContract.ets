import { Result } from 'common_core';
import { DeviceFavoriteRecord } from 'common_storage';
import { Observable } from 'common_core';
import {
  BluetoothAdapterSnapshot,
  BluetoothDevice,
  BluetoothOverviewSnapshot
} from '../model/BluetoothDevice';
import { BleScanFilter } from '../model/BleScanFilter';
import { BleAdvertisingPacket } from '../model/BleAdvertisingPacket';
import { BluetoothRecentConnection } from '../model/BluetoothRecentConnection';
import { PairingEvent, PairingState } from '../model/PairingState';
import { GattServiceTreeSnapshot } from '../model/GattServiceTree';
import { SppConnectParams } from '../model/SppConnectParams';

/**
 * Domain repository contract per architecture 02-§6.1.
 * Implemented by data/repository/BluetoothRepository.
 */
export interface BluetoothRepositoryContract {
  getAdapterState(): Promise<Result<BluetoothAdapterSnapshot>>;
  observeAdapterState(): Observable<BluetoothAdapterSnapshot>;
  getPairedDevices(): Promise<Result<BluetoothDevice[]>>;
  startClassicScan(sessionId: string): Promise<Result<void>>;
  stopClassicScan(scanId: string): Promise<Result<void>>;
  createSppTransport(sessionId: string, params: SppConnectParams): object;
  startBleScan(sessionId: string, filter: BleScanFilter): Result<void>;
  stopBleScan(scanId: string): Result<void>;
  createGattClient(sessionId: string, deviceId: string): object;
  loadOverview(permissionGranted: boolean): Promise<BluetoothOverviewSnapshot>;
  listRecentConnections(): BluetoothRecentConnection[];
  recordRecentConnection(deviceId: string, displayName: string, protocol: string): void;
  listFavorites(): DeviceFavoriteRecord[];
  getBleAdvertising(deviceId: string): BleAdvertisingPacket | undefined;
  observeGattTree(): Observable<GattServiceTreeSnapshot>;
  getPairState(deviceId: string): Promise<Result<PairingState>>;
  applyPairingEvent(event: PairingEvent): void;
}
