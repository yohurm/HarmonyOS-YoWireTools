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
import { ConnectionParamPreset } from '../model/ConnectionParamPreset';
import { AdvertisingRequest } from '../model/AdvertisingRequest';
import { SppUuidFavoriteEntry } from '../model/SppUuidFavoriteEntry';
import { SppSocketKind } from '../model/SppSocketKind';

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
  listBleDevices(): BluetoothDevice[];
  tryReserveBleConnection(): boolean;
  releaseBleConnection(): void;
  resetBleScanPhase(): void;
  observeBleDevices(): Observable<BluetoothDevice[]>;
  startClassicDiscovery(sessionId: string): Promise<Result<void>>;
  stopClassicDiscovery(): Promise<Result<void>>;
  listClassicDevices(): BluetoothDevice[];
  resetClassicScanPhase(): void;
  ensureClassicDiscoveryStopped(): Promise<Result<void>>;
  pairDevice(deviceId: string): Promise<Result<void>>;
  observeClassicDevices(): Observable<BluetoothDevice[]>;
  enableBluetooth(): Promise<Result<void>>;
  disableBluetooth(): Promise<Result<void>>;
  republishClassicDevices(): void;
  saveFavorite(device: BluetoothDevice, alias: string, protocol: string, uuid: string): Promise<Result<void>>;
  getRemoteProfileUuids(deviceId: string): Promise<Result<string[]>>;
  discoverGattServices(sessionId: string, bleDeviceId: string, mtu: number): Promise<Result<GattServiceTreeSnapshot>>;
  getGattTree(sessionId: string): GattServiceTreeSnapshot | undefined;
  connectGattBrowser(sessionId: string, bleDeviceId: string): Promise<Result<void>>;
  releaseGattClient(sessionId: string): void;
  gattCurrentMtu(sessionId: string): number;
  createGattTransport(sessionId: string): object;
  readGattCharacteristicHex(sessionId: string, serviceUuid: string, characteristicUuid: string): Promise<Result<string>>;
  writeGattCharacteristicChunk(
    sessionId: string,
    serviceUuid: string,
    characteristicUuid: string,
    bytes: Uint8Array,
    noResponse: boolean
  ): Promise<Result<void>>;
  setGattNotification(
    sessionId: string,
    serviceUuid: string,
    characteristicUuid: string,
    enable: boolean,
    useIndication: boolean
  ): Promise<Result<void>>;
  readGattDescriptorHex(
    sessionId: string,
    serviceUuid: string,
    characteristicUuid: string,
    descriptorUuid: string
  ): Promise<Result<string>>;
  writeGattDescriptor(
    sessionId: string,
    serviceUuid: string,
    characteristicUuid: string,
    descriptorUuid: string,
    bytes: Uint8Array
  ): Promise<Result<void>>;
  requestGattMtu(sessionId: string, mtu: number): Promise<Result<number>>;
  readGattRssi(sessionId: string): Promise<Result<number>>;
  updateGattConnectionParam(sessionId: string, preset: ConnectionParamPreset): Promise<Result<void>>;
  openGattServer(serviceUuid: string, characteristicUuid: string, value: Uint8Array): Result<void>;
  closeGattServer(): Result<void>;
  notifyGattServer(
    deviceId: string,
    serviceUuid: string,
    characteristicUuid: string,
    value: Uint8Array,
    confirm: boolean
  ): Result<void>;
  startBleAdvertise(request: AdvertisingRequest): Promise<Result<void>>;
  stopBleAdvertise(): Promise<Result<void>>;
  listSppUuidFavorites(): Promise<SppUuidFavoriteEntry[]>;
  isSppUuidFavorite(uuid: string): boolean;
  toggleSppUuidFavorite(uuid: string, label: string): Promise<Result<boolean>>;
  addSppUuidFavorite(uuid: string, label: string): Promise<Result<void>>;
  updateSppUuidFavorite(uuid: string, nextUuid: string, label: string): Promise<Result<void>>;
  removeSppUuidFavorite(uuid: string): Promise<Result<void>>;
  listenSpp(name: string, uuid: string, secure: boolean, kind: SppSocketKind, psm: number): Promise<Result<number>>;
  acceptSpp(serverSocket: number): Promise<Result<number>>;
  closeSppServer(serverSocket: number): Result<void>;
}
