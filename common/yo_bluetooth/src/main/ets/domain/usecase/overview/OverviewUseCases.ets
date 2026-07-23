import { Result } from 'common_core';
import { EnsurePermissionUseCase, PermissionScenario } from 'debug_core';
import { PermissionDecision } from 'common_platform';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';
import {
  BluetoothCapabilitySnapshot,
  BluetoothDevice,
  BluetoothOverviewSnapshot
} from '../../model/BluetoothDevice';
import { BluetoothSubscriptionBundle } from '../shared/BluetoothSubscriptionBundle';

export class LoadBluetoothOverviewUseCase {
  private readonly repository: BluetoothRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
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
  private readonly repository: BluetoothRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
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
  private readonly repository: BluetoothRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(): Promise<Result<BluetoothCapabilitySnapshot>> {
    const permission: PermissionDecision =
      await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    const adapter = await this.repository.loadAdapterState();
    const adapterOn = adapter.success && adapter.value !== undefined && adapter.value.enabled;
    return Result.ok(new BluetoothCapabilitySnapshot(permission.granted, adapterOn === true));
  }
}

export class ObserveBluetoothDevicesUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
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
