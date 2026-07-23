import { Result } from 'common_core';
import { DeviceFavoriteRecord } from 'common_storage';
import { Observable } from 'common_core';
import {
  BluetoothAdapterSnapshot,
  BluetoothDevice,
  BluetoothOverviewSnapshot
} from '../model/BluetoothDevice';
import { BluetoothTransportType } from '../model/BluetoothTransportType';
import { DeviceIdentity } from '../model/DeviceIdentity';
import { BleScanFilter } from '../model/BleScanFilter';
import { BleAdvertisingPacket } from '../model/BleAdvertisingPacket';
import { BluetoothRecentConnection } from '../model/BluetoothRecentConnection';
import { PairingEvent, PairingState } from '../model/PairingState';
import { GattServiceTreeSnapshot } from '../model/GattServiceTree';
import { SppConnectParams } from '../model/SppConnectParams';

/**
 * Domain repository contract per architecture 02-§6.1 + bluetooth/00.
 */
export interface BluetoothRepositoryContract {
  getAdapterState(): Promise<Result<BluetoothAdapterSnapshot>>;
  observeAdapterState(): Observable<BluetoothAdapterSnapshot>;
  loadPairedClassicCandidates(): Promise<Result<BluetoothDevice[]>>;
  loadPairedBleCandidates(): Promise<Result<BluetoothDevice[]>>;
  getRemoteDeviceTransport(deviceId: string): Result<BluetoothTransportType>;
  resolveClassicIdForSpp(device: BluetoothDevice): Result<string>;
  linkDualModeIdentity(classicDeviceId: string, bleDeviceId: string, displayNameHint?: string): DeviceIdentity;
  startClassicScan(sessionId: string): Promise<Result<void>>;
  stopClassicScan(scanId: string): Promise<Result<void>>;
  createSppTransport(sessionId: string, params: SppConnectParams): object;
  startBleScan(sessionId: string, filter: BleScanFilter): Result<void>;
  stopBleScan(scanId: string): Result<void>;
  createGattClient(sessionId: string, bleDeviceId: string): object;
  loadOverview(permissionGranted: boolean): Promise<BluetoothOverviewSnapshot>;
  listRecentConnections(): BluetoothRecentConnection[];
  recordRecentConnection(deviceId: string, displayName: string, protocol: string): void;
  listFavorites(): DeviceFavoriteRecord[];
  getBleAdvertising(bleDeviceId: string): BleAdvertisingPacket | undefined;
  observeGattTree(): Observable<GattServiceTreeSnapshot>;
  getPairState(deviceId: string): Promise<Result<PairingState>>;
  applyPairingEvent(event: PairingEvent): void;
}
