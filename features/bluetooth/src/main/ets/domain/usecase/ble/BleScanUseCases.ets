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
import { BleScanFilter } from '../../model/BleScanFilter';
import { BluetoothDevice } from '../../model/BluetoothDevice';
import { BluetoothScanLogger } from '../../service/BluetoothScanLogger';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';
import { BluetoothSessionBootstrap } from '../shared/BluetoothSessionBootstrap';

export class StartBleScanUseCase {
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

  async execute(serviceUuid: string = '', filter?: BleScanFilter): Promise<Result<string>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    await this.repository.loadPairedBleCandidates();
    const input = new CreateSessionInput(
      SessionType.SCAN,
      ModuleType.BLUETOOTH,
      ProtocolType.BLE_SCAN,
      'BLE Scan',
      AppMode.EXPERT
    );
    const session = await this.sessionBootstrap.createAndStart(input);
    if (!session.success || session.value === undefined) {
      return Result.fail(session.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const scanFilter: BleScanFilter = filter !== undefined ? filter : new BleScanFilter('', '', serviceUuid);
    const scan = this.repository.startBleScan(session.value.id, scanFilter);
    if (!scan.success) {
      return Result.fail(scan.error ?? new ResultError(BluetoothErrorCodes.BLE_SCAN_FAILED, 'BLE scan failed'));
    }
    await BluetoothScanLogger.logBle(session.value.id, 'BLE scan started');
    return Result.ok(session.value.id);
  }
}

export class StopBleScanUseCase {
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
    const stopped = this.repository.stopBleScan();
    if (!stopped.success) {
      return stopped;
    }
    if (sessionId.length > 0) {
      await BluetoothScanLogger.logBle(
        sessionId,
        `BLE scan stopped, devices=${this.repository.listBleDevices().length}`
      );
      await this.stopSession.execute(sessionId, 'ble_scan_stopped');
    }
    this.repository.resetBleScanPhase();
    return Result.ok(undefined);
  }
}

export class StartBleScanWithFilterUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  execute(sessionId: string, filter: BleScanFilter): Result<void> {
    return this.repository.startBleScan(sessionId, filter);
  }
}

export class LoadPairedBleDevicesUseCase {
  private readonly repository: BluetoothRepository;
  private readonly guard: BluetoothOperationGuard;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard()
  ) {
    this.repository = repository;
    this.guard = guard;
  }

  async execute(): Promise<Result<BluetoothDevice[]>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    return this.repository.loadPairedBleCandidates();
  }
}

export class ObserveBleDevicesUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  execute(listener: (devices: BluetoothDevice[]) => void): import('common_core').Subscription {
    return this.repository.observeBleDevices().subscribe(listener);
  }
}
