import { access, connection } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Observable, Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothAdapterSnapshot } from '../../../domain/model/BluetoothDevice';
import { PairingEvent, PairingState } from '../../../domain/model/PairingState';
import { BluetoothDeviceMapper, PlatformPairedDevice } from '../../mapper/BluetoothDeviceMapper';
import { ConnectivityKitEventBridge } from '../../kit/ConnectivityKitEventBridge';

export class PlatformDiscoveryPayload {
  readonly deviceId: string;
  readonly deviceName: string;
  readonly rssi: number;
  readonly deviceClass: number;
  readonly fromLegacyFind: boolean;

  constructor(
    deviceId: string,
    deviceName: string,
    rssi: number,
    deviceClass: number,
    fromLegacyFind: boolean = false
  ) {
    this.deviceId = deviceId;
    this.deviceName = deviceName;
    this.rssi = rssi;
    this.deviceClass = deviceClass;
    this.fromLegacyFind = fromLegacyFind;
  }
}

type DiscoveryResultListener = (payload: PlatformDiscoveryPayload) => void;
type BondStateListener = (event: PairingEvent) => void;
type AdapterStateListener = (snapshot: BluetoothAdapterSnapshot) => void;
/**
 * Platform wrapper for classic Bluetooth adapter, discovery and pairing APIs.
 * WSL: connection.startBluetoothDiscovery, discoveryResult, pairDevice, bondStateChange.
 */
export class ClassicBluetoothDataSource {
  private static instance: ClassicBluetoothDataSource | undefined;
  private discoveryListener: DiscoveryResultListener | undefined;
  private discoveryResultHandler: ((data: Array<connection.DiscoveryResult>) => void) | undefined;
  private deviceFindHandler: ((data: Array<string>) => void) | undefined;
  private bondListener: BondStateListener | undefined;
  private bondHandler: ((data: connection.BondStateParam) => void) | undefined;
  private adapterHandler: ((state: access.BluetoothState) => void) | undefined;
  private adapterListener: AdapterStateListener | undefined;
  private readonly adapterObservable: Observable<BluetoothAdapterSnapshot>;
  private constructor() {
    this.adapterObservable = new Observable<BluetoothAdapterSnapshot>(
      new BluetoothAdapterSnapshot(false, access.BluetoothState.STATE_OFF, 'Off')
    );
  }

  static getInstance(): ClassicBluetoothDataSource {
    if (ClassicBluetoothDataSource.instance === undefined) {
      ClassicBluetoothDataSource.instance = new ClassicBluetoothDataSource();
    }
    return ClassicBluetoothDataSource.instance;
  }

  async getAdapterState(): Promise<Result<BluetoothAdapterSnapshot>> {
    try {
      const state = access.getState();
      const enabled = state === access.BluetoothState.STATE_ON;
      const label = enabled ? 'On' : 'Off';
      return Result.ok(new BluetoothAdapterSnapshot(enabled, state, label));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.CLASSIC_UNAVAILABLE, err));
    }
  }

  observeAdapterState(): Observable<BluetoothAdapterSnapshot> {
    return this.adapterObservable;
  }

  onAdapterStateChange(listener: AdapterStateListener): Result<void> {
    this.offAdapterStateChange();
    this.adapterListener = listener;
    this.adapterHandler = (state: access.BluetoothState) => {
      const enabled = state === access.BluetoothState.STATE_ON;
      const label = enabled ? 'On' : 'Off';
      const snapshot = new BluetoothAdapterSnapshot(enabled, state, label);
      this.adapterObservable.next(snapshot);
      listener(snapshot);
    };
    return ConnectivityKitEventBridge.subscribeAccessStateChange(this.adapterHandler);
  }

  offAdapterStateChange(): void {
    if (this.adapterHandler !== undefined) {
      ConnectivityKitEventBridge.unsubscribeAccessStateChange(this.adapterHandler);
      this.adapterHandler = undefined;
    }
    this.adapterListener = undefined;
  }

  async getRemoteProfileUuids(deviceId: string): Promise<Result<string[]>> {
    try {
      const profiles = await connection.getRemoteProfileUuids(deviceId);
      const uuids: string[] = [];
      for (let i = 0; i < profiles.length; i++) {
        uuids.push(`${profiles[i]}`);
      }
      return Result.ok(uuids);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.PROFILE_UUID_FAILED, err));
    }
  }

  async getPairedDevices(): Promise<Result<Array<PlatformPairedDevice>>> {
    try {
      const deviceIds: Array<string> = connection.getPairedDevices();
      const devices: PlatformPairedDevice[] = [];
      for (let i = 0; i < deviceIds.length; i++) {
        const deviceId = deviceIds[i];
        let deviceName = deviceId;
        try {
          const remoteName = connection.getRemoteDeviceName(deviceId);
          if (remoteName.length > 0) {
            deviceName = remoteName;
          }
        } catch (_error) {
          // Name lookup is best-effort; virtual MAC remains the fallback label.
        }
        devices.push(new PlatformPairedDevice(deviceId, deviceName, 0));
      }
      return Result.ok(devices);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.CLASSIC_UNAVAILABLE, err));
    }
  }

  async getPairState(deviceId: string): Promise<Result<PairingState>> {
    try {
      const state = connection.getPairState(deviceId);
      return Result.ok(BluetoothDeviceMapper.pairStateFromPlatform(state));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.CLASSIC_UNAVAILABLE, err));
    }
  }

  async isBluetoothDiscovering(): Promise<Result<boolean>> {
    try {
      return Result.ok(connection.isBluetoothDiscovering());
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.CLASSIC_UNAVAILABLE, err));
    }
  }

  async startBluetoothDiscovery(): Promise<Result<void>> {
    try {
      connection.startBluetoothDiscovery();
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.SCAN_RESOURCE_FAILED, err));
    }
  }

  async stopBluetoothDiscovery(): Promise<Result<void>> {
    try {
      connection.stopBluetoothDiscovery();
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.CLASSIC_UNAVAILABLE, err));
    }
  }

  onDiscoveryResult(listener: DiscoveryResultListener): Result<void> {
    this.offDiscoveryResult();
    this.discoveryListener = listener;
    this.discoveryResultHandler = (results: Array<connection.DiscoveryResult>) => {
      for (let i = 0; i < results.length; i++) {
        const item = results[i];
        const payload = new PlatformDiscoveryPayload(
          item.deviceId,
          item.deviceName ?? item.deviceId,
          item.rssi ?? 0,
          typeof item.deviceClass === 'number' ? item.deviceClass : 0,
          false
        );
        listener(payload);
      }
    };
    const discoveryRegistered =
      ConnectivityKitEventBridge.subscribeDiscoveryResult(this.discoveryResultHandler);
    if (!discoveryRegistered.success) {
      this.discoveryResultHandler = undefined;
      this.discoveryListener = undefined;
      return discoveryRegistered;
    }
    this.deviceFindHandler = (deviceIds: Array<string>) => {
      for (let i = 0; i < deviceIds.length; i++) {
        const payload = new PlatformDiscoveryPayload(deviceIds[i], deviceIds[i], 0, 0, true);
        listener(payload);
      }
    };
    return ConnectivityKitEventBridge.subscribeBluetoothDeviceFind(this.deviceFindHandler);
  }

  offDiscoveryResult(): void {
    if (this.discoveryResultHandler !== undefined) {
      ConnectivityKitEventBridge.unsubscribeDiscoveryResult(this.discoveryResultHandler);
      this.discoveryResultHandler = undefined;
    }
    if (this.deviceFindHandler !== undefined) {
      ConnectivityKitEventBridge.unsubscribeBluetoothDeviceFind(this.deviceFindHandler);
      this.deviceFindHandler = undefined;
    }
    this.discoveryListener = undefined;
  }

  onBondStateChange(listener: BondStateListener): Result<void> {
    this.offBondStateChange();
    this.bondListener = listener;
    this.bondHandler = (param: connection.BondStateParam) => {
      const state = BluetoothDeviceMapper.pairStateFromPlatform(param.state);
      listener(new PairingEvent(param.deviceId, state, Date.now()));
    };
    return ConnectivityKitEventBridge.subscribeBondStateChange(this.bondHandler);
  }

  offBondStateChange(): void {
    if (this.bondHandler !== undefined) {
      ConnectivityKitEventBridge.unsubscribeBondStateChange(this.bondHandler);
      this.bondHandler = undefined;
    }
    this.bondListener = undefined;
  }

  async pairDevice(deviceId: string): Promise<Result<void>> {
    try {
      await connection.pairDevice(deviceId);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      if (err.code === 2900001) {
        return Result.fail(new ResultError(BluetoothErrorCodes.PAIRING_CANCELLED, err.message, err));
      }
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.CLASSIC_UNAVAILABLE, err));
    }
  }
}
