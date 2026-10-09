import { Result, ResultError, Subscription } from 'common_core';
import {
  AppMode,
  CapabilityId,
  CreateSessionInput,
  CreateSessionUseCase,
  DebugTarget,
  EnsurePermissionUseCase,
  ModuleType,
  PermissionScenario,
  ProtocolType,
  SessionType,
  StartSessionUseCase,
  StopSessionUseCase
} from 'debug_core';
import { PermissionDecision } from 'common_platform';
import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';
import { NearLinkRepository } from '../../data/repository/NearLinkRepository';
import { NearLinkAdapterSnapshot, NearLinkDevice, NearLinkCapabilitySnapshot } from '../model/NearLinkDevice';
import { NearLinkScanFilter } from '../model/NearLinkScanFilter';
import { NearLinkScanPhase } from '../model/NearLinkScanPhase';
import { CapabilityResult } from 'common_platform';
import { NearLinkCapabilityService } from '../service/NearLinkCapabilityService';
import { NearLinkScanLogger } from '../service/NearLinkScanLogger';

export class StartNearLinkScanUseCase {
  private readonly repository: NearLinkRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;

  constructor(
    repository: NearLinkRepository = NearLinkRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
  }

  async execute(filter: NearLinkScanFilter): Promise<Result<string>> {
    const permission: PermissionDecision = await this.ensurePermission.execute(PermissionScenario.NEARLINK_ACCESS);
    if (!permission.granted) {
      return Result.fail(new ResultError(NearLinkErrorCodes.PERMISSION_DENIED, 'NearLink permission denied'));
    }
    const adapter = await this.repository.loadAdapterState();
    if (!adapter.success || adapter.value === undefined || !adapter.value.supported) {
      return Result.fail(new ResultError(NearLinkErrorCodes.UNSUPPORTED, 'NearLink unsupported'));
    }
    if (!adapter.value.enabled) {
      return Result.fail(new ResultError(NearLinkErrorCodes.SWITCH_OFF, 'NearLink switch off'));
    }
    const input = new CreateSessionInput(
      SessionType.SCAN,
      ModuleType.NEARLINK,
      ProtocolType.NEARLINK_SCAN,
      'NearLink Scan',
      AppMode.EXPERT
    );
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const started = await this.startSession.execute(created.value.id);
    if (!started.success) {
      return Result.fail(started.error ?? new ResultError('YW-SESSION-1003', 'Session start failed'));
    }
    const scan = this.repository.startScan(created.value.id, filter);
    if (!scan.success) {
      return Result.fail(scan.error ?? new ResultError(NearLinkErrorCodes.SCAN_FAILED, 'Scan failed'));
    }
    await NearLinkScanLogger.logScan(created.value.id, 'NearLink scan started');
    return Result.ok(created.value.id);
  }
}

export class StopNearLinkScanUseCase {
  private readonly repository: NearLinkRepository;
  private readonly stopSession: StopSessionUseCase;

  constructor(
    repository: NearLinkRepository = NearLinkRepository.getInstance(),
    stopSession: StopSessionUseCase = new StopSessionUseCase()
  ) {
    this.repository = repository;
    this.stopSession = stopSession;
  }

  async execute(sessionId: string): Promise<Result<void>> {
    const stopped = this.repository.stopScan();
    if (!stopped.success) {
      return stopped;
    }
    if (sessionId.length > 0) {
      await NearLinkScanLogger.logScan(
        sessionId,
        `NearLink scan stopped, devices=${this.repository.listDevices().length}`
      );
      await this.stopSession.execute(sessionId, 'nearlink_scan_stopped');
    }
    this.repository.resetScanPhase();
    return Result.ok(undefined);
  }
}

export class LoadNearLinkOverviewUseCase {
  private readonly repository: NearLinkRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: NearLinkRepository = NearLinkRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(): Promise<Result<NearLinkDevice[]>> {
    const permission: PermissionDecision = await this.ensurePermission.execute(PermissionScenario.NEARLINK_ACCESS);
    if (!permission.granted) {
      return Result.ok([]);
    }
    return Result.ok(this.repository.listDevices());
  }
}

export class ObserveNearLinkDevicesUseCase {
  private readonly repository: NearLinkRepository;

  constructor(repository: NearLinkRepository = NearLinkRepository.getInstance()) {
    this.repository = repository;
  }

  execute(listener: (devices: NearLinkDevice[]) => void): Subscription {
    return this.repository.observeDevices().subscribe(listener);
  }
}

export class ResolveNearLinkCapabilityUseCase {
  private readonly repository: NearLinkRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: NearLinkRepository = NearLinkRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(): Promise<Result<NearLinkCapabilitySnapshot>> {
    const permission: PermissionDecision = await this.ensurePermission.execute(PermissionScenario.NEARLINK_ACCESS);
    const adapter = await this.repository.loadAdapterState();
    const supported = adapter.success && adapter.value !== undefined && adapter.value.supported;
    const switchOn = adapter.success && adapter.value !== undefined && adapter.value.enabled;
    const capabilityResults: CapabilityResult[] = await NearLinkCapabilityService.probeAll();
    const scanCap = NearLinkCapabilityService.find(capabilityResults, CapabilityId.NEARLINK_SCAN);
    const readyForScan = permission.granted && supported === true && switchOn === true &&
      scanCap !== undefined && `${scanCap.status}` === 'available';
    const readyForConnect = readyForScan;
    return Result.ok(new NearLinkCapabilitySnapshot(
      permission.granted,
      supported === true,
      switchOn === true,
      readyForScan,
      readyForConnect
    ));
  }
}

export class ObserveNearLinkScanPhaseUseCase {
  private readonly repository: NearLinkRepository;

  constructor(repository: NearLinkRepository = NearLinkRepository.getInstance()) {
    this.repository = repository;
  }

  execute(listener: (phase: NearLinkScanPhase) => void): Subscription {
    return this.repository.observeScanPhase().subscribe(listener);
  }
}

export class ReadNearLinkScanFailureUseCase {
  private readonly repository: NearLinkRepository;

  constructor(repository: NearLinkRepository = NearLinkRepository.getInstance()) {
    this.repository = repository;
  }

  execute(): string {
    return this.repository.getLastScanFailureCode();
  }
}

export class ObserveNearLinkAdapterUseCase {
  private readonly repository: NearLinkRepository;

  constructor(repository: NearLinkRepository = NearLinkRepository.getInstance()) {
    this.repository = repository;
  }

  execute(listener: (snapshot: NearLinkAdapterSnapshot) => void): Subscription {
    return this.repository.observeAdapterState().subscribe(listener, false);
  }
}
