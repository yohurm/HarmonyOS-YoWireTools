import { ble } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothPlatformCodes } from '../../../constants/BluetoothPlatformCodes';

/**
 * Local GATT server. Every read or write request is answered with sendResponse.
 */
export class GattServerDataSource {
  private server: ble.GattServer | undefined;
  private open: boolean = false;
  private readonly values: Map<string, ArrayBuffer> = new Map();

  isOpen(): boolean {
    return this.open;
  }

  openServer(): Result<void> {
    try {
      this.closeServer();
      this.server = ble.createGattServer();
      this.bindRequests();
      this.open = true;
      return Result.ok(undefined);
    } catch (error) {
      this.open = false;
      const err = error as BusinessError;
      return Result.fail(GattServerDataSource.mapError(err));
    }
  }

  addService(service: ble.GattService): Result<void> {
    try {
      if (this.server === undefined) {
        return Result.fail(new ResultError(BluetoothErrorCodes.GATT_NOT_CONNECTED, 'GATT server is closed'));
      }
      this.server.addService(service);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(GattServerDataSource.mapError(err));
    }
  }

  setValue(serviceUuid: string, characteristicUuid: string, bytes: Uint8Array): void {
    const key = GattServerDataSource.key(serviceUuid, characteristicUuid);
    const copy = new ArrayBuffer(bytes.byteLength);
    new Uint8Array(copy).set(bytes);
    this.values.set(key, copy);
  }

  notify(deviceId: string, characteristic: ble.NotifyCharacteristic): Result<void> {
    try {
      if (this.server === undefined || !this.open) {
        return Result.fail(new ResultError(BluetoothErrorCodes.GATT_NOT_CONNECTED, 'GATT server is closed'));
      }
      this.server.notifyCharacteristicChanged(deviceId, characteristic);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(GattServerDataSource.mapError(err));
    }
  }

  closeServer(): Result<void> {
    try {
      if (this.server !== undefined) {
        this.server.close();
      }
      this.server = undefined;
      this.open = false;
      this.values.clear();
      return Result.ok(undefined);
    } catch (error) {
      this.server = undefined;
      this.open = false;
      const err = error as BusinessError;
      return Result.fail(GattServerDataSource.mapError(err));
    }
  }

  private bindRequests(): void {
    if (this.server === undefined) {
      return;
    }
    this.server.on('characteristicRead', (request: ble.CharacteristicReadRequest) => {
      if (!this.open || this.server === undefined) {
        return;
      }
      const stored = this.values.get(GattServerDataSource.key(request.serviceUuid, request.characteristicUuid));
      const value = stored !== undefined ? stored : new ArrayBuffer(0);
      this.server.sendResponse({
        deviceId: request.deviceId,
        transId: request.transId,
        status: 0,
        offset: request.offset,
        value: value
      });
    });
    this.server.on('characteristicWrite', (request: ble.CharacteristicWriteRequest) => {
      if (!this.open || this.server === undefined) {
        return;
      }
      if (request.value !== undefined) {
        this.values.set(
          GattServerDataSource.key(request.serviceUuid, request.characteristicUuid),
          request.value
        );
      }
      this.server.sendResponse({
        deviceId: request.deviceId,
        transId: request.transId,
        status: 0,
        offset: request.offset,
        value: new ArrayBuffer(0)
      });
    });
  }

  private static key(serviceUuid: string, characteristicUuid: string): string {
    return `${serviceUuid.toUpperCase()}|${characteristicUuid.toUpperCase()}`;
  }

  private static mapError(err: BusinessError): ResultError {
    const mapped = BluetoothPlatformCodes.domainCode(err.code);
    const code = mapped.length > 0 ? mapped : BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED;
    return ResultError.fromBusinessError(code, err);
  }
}
