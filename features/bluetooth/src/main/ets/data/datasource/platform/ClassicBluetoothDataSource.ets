import { access, connection } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Observable, Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothAdapterSnapshot } from '../../../domain/model/BluetoothDevice';
import {
  BluetoothTransportPolicy,
  BluetoothTransportType
} from '../../../domain/model/BluetoothTransportType';
import { PairingEvent, PairingState } from '../../../domain/model/PairingState';
import {
  BluetoothDeviceMapper,
  PlatformPairedSnapshot
} from '../../mapper/BluetoothDeviceMapper';
import { ConnectivityKitEventBridge } from '../../kit/ConnectivityKitEventBridge';

export class PlatformDiscoveryPayload {
  readonly classicDeviceId: string;
  readonly deviceName: string;
  readonly rssi: number;
  readonly deviceClass: number;
  readonly majorClass: number;
  readonly majorMinorClass: number;
  readonly fromLegacyFind: boolean;

  constructor(
    classicDeviceId: string,
    deviceName: string,
    rssi: number,
    deviceClass: number,
    fromLegacyFind: boolean = false,
    majorClass: number = 0,
    majorMinorClass: number = 0
  ) {
    this.classicDeviceId = classicDeviceId;
    this.deviceName = deviceName;
    this.rssi = rssi;
    this.deviceClass = deviceClass;
    this.fromLegacyFind = fromLegacyFind;
    this.majorClass = majorClass;
    this.majorMinorClass = majorMinorClass;
  }
}

type DiscoveryResultListener = (payload: PlatformDiscoveryPayload) => void;
type BondStateListener = (event: PairingEvent) => void;
type AdapterStateListener = (snapshot: BluetoothAdapterSnapshot) => void;

/**
 * Platform wrapper for classic Bluetooth adapter, discovery, pairing and transport APIs.
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

  getRemoteDeviceTransport(deviceId: string): Result<BluetoothTransportType> {
    try {
      const code = connection.getRemoteDeviceTransport(deviceId) as number;
      return Result.ok(BluetoothTransportPolicy.fromPlatformCode(code));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.TRANSPORT_QUERY_FAILED, err));
    }
  }

  getRemoteDeviceClassCod(deviceId: string): Result<DeviceClassCod> {
    try {
      const deviceClass = connection.getRemoteDeviceClass(deviceId);
      return Result.ok(ClassicBluetoothDataSource.parseDeviceClass(deviceClass));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.CLASSIC_UNAVAILABLE, err));
    }
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

  getRemoteDeviceNameSafe(deviceId: string): string {
    try {
      const remoteName = connection.getRemoteDeviceName(deviceId);
      if (remoteName.length > 0) {
        return remoteName;
      }
    } catch (_error) {
      // best-effort
    }
    return deviceId;
  }

  /**
   * Full paired snapshots with transport + CoD. Application filters by rail.
   */
  async getPairedDeviceSnapshots(): Promise<Result<Array<PlatformPairedSnapshot>>> {
    try {
      const deviceIds: Array<string> = connection.getPairedDevices();
      const devices: PlatformPairedSnapshot[] = [];
      for (let i = 0; i < deviceIds.length; i++) {
        const deviceId = deviceIds[i];
        const deviceName = this.getRemoteDeviceNameSafe(deviceId);
        let transport = BluetoothTransportType.UNKNOWN;
        const transportResult = this.getRemoteDeviceTransport(deviceId);
        if (transportResult.success && transportResult.value !== undefined) {
          transport = transportResult.value;
        }
        let deviceClassCod = 0;
        let majorClass = 0;
        let majorMinorClass = 0;
        const codResult = this.getRemoteDeviceClassCod(deviceId);
        if (codResult.success && codResult.value !== undefined) {
          deviceClassCod = codResult.value.classOfDevice;
          majorClass = codResult.value.majorClass;
          majorMinorClass = codResult.value.majorMinorClass;
        }
        devices.push(new PlatformPairedSnapshot(
          deviceId,
          deviceName,
          transport,
          deviceClassCod,
          majorClass,
          majorMinorClass
        ));
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
        const cod = ClassicBluetoothDataSource.parseDeviceClass(item.deviceClass);
        const payload = new PlatformDiscoveryPayload(
          item.deviceId,
          item.deviceName ?? item.deviceId,
          item.rssi ?? 0,
          cod.classOfDevice,
          false,
          cod.majorClass,
          cod.majorMinorClass
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

  private static parseDeviceClass(deviceClass: connection.DeviceClass | number | undefined): DeviceClassCod {
    if (deviceClass === undefined) {
      return new DeviceClassCod(0, 0, 0);
    }
    if (typeof deviceClass === 'number') {
      return new DeviceClassCod(deviceClass, 0, 0);
    }
    const major = typeof deviceClass.majorClass === 'number' ? deviceClass.majorClass : 0;
    const minor = typeof deviceClass.majorMinorClass === 'number' ? deviceClass.majorMinorClass : 0;
    const cod = typeof deviceClass.classOfDevice === 'number' ? deviceClass.classOfDevice : 0;
    return new DeviceClassCod(cod, major, minor);
  }
}

export class DeviceClassCod {
  readonly classOfDevice: number;
  readonly majorClass: number;
  readonly majorMinorClass: number;

  constructor(classOfDevice: number, majorClass: number, majorMinorClass: number) {
    this.classOfDevice = classOfDevice;
    this.majorClass = majorClass;
    this.majorMinorClass = majorMinorClass;
  }
}
