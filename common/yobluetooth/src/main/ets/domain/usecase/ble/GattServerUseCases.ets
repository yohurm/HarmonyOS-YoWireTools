import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothRepositoryContract } from '../../repository/BluetoothRepositoryContract';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';

export class OpenGattServerUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly guard: BluetoothOperationGuard;

  constructor(
    repository: BluetoothRepositoryContract,
    guard: BluetoothOperationGuard
  ) {
    this.repository = repository;
    this.guard = guard;
  }

  async execute(
    serviceUuid: string,
    characteristicUuid: string,
    value: Uint8Array
  ): Promise<Result<void>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    return this.repository.openGattServer(serviceUuid, characteristicUuid, value);
  }
}

export class CloseGattServerUseCase {
  private readonly repository: BluetoothRepositoryContract;

  constructor(repository: BluetoothRepositoryContract) {
    this.repository = repository;
  }

  execute(): Result<void> {
    return this.repository.closeGattServer();
  }
}

export class NotifyGattServerUseCase {
  private readonly repository: BluetoothRepositoryContract;

  constructor(repository: BluetoothRepositoryContract) {
    this.repository = repository;
  }

  execute(
    deviceId: string,
    serviceUuid: string,
    characteristicUuid: string,
    value: Uint8Array,
    confirm: boolean
  ): Result<void> {
    return this.repository.notifyGattServer(deviceId, serviceUuid, characteristicUuid, value, confirm);
  }
}
