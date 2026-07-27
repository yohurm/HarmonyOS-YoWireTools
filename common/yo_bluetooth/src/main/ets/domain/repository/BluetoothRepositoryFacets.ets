import { Result } from 'common_core';
import { BluetoothDevice } from '../model/BluetoothDevice';
import { BluetoothTransportType } from '../model/BluetoothTransportType';
import { DeviceIdentity } from '../model/DeviceIdentity';
import { SppConnectParams } from '../model/SppConnectParams';
import { BleScanFilter } from '../model/BleScanFilter';

/**
 * Repository facet contracts (architecture bluetooth/06).
 * Implementation may remain aggregated in BluetoothRepository.
 */
/**
 * 经典蓝牙发现 / 配对面（≠ SPP socket）。
 * Profile UUID 仅辅助展示与 UNKNOWN 降级，不构成完整 SDP。
 */
export interface ClassicBluetoothRepositoryFacet {
  loadPairedClassicCandidates(): Promise<Result<BluetoothDevice[]>>;
  getRemoteDeviceTransport(deviceId: string): Result<BluetoothTransportType>;
  getRemoteProfileUuids(deviceId: string): Promise<Result<string[]>>;
  startClassicScan(sessionId: string): Promise<Result<void>>;
  stopClassicScan(scanId: string): Promise<Result<void>>;
  ensureClassicDiscoveryStopped(): Promise<Result<void>>;
}

/** SPP 连接协议面：消费经典扫描轨得到的 classicDeviceId。 */
export interface SppBluetoothRepositoryFacet {
  resolveClassicIdForSpp(device: BluetoothDevice): Result<string>;
  createSppTransport(sessionId: string, params: SppConnectParams): object;
  linkDualModeIdentity(classicDeviceId: string, bleDeviceId: string, displayNameHint?: string): DeviceIdentity;
}

export interface BleScanRepositoryFacet {
  loadPairedBleCandidates(): Promise<Result<BluetoothDevice[]>>;
  startBleScan(sessionId: string, filter: BleScanFilter): Result<void>;
  stopBleScan(scanId?: string): Result<void>;
}

export interface GattBluetoothRepositoryFacet {
  createGattClient(sessionId: string, bleDeviceId: string): object;
  canOpenGattSession(): boolean;
  tryReserveBleConnection(): boolean;
  releaseBleConnection(): void;
  getActiveGattSessionCount(): number;
}
