import { Result, ResultError, Subscription } from 'common_core';
import {
  AppMode,
  CreateSessionInput,
  CreateSessionUseCase,
  Direction,
  EnsurePermissionUseCase,
  ModuleType,
  PermissionScenario,
  PermissionScenarioCoordinator,
  ProtocolType,
  RadioSwitchReading,
  SessionType,
  StartSessionUseCase,
  StopSessionUseCase
} from 'debug_core';
import { WifiScanLogger } from '../service/WifiScanLogger';
import { WifiMessageLogger } from '../service/WifiMessageLogger';
import { WifiNetworkRepository } from '../../data/repository/WifiNetworkRepository';
import { WifiNetworkRepositoryContract } from '../repository/WifiNetworkRepositoryContract';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { WifiOverviewSnapshot } from '../model/WifiOverviewSnapshot';
import { WifiAccessPointSnapshot } from '../model/WifiAccessPointSnapshot';
import { WifiScanPhase } from '../model/WifiScanState';
import { NetworkDiagnosticPlan, DiagnosticStepResult } from '../model/NetworkDiagnosticModels';
import { HttpRequestDraft, HttpResponseRecord } from '../model/HttpModels';
import { WebSocketConfig, WebSocketMessageRecord } from '../model/WebSocketModels';
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
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  private readonly stopSession: StopSessionUseCase;
  private activeSessionId: string = '';
  private messageSubscription: Subscription | undefined;
  private loggedMessageCount: number = 0;

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

  async execute(config: WebSocketConfig): Promise<Result<string>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.WIFI,
      ProtocolType.WEBSOCKET,
      `WS ${config.url}`,
      AppMode.EXPERT
    );
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    await this.startSession.execute(created.value.id);
    const connected = await this.repository.connectWebSocket(config);
    if (!connected.success) {
      await this.stopSession.execute(created.value.id, 'ws_connect_failed');
      return Result.fail(connected.error ?? new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'WebSocket connect failed'));
    }
    this.activeSessionId = created.value.id;
    this.bindMessageEvidence();
    return Result.ok(created.value.id);
  }

  async sendText(text: string): Promise<Result<void>> {
    return this.repository.sendWebSocketText(text);
  }

  async disconnect(sessionId: string = ''): Promise<Result<void>> {
    this.unbindMessageEvidence();
    await this.repository.disconnectWebSocket();
    const id = sessionId.length > 0 ? sessionId : this.activeSessionId;
    this.activeSessionId = '';
    if (id.length > 0) {
      return this.stopSession.execute(id, 'ws_disconnected');
    }
    return Result.ok(undefined);
  }

  private bindMessageEvidence(): void {
    this.unbindMessageEvidence();
    this.loggedMessageCount = 0;
    this.messageSubscription = this.repository.observeWebSocketMessages()
      .subscribe((messages: WebSocketMessageRecord[]) => {
        if (this.activeSessionId.length === 0 || messages.length <= this.loggedMessageCount) {
          this.loggedMessageCount = messages.length;
          return;
        }
        for (let i = this.loggedMessageCount; i < messages.length; i++) {
          const message = messages[i];
          const direction = message.direction === 'outbound' ? Direction.OUTBOUND : Direction.INBOUND;
          void WifiMessageLogger.logText(
            this.activeSessionId,
            ProtocolType.WEBSOCKET,
            direction,
            message.payload,
            `ws_${message.messageType}`
          );
        }
        this.loggedMessageCount = messages.length;
      }, false);
  }

  private unbindMessageEvidence(): void {
    if (this.messageSubscription !== undefined) {
      this.messageSubscription.dispose();
      this.messageSubscription = undefined;
    }
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

export class ReadWifiSwitchUseCase {
  private readonly repository: WifiNetworkRepositoryContract;

  constructor(repository: WifiNetworkRepositoryContract = WifiNetworkRepository.getInstance()) {
    this.repository = repository;
  }

  async execute(): Promise<Result<string>> {
    const granted = await PermissionScenarioCoordinator.getInstance().checkGranted(PermissionScenario.WIFI_INFO);
    if (!granted) {
      return Result.ok(RadioSwitchReading.DENIED);
    }
    const active = await this.repository.getWifiState();
    if (!active.success || active.value === undefined) {
      return Result.fail(active.error ?? new ResultError(WifiNetworkErrorCodes.NO_WIFI_INFO, 'wifi unread'));
    }
    return Result.ok(active.value ? RadioSwitchReading.ON : RadioSwitchReading.OFF);
  }
}

export { WifiScanPhase };
