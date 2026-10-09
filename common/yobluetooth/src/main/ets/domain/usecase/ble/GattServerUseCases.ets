import { ble } from '@kit.ConnectivityKit';
import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { GattServerDataSource } from '../../../data/datasource/platform/GattServerDataSource';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';

export class OpenGattServerUseCase {
  private readonly server: GattServerDataSource;
  private readonly guard: BluetoothOperationGuard;

  constructor(
    server: GattServerDataSource = new GattServerDataSource(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard()
  ) {
    this.server = server;
    this.guard = guard;
  }

  async execute(service: ble.GattService): Promise<Result<void>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    const opened = this.server.openServer();
    if (!opened.success) {
      return opened;
    }
    return this.server.addService(service);
  }

  source(): GattServerDataSource {
    return this.server;
  }
}

export class CloseGattServerUseCase {
  private readonly server: GattServerDataSource;

  constructor(server: GattServerDataSource) {
    this.server = server;
  }

  execute(): Result<void> {
    return this.server.closeServer();
  }
}

export class NotifyGattServerUseCase {
  private readonly server: GattServerDataSource;

  constructor(server: GattServerDataSource) {
    this.server = server;
  }

  execute(deviceId: string, characteristic: ble.NotifyCharacteristic): Result<void> {
    if (!this.server.isOpen()) {
      return Result.fail(new ResultError(BluetoothErrorCodes.GATT_NOT_CONNECTED, 'GATT server is closed'));
    }
    return this.server.notify(deviceId, characteristic);
  }
}
