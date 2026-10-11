import { Result } from 'common_core';
import { BluetoothRepositoryContract } from '../../repository/BluetoothRepositoryContract';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';

/**
 * Switch requests. The adapter state callback remains the source of truth,
 * not the promise returned by enable or disable.
 */
export class EnableBluetoothUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly guard: BluetoothOperationGuard;

  constructor(
    repository: BluetoothRepositoryContract,
    guard: BluetoothOperationGuard
  ) {
    this.repository = repository;
    this.guard = guard;
  }

  async execute(): Promise<Result<void>> {
    const permission = await this.guard.ensurePermissionGranted();
    if (!permission.success) {
      return permission;
    }
    return this.repository.enableBluetooth();
  }
}

export class DisableBluetoothUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly guard: BluetoothOperationGuard;

  constructor(
    repository: BluetoothRepositoryContract,
    guard: BluetoothOperationGuard
  ) {
    this.repository = repository;
    this.guard = guard;
  }

  async execute(): Promise<Result<void>> {
    const permission = await this.guard.ensurePermissionGranted();
    if (!permission.success) {
      return permission;
    }
    return this.repository.disableBluetooth();
  }
}
