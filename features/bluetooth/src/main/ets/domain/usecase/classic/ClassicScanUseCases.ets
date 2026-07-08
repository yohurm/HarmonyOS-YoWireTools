import { Result, ResultError } from 'common_core';
import {
  AppMode,
  CreateSessionInput,
  ModuleType,
  ProtocolType,
  SessionType,
  StopSessionUseCase
} from 'feature_debug_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';
import { PairingCoordinator } from '../../service/PairingCoordinator';
import { PairingEvent } from '../../model/PairingState';
import { BluetoothScanLogger } from '../../service/BluetoothScanLogger';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';
import { BluetoothSessionBootstrap } from '../shared/BluetoothSessionBootstrap';

export class StartClassicScanUseCase {
  private readonly repository: BluetoothRepository;
  private readonly guard: BluetoothOperationGuard;
  private readonly sessionBootstrap: BluetoothSessionBootstrap;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard(),
    sessionBootstrap: BluetoothSessionBootstrap = new BluetoothSessionBootstrap()
  ) {
    this.repository = repository;
    this.guard = guard;
    this.sessionBootstrap = sessionBootstrap;
  }

  async execute(): Promise<Result<string>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    await this.repository.loadPairedDevices();
    const input = new CreateSessionInput(
      SessionType.SCAN,
      ModuleType.BLUETOOTH,
      ProtocolType.CLASSIC_SCAN,
      'Classic Bluetooth Scan',
      AppMode.EXPERT
    );
    const session = await this.sessionBootstrap.createAndStart(input);
    if (!session.success || session.value === undefined) {
      return Result.fail(session.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const discovery = await this.repository.startClassicDiscovery(session.value.id);
    if (!discovery.success) {
      return Result.fail(discovery.error ?? new ResultError(BluetoothErrorCodes.SCAN_RESOURCE_FAILED, 'Scan failed'));
    }
    await BluetoothScanLogger.logClassic(session.value.id, 'Classic scan started');
    return Result.ok(session.value.id);
  }
}

export class StopClassicScanUseCase {
  private readonly repository: BluetoothRepository;
  private readonly stopSession: StopSessionUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    stopSession: StopSessionUseCase = new StopSessionUseCase()
  ) {
    this.repository = repository;
    this.stopSession = stopSession;
  }

  async execute(sessionId: string): Promise<Result<void>> {
    const stopped = await this.repository.stopClassicDiscovery();
    if (!stopped.success) {
      return stopped;
    }
    if (sessionId.length > 0) {
      await BluetoothScanLogger.logClassic(
        sessionId,
        `Classic scan stopped, devices=${this.repository.listClassicDevices().length}`
      );
      await this.stopSession.execute(sessionId, 'scan_stopped');
    }
    this.repository.resetClassicScanPhase();
    return Result.ok(undefined);
  }
}

export class PairBluetoothDeviceUseCase {
  private readonly repository: BluetoothRepository;
  private readonly guard: BluetoothOperationGuard;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard()
  ) {
    this.repository = repository;
    this.guard = guard;
  }

  async execute(deviceId: string): Promise<Result<void>> {
    const permission = await this.guard.ensurePermissionGranted();
    if (!permission.success) {
      return permission;
    }
    return this.repository.pairDevice(deviceId);
  }
}

export class ObservePairingEventsUseCase {
  private readonly coordinator: PairingCoordinator;

  constructor(coordinator: PairingCoordinator = PairingCoordinator.getInstance()) {
    this.coordinator = coordinator;
  }

  execute(listener: (event: PairingEvent) => void) {
    return this.coordinator.subscribe(listener);
  }
}
