import { Result, ResultError } from 'common_core';
import { EnsurePermissionUseCase, PermissionScenario } from 'debug_core';
import { PermissionDecision } from 'common_platform';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';

/**
 * Shared permission and adapter preconditions for bluetooth use cases.
 */
export class BluetoothOperationGuard {
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly repository: BluetoothRepository;

  constructor(
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    repository: BluetoothRepository = BluetoothRepository.getInstance()
  ) {
    this.ensurePermission = ensurePermission;
    this.repository = repository;
  }

  async checkPermission(): Promise<PermissionDecision> {
    return this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
  }

  async ensurePermissionGranted(): Promise<Result<void>> {
    const permission = await this.checkPermission();
    if (!permission.granted) {
      return Result.fail(new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Bluetooth permission denied'));
    }
    return Result.ok(undefined);
  }

  async ensureAdapterOn(): Promise<Result<void>> {
    const adapter = await this.repository.loadAdapterState();
    if (!adapter.success || adapter.value === undefined || !adapter.value.enabled) {
      return Result.fail(new ResultError(BluetoothErrorCodes.ADAPTER_OFF, 'Bluetooth adapter is off'));
    }
    return Result.ok(undefined);
  }

  async ensureOperational(): Promise<Result<void>> {
    const permission = await this.ensurePermissionGranted();
    if (!permission.success) {
      return permission;
    }
    return this.ensureAdapterOn();
  }
}
