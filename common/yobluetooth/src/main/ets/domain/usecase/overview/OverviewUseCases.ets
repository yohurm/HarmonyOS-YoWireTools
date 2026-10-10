import { Result } from 'common_core';
import { EnsurePermissionUseCase, PermissionScenario } from 'debug_core';
import { PermissionDecision } from 'common_platform';
import { BluetoothRepositoryContract } from '../../repository/BluetoothRepositoryContract';
import { bluetoothRepository } from '../../repository/BluetoothRepositories';
import {
  BluetoothCapabilitySnapshot,
  BluetoothDevice,
  BluetoothOverviewSnapshot
} from '../../model/BluetoothDevice';
import { BluetoothSubscriptionBundle } from '../shared/BluetoothSubscriptionBundle';

export class LoadBluetoothOverviewUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: BluetoothRepositoryContract = bluetoothRepository(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(): Promise<Result<BluetoothDevice[]>> {
    const permission: PermissionDecision = await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    if (!permission.granted) {
      return Result.ok([]);
    }
    return this.repository.loadPairedClassicCandidates();
  }
}

export class LoadBluetoothOverviewSnapshotUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: BluetoothRepositoryContract = bluetoothRepository(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(): Promise<Result<BluetoothOverviewSnapshot>> {
    const permission: PermissionDecision =
      await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    const overview = await this.repository.loadOverview(permission.granted);
    return Result.ok(overview);
  }
}

export class ResolveBluetoothCapabilityUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: BluetoothRepositoryContract = bluetoothRepository(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(): Promise<Result<BluetoothCapabilitySnapshot>> {
    const permission: PermissionDecision =
      await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    const adapter = await this.repository.getAdapterState();
    const adapterOn = adapter.success && adapter.value !== undefined && adapter.value.enabled;
    return Result.ok(new BluetoothCapabilitySnapshot(permission.granted, adapterOn === true));
  }
}

export class ObserveBluetoothDevicesUseCase {
  private readonly repository: BluetoothRepositoryContract;

  constructor(repository: BluetoothRepositoryContract = bluetoothRepository()) {
    this.repository = repository;
  }

  execute(
    onClassic: (devices: BluetoothDevice[]) => void,
    onBle: (devices: BluetoothDevice[]) => void
  ): BluetoothSubscriptionBundle {
    const classic = this.repository.observeClassicDevices().subscribe(onClassic);
    const ble = this.repository.observeBleDevices().subscribe(onBle);
    return new BluetoothSubscriptionBundle(classic, ble);
  }
}
