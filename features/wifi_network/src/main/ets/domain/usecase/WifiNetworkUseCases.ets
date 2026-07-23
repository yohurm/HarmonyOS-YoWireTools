import { Result, ResultError } from 'common_core';
import {
  AppMode,
  CreateSessionInput,
  CreateSessionUseCase,
  EnsurePermissionUseCase,
  ModuleType,
  PermissionScenario,
  ProtocolType,
  SessionType,
  StartSessionUseCase,
  StopSessionUseCase
} from 'debug_core';
import { WifiScanLogger } from '../service/WifiScanLogger';
import { WifiNetworkRepository } from '../../data/repository/WifiNetworkRepository';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { WifiOverviewSnapshot } from '../model/WifiOverviewSnapshot';
import { WifiAccessPointSnapshot } from '../model/WifiAccessPointSnapshot';
import { WifiScanPhase } from '../model/WifiScanState';
import { NetworkDiagnosticPlan, DiagnosticStepResult } from '../model/NetworkDiagnosticModels';
import { HttpRequestDraft, HttpResponseRecord } from '../model/HttpModels';
import { WebSocketConfig } from '../model/WebSocketModels';
import { LanDiscoveryConfig, LanHostResult, PortScanConfig, PortProbeResult } from '../model/LanDiscoveryModels';
import { SocketConnectionParams } from '../model/SocketModels';

export class ObserveWifiStateUseCase {
  private readonly repository: WifiNetworkRepository;

  constructor(repository: WifiNetworkRepository = WifiNetworkRepository.getInstance()) {
    this.repository = repository;
  }

  start(onChange: () => void): void {
    this.repository.onWifiStateChange(() => onChange());
    this.repository.onWifiConnectionChange(() => onChange());
  }

  stop(): void {
    this.repository.offWifiStateChange();
    this.repository.offWifiConnectionChange();
  }
}

export class WifiScanCacheFacade {
  private readonly repository: WifiNetworkRepository;
  private readonly ensurePeersMac: EnsurePermissionUseCase;

  constructor(
    repository: WifiNetworkRepository = WifiNetworkRepository.getInstance(),
    ensurePeersMac: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePeersMac = ensurePeersMac;
  }

  getLastScanResults(): WifiAccessPointSnapshot[] {
    return this.repository.getLastScanResults();
  }

  getScanCooldownRemainingMs(): number {
    return this.repository.getScanCooldownRemainingMs();
  }

  async readScanCache(withMacPermission: boolean, fromCache: boolean): Promise<Result<WifiAccessPointSnapshot[]>> {
    return this.repository.getScanResults(withMacPermission, fromCache);
  }

  async resolveMacPermissionGranted(): Promise<boolean> {
    const macPerm = await this.ensurePeersMac.execute(PermissionScenario.WIFI_PEERS_MAC);
    return macPerm.granted;
  }
}

export class StartWifiScanUseCase {
  private readonly repository: WifiNetworkRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  private readonly stopSession: StopSessionUseCase;

  constructor(
    repository: WifiNetworkRepository = WifiNetworkRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase(),
    stopSession: StopSessionUseCase = new StopSessionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
    this.stopSession = stopSession;
  }

  async execute(activeScan: boolean, sessionId: string = ''): Promise<Result<WifiAccessPointSnapshot[]>> {
    const wifiPerm = await this.ensurePermission.execute(PermissionScenario.WIFI_INFO);
    if (!wifiPerm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_WIFI_INFO, 'GET_WIFI_INFO required'));
    }
    const macPerm = await this.ensurePermission.execute(PermissionScenario.WIFI_PEERS_MAC);
    let sid = sessionId;
    if (sid.length === 0) {
      const input = new CreateSessionInput(
        SessionType.SCAN,
        ModuleType.WIFI,
        ProtocolType.WIFI_SCAN,
        'WiFi Scan',
        AppMode.EXPERT
      );
      const created = await this.createSession.execute(input);
      if (!created.success || created.value === undefined) {
        return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
      }
      sid = created.value.id;
      await this.startSession.execute(sid);
    }
    let fromCache = true;
    if (activeScan) {
      const scan = await this.repository.startWifiScan();
      if (scan.success) {
        fromCache = false;
        await WifiScanLogger.log(sid, 'WiFi active scan started');
      } else {
        await WifiScanLogger.log(sid, 'Active scan unavailable, reading cache');
      }
    }
    const results = await this.repository.getScanResults(macPerm.granted, fromCache);
    if (sid.length > 0) {
      await this.stopSession.execute(sid, 'scan_complete');
    }
    return results;
  }
}

export class RunNetworkDiagnosticsUseCase {
  private readonly repository: WifiNetworkRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: WifiNetworkRepository = WifiNetworkRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(plan: NetworkDiagnosticPlan): Promise<Result<DiagnosticStepResult[]>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    const results = await this.repository.runDiagnostics(plan);
    return Result.ok(results);
  }
}

export class ExecuteHttpRequestUseCase {
  private readonly repository: WifiNetworkRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: WifiNetworkRepository = WifiNetworkRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(draft: HttpRequestDraft): Promise<Result<HttpResponseRecord>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    return this.repository.executeHttp(draft);
  }
}

export class OpenWebSocketUseCase {
  private readonly repository: WifiNetworkRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: WifiNetworkRepository = WifiNetworkRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(config: WebSocketConfig): Promise<Result<void>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    return this.repository.connectWebSocket(config);
  }
}

export class StartLanDiscoveryUseCase {
  private readonly repository: WifiNetworkRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: WifiNetworkRepository = WifiNetworkRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(config: LanDiscoveryConfig, onHost: (host: LanHostResult) => void): Promise<Result<void>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    return this.repository.startLanDiscovery(config, onHost);
  }
}

export class StartPortScanUseCase {
  private readonly repository: WifiNetworkRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: WifiNetworkRepository = WifiNetworkRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(config: PortScanConfig, onResult: (result: PortProbeResult) => void): Promise<Result<void>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    return this.repository.startPortScan(config, onResult);
  }
}

export class OpenTcpClientUseCase {
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()) {
    this.ensurePermission = ensurePermission;
  }

  async execute(params: SocketConnectionParams): Promise<Result<SocketConnectionParams>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    return Result.ok(params);
  }
}

export { WifiScanPhase };
