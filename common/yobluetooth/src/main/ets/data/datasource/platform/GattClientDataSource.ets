import { ble, constant } from '@kit.ConnectivityKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothPlatformCodes } from '../../../constants/BluetoothPlatformCodes';
import { ConnectionParamPreset } from '../../../domain/model/ConnectionParamPreset';
import { ConnectivityKitEventBridge } from '../../kit/ConnectivityKitEventBridge';

type ConnectionStateListener = (state: ble.BLEConnectionChangeState) => void;
type CharacteristicChangeListener = (characteristic: ble.BLECharacteristic) => void;

/**
 * GATT client platform wrapper per WSL bpta-bluetooth-low-energy and architecture bluetooth/03-§4.
 */
export class GattClientDataSource {
  private client: ble.GattClientDevice | undefined;
  private connectionHandler: ConnectionStateListener | undefined;
  private characteristicHandler: CharacteristicChangeListener | undefined;
  private cachedServices: Array<ble.GattService> = [];
  private negotiatedMtu: number = BluetoothConstants.BLE_DEFAULT_MTU;
  private mtuPending: boolean = false;
  private mtuHandler: ((mtuSize: number) => void) | undefined;
  private servicesReady: boolean = false;

  createClient(bleDeviceId: string): Result<void> {
    try {
      this.release();
      this.client = ble.createGattClientDevice(bleDeviceId);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, err));
    }
  }

  onConnectionStateChange(listener: ConnectionStateListener): Result<void> {
    this.offConnectionStateChange();
    if (this.client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, 'GATT client not created'));
    }
    this.connectionHandler = listener;
    return ConnectivityKitEventBridge.subscribeGattConnectionStateChange(this.client, this.connectionHandler);
  }

  offConnectionStateChange(): void {
    if (this.client !== undefined && this.connectionHandler !== undefined) {
      ConnectivityKitEventBridge.unsubscribeGattConnectionStateChange(this.client, this.connectionHandler);
    }
    this.connectionHandler = undefined;
  }

  connect(): Result<void> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, 'GATT client not created'));
      }
      this.client.connect();
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, err));
    }
  }

  waitForConnected(timeoutMs: number): Promise<Result<void>> {
    return new Promise((resolve: (value: Result<void>) => void) => {
      if (this.client === undefined) {
        resolve(Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, 'GATT client not created')));
        return;
      }
      let settled = false;
      const timer = setTimeout(() => {
        if (!settled) {
          settled = true;
          this.offConnectionStateChange();
          resolve(Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, 'GATT connect timeout')));
        }
      }, timeoutMs);
      this.onConnectionStateChange((state: ble.BLEConnectionChangeState) => {
        if (settled) {
          return;
        }
        if (state.state === constant.ProfileConnectionState.STATE_CONNECTED) {
          settled = true;
          clearTimeout(timer);
          resolve(Result.ok(undefined));
        }
        if (state.state === constant.ProfileConnectionState.STATE_DISCONNECTED) {
          settled = true;
          clearTimeout(timer);
          resolve(Result.fail(new ResultError(BluetoothErrorCodes.DISCONNECTED, 'GATT disconnected during connect')));
        }
      });
      const started = this.connect();
      if (!started.success) {
        settled = true;
        clearTimeout(timer);
        resolve(started);
      }
    });
  }

  async discoverServices(): Promise<Result<Array<ble.GattService>>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'GATT client not created'));
      }
      const services = await this.client.getServices();
      this.cachedServices = services;
      this.servicesReady = true;
      return Result.ok(services);
    } catch (error) {
      this.servicesReady = false;
      const err = error as BusinessError;
      return Result.fail(GattClientDataSource.mapError(err, BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED));
    }
  }

  hasServiceTree(): boolean {
    return this.servicesReady;
  }

  currentMtu(): number {
    return this.negotiatedMtu;
  }

  isMtuPending(): boolean {
    return this.mtuPending;
  }

  onCharacteristicChange(listener: CharacteristicChangeListener): Result<void> {
    this.offCharacteristicChange();
    if (this.client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, 'GATT client not created'));
    }
    this.characteristicHandler = listener;
    return ConnectivityKitEventBridge.subscribeGattCharacteristicChange(this.client, this.characteristicHandler);
  }

  offCharacteristicChange(): void {
    if (this.client !== undefined && this.characteristicHandler !== undefined) {
      ConnectivityKitEventBridge.unsubscribeGattCharacteristicChange(this.client, this.characteristicHandler);
    }
    this.characteristicHandler = undefined;
  }

  async enableNotification(characteristic: ble.BLECharacteristic): Promise<Result<void>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(BluetoothErrorCodes.BLE_NOTIFY_FAILED, 'GATT client not created'));
      }
      await this.client.setCharacteristicChangeNotification(characteristic, true);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(GattClientDataSource.mapError(err, BluetoothErrorCodes.BLE_NOTIFY_FAILED));
    }
  }

  async disableNotification(characteristic: ble.BLECharacteristic): Promise<Result<void>> {
    try {
      if (this.client === undefined) {
        return Result.ok(undefined);
      }
      await this.client.setCharacteristicChangeNotification(characteristic, false);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.BLE_NOTIFY_FAILED, err));
    }
  }

  async writeCharacteristic(
    characteristic: ble.BLECharacteristic,
    bytes: Uint8Array,
    noResponse: boolean = false
  ): Promise<Result<void>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT client not created'));
      }
      const buffer = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
      const payload: ble.BLECharacteristic = {
        serviceUuid: characteristic.serviceUuid,
        characteristicUuid: characteristic.characteristicUuid,
        characteristicValue: buffer,
        descriptors: characteristic.descriptors ?? []
      };
      const writeType = noResponse ? ble.GattWriteType.WRITE_NO_RESPONSE : ble.GattWriteType.WRITE;
      await this.client.writeCharacteristicValue(payload, writeType);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(GattClientDataSource.mapError(err, BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED));
    }
  }

  async requestMtu(mtu: number): Promise<Result<number>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(BluetoothErrorCodes.BLE_MTU_FAILED, 'GATT client not created'));
      }
      this.mtuPending = true;
      if (this.mtuHandler !== undefined) {
        this.client.off('BLEMtuChange', this.mtuHandler);
      }
      this.mtuHandler = (mtuSize: number): void => {
        this.negotiatedMtu = mtuSize;
        this.mtuPending = false;
      };
      this.client.on('BLEMtuChange', this.mtuHandler);
      await this.client.setBLEMtuSize(mtu);
      return Result.ok(this.negotiatedMtu);
    } catch (error) {
      this.mtuPending = false;
      const err = error as BusinessError;
      return Result.fail(GattClientDataSource.mapError(err, BluetoothErrorCodes.BLE_MTU_FAILED));
    }
  }

  async readRssi(): Promise<Result<number>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT client not created'));
      }
      const rssi = await this.client.getRssiValue();
      return Result.ok(rssi);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(GattClientDataSource.mapError(err, BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED));
    }
  }

  async updateConnectionParam(preset: ConnectionParamPreset): Promise<Result<void>> {
    if (deviceInfo.sdkApiVersion < BluetoothConstants.SPP_SOCKET_QUERY_API) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.CAPABILITY_UNSUPPORTED,
        'updateConnectionParam requires API 22'
      ));
    }
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT client not created'));
      }
      await this.client.updateConnectionParam(GattClientDataSource.toConnectionParam(preset));
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(GattClientDataSource.mapError(err, BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED));
    }
  }

  async readCharacteristic(characteristic: ble.BLECharacteristic): Promise<Result<ble.BLECharacteristic>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT client not created'));
      }
      const result = await this.client.readCharacteristicValue(characteristic);
      return Result.ok(result);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, err));
    }
  }

  async readDescriptor(descriptor: ble.BLEDescriptor): Promise<Result<ble.BLEDescriptor>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT client not created'));
      }
      const result = await this.client.readDescriptorValue(descriptor);
      return Result.ok(result);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, err));
    }
  }

  async writeDescriptor(descriptor: ble.BLEDescriptor): Promise<Result<void>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT client not created'));
      }
      await this.client.writeDescriptorValue(descriptor);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, err));
    }
  }

  async writeDescriptorByUuid(
    serviceUuid: string,
    characteristicUuid: string,
    descriptorUuid: string,
    bytes: Uint8Array
  ): Promise<Result<void>> {
    const descriptor = this.findDescriptor(serviceUuid, characteristicUuid, descriptorUuid);
    if (descriptor === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'Descriptor not found'));
    }
    const buffer = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
    const payload: ble.BLEDescriptor = {
      serviceUuid: descriptor.serviceUuid,
      characteristicUuid: descriptor.characteristicUuid,
      descriptorUuid: descriptor.descriptorUuid,
      descriptorValue: buffer
    };
    return this.writeDescriptor(payload);
  }

  async enableIndication(characteristic: ble.BLECharacteristic): Promise<Result<void>> {
    try {
      if (this.client === undefined) {
        return Result.fail(new ResultError(BluetoothErrorCodes.BLE_NOTIFY_FAILED, 'GATT client not created'));
      }
      await this.client.setCharacteristicChangeIndication(characteristic, true);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(GattClientDataSource.mapError(err, BluetoothErrorCodes.BLE_NOTIFY_FAILED));
    }
  }

  async disableIndication(characteristic: ble.BLECharacteristic): Promise<Result<void>> {
    try {
      if (this.client === undefined) {
        return Result.ok(undefined);
      }
      await this.client.setCharacteristicChangeIndication(characteristic, false);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.BLE_NOTIFY_FAILED, err));
    }
  }

  getClient(): ble.GattClientDevice | undefined {
    return this.client;
  }

  findCharacteristic(serviceUuid: string, characteristicUuid: string): ble.BLECharacteristic | undefined {
    for (let i = 0; i < this.cachedServices.length; i++) {
      const service = this.cachedServices[i];
      if (service.serviceUuid.toUpperCase() !== serviceUuid.toUpperCase()) {
        continue;
      }
      const chars = service.characteristics ?? [];
      for (let j = 0; j < chars.length; j++) {
        if (chars[j].characteristicUuid.toUpperCase() === characteristicUuid.toUpperCase()) {
          return chars[j];
        }
      }
    }
    return undefined;
  }

  findDescriptor(
    serviceUuid: string,
    characteristicUuid: string,
    descriptorUuid: string
  ): ble.BLEDescriptor | undefined {
    const characteristic = this.findCharacteristic(serviceUuid, characteristicUuid);
    if (characteristic === undefined) {
      return undefined;
    }
    const descriptors = characteristic.descriptors ?? [];
    for (let i = 0; i < descriptors.length; i++) {
      if (descriptors[i].descriptorUuid.toUpperCase() === descriptorUuid.toUpperCase()) {
        return descriptors[i];
      }
    }
    return undefined;
  }

  disconnect(): Result<void> {
    try {
      if (this.client !== undefined) {
        this.client.disconnect();
      }
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.DISCONNECTED, err));
    }
  }

  close(): Result<void> {
    try {
      if (this.client !== undefined) {
        this.client.close();
      }
      this.client = undefined;
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, err));
    }
  }

  release(): void {
    this.cachedServices = [];
    this.servicesReady = false;
    this.negotiatedMtu = BluetoothConstants.BLE_DEFAULT_MTU;
    this.mtuPending = false;
    this.mtuHandler = undefined;
    this.offCharacteristicChange();
    this.offConnectionStateChange();
    this.disconnect();
    this.close();
  }

  private static toConnectionParam(preset: ConnectionParamPreset): ble.ConnectionParam {
    if (preset === ConnectionParamPreset.LOW_POWER) {
      return ble.ConnectionParam.LOW_POWER;
    }
    if (preset === ConnectionParamPreset.HIGH) {
      return ble.ConnectionParam.HIGH;
    }
    return ble.ConnectionParam.BALANCED;
  }

  private static mapError(err: BusinessError, fallback: string): ResultError {
    const mapped = BluetoothPlatformCodes.domainCode(err.code);
    const code = mapped.length > 0 ? mapped : fallback;
    return ResultError.fromBusinessError(code, err);
  }
}
