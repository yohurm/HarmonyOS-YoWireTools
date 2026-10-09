import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BleAdvertiserDataSource } from '../../../data/datasource/platform/BleAdvertiserDataSource';
import { AdvertisingRequest } from '../../model/AdvertisingRequest';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';

export class StartBleAdvertiseUseCase {
  private readonly advertiser: BleAdvertiserDataSource;
  private readonly guard: BluetoothOperationGuard;

  constructor(
    advertiser: BleAdvertiserDataSource = new BleAdvertiserDataSource(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard()
  ) {
    this.advertiser = advertiser;
    this.guard = guard;
  }

  async execute(request: AdvertisingRequest): Promise<Result<void>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    return this.advertiser.start(request);
  }

  source(): BleAdvertiserDataSource {
    return this.advertiser;
  }
}

export class StopBleAdvertiseUseCase {
  private readonly advertiser: BleAdvertiserDataSource;

  constructor(advertiser: BleAdvertiserDataSource) {
    this.advertiser = advertiser;
  }

  async execute(): Promise<Result<void>> {
    return this.advertiser.stop();
  }
}
