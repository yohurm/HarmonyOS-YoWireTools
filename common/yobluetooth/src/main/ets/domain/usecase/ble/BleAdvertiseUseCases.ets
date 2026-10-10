import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { AdvertisingRequest } from '../../model/AdvertisingRequest';
import { BluetoothRepositoryContract } from '../../repository/BluetoothRepositoryContract';
import { bluetoothRepository } from '../../repository/BluetoothRepositories';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';

export class StartBleAdvertiseUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly guard: BluetoothOperationGuard;

  constructor(
    repository: BluetoothRepositoryContract = bluetoothRepository(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard()
  ) {
    this.repository = repository;
    this.guard = guard;
  }

  async execute(request: AdvertisingRequest): Promise<Result<void>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    return this.repository.startBleAdvertise(request);
  }
}

export class StopBleAdvertiseUseCase {
  private readonly repository: BluetoothRepositoryContract;

  constructor(repository: BluetoothRepositoryContract = bluetoothRepository()) {
    this.repository = repository;
  }

  async execute(): Promise<Result<void>> {
    return this.repository.stopBleAdvertise();
  }
}
