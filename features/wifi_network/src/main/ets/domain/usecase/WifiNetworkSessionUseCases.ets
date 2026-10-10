import { CommandRepository, CommandTemplateRecord } from 'common_storage';
import { IdGenerator, Observable, Result, ResultError } from 'common_core';
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
  StopSessionUseCase,
  WriteResult
} from 'debug_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { WifiNetworkRepositoryContract } from '../repository/WifiNetworkRepositoryContract';
import { HttpRequestDraft, HttpResponseRecord } from '../model/HttpModels';
import { MulticastSessionConfig, UdpSessionConfig } from '../model/SocketModels';
import { DiscoveredNetworkService } from '../model/MqttModels';
import { WebSocketServerClientRecord, WebSocketServerConfigModel } from '../model/WebSocketModels';
import { HttpNetworkLogger } from '../service/HttpNetworkLogger';
import { HttpRequestTemplateCodec } from '../service/HttpRequestTemplateCodec';

export class UdpSessionOpenResult {
  readonly sessionId: string;
  constructor(sessionId: string) {
    this.sessionId = sessionId;
  }
}

export class MulticastSessionOpenResult {
  readonly sessionId: string;
  constructor(sessionId: string) {
    this.sessionId = sessionId;
  }
}

export class OpenUdpSessionUseCase {
  private readonly repository: WifiNetworkRepositoryContract;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  constructor(
    repository: WifiNetworkRepositoryContract,
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
  }
  async execute(config: UdpSessionConfig): Promise<Result<UdpSessionOpenResult>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.WIFI,
      ProtocolType.UDP,
      `UDP :${config.localPort}`,
      AppMode.EXPERT
    );
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    await this.startSession.execute(created.value.id);
    const bound = await this.repository.openUdpSession(created.value.id, config);
    if (!bound.success) {
      return Result.fail(bound.error ?? new ResultError(WifiNetworkErrorCodes.UDP_NOT_BOUND, 'UDP bind failed'));
    }
    return Result.ok(new UdpSessionOpenResult(created.value.id));
  }

  write(sessionId: string, payload: Uint8Array): Promise<WriteResult> {
    return this.repository.writeUdpSession(sessionId, payload);
  }
}

export class CloseUdpSessionUseCase {
  private readonly repository: WifiNetworkRepositoryContract;
  private readonly stopSession: StopSessionUseCase;
  constructor(
    repository: WifiNetworkRepositoryContract,
    stopSession: StopSessionUseCase = new StopSessionUseCase()
  ) {
    this.repository = repository;
    this.stopSession = stopSession;
  }
  async execute(sessionId: string): Promise<Result<void>> {
    await this.repository.closeUdpSession(sessionId);
    return this.stopSession.execute(sessionId, 'udp_closed');
  }
}

export class OpenMulticastSessionUseCase {
  private readonly repository: WifiNetworkRepositoryContract;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  constructor(
    repository: WifiNetworkRepositoryContract,
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
  }
  async execute(config: MulticastSessionConfig): Promise<Result<MulticastSessionOpenResult>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.WIFI,
      ProtocolType.UDP,
      `Multicast ${config.groupAddress}`,
      AppMode.EXPERT
    );
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    await this.startSession.execute(created.value.id);
    const joined = await this.repository.joinMulticast(created.value.id, config);
    if (!joined.success) {
      return Result.fail(joined.error ?? new ResultError(WifiNetworkErrorCodes.SOCKET_ERRNO, 'Multicast join failed'));
    }
    return Result.ok(new MulticastSessionOpenResult(created.value.id));
  }

  setMessageListener(listener: (text: string) => void): void {
    this.repository.setMulticastMessageListener(listener);
  }
}

export class LeaveMulticastSessionUseCase {
  private readonly repository: WifiNetworkRepositoryContract;
  private readonly stopSession: StopSessionUseCase;
  constructor(
    repository: WifiNetworkRepositoryContract,
    stopSession: StopSessionUseCase = new StopSessionUseCase()
  ) {
    this.repository = repository;
    this.stopSession = stopSession;
  }
  async execute(sessionId: string): Promise<Result<void>> {
    await this.repository.leaveMulticast();
    if (sessionId.length > 0) {
      return this.stopSession.execute(sessionId, 'multicast_left');
    }
    return Result.ok(undefined);
  }
}

export class StartMdnsDiscoveryUseCase {
  private readonly repository: WifiNetworkRepositoryContract;
  private readonly ensurePermission: EnsurePermissionUseCase;
  constructor(
    repository: WifiNetworkRepositoryContract,
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }
  async execute(serviceType: string): Promise<Result<void>> {
    if (serviceType.trim().length === 0) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.SCAN_LIMITED, '类型为空'));
    }
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    return this.repository.startMdnsDiscovery(serviceType);
  }

  observeServices(): Observable<DiscoveredNetworkService[]> {
    return this.repository.observeMdnsServices();
  }

  async publish(serviceName: string, serviceType: string, port: number): Promise<Result<void>> {
    return this.repository.publishMdns(serviceName, serviceType, port);
  }

  async unpublish(serviceName: string, serviceType: string): Promise<Result<void>> {
    return this.repository.unpublishMdns(serviceName, serviceType);
  }
}

export class StopMdnsDiscoveryUseCase {
  private readonly repository: WifiNetworkRepositoryContract;
  constructor(repository: WifiNetworkRepositoryContract) {
    this.repository = repository;
  }
  async execute(): Promise<void> {
    await this.repository.stopMdnsDiscovery();
  }
}

export class StartSsdpDiscoveryUseCase {
  private readonly repository: WifiNetworkRepositoryContract;
  private readonly ensurePermission: EnsurePermissionUseCase;
  constructor(
    repository: WifiNetworkRepositoryContract,
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }
  async execute(): Promise<Result<void>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    return this.repository.startSsdpDiscovery();
  }
}

export class StopSsdpDiscoveryUseCase {
  private readonly repository: WifiNetworkRepositoryContract;
  constructor(repository: WifiNetworkRepositoryContract) {
    this.repository = repository;
  }
  async execute(): Promise<void> {
    await this.repository.stopSsdpDiscovery();
  }
}

export class OpenWebSocketServerUseCase {
  private readonly repository: WifiNetworkRepositoryContract;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  constructor(
    repository: WifiNetworkRepositoryContract,
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
  }
  async execute(config: WebSocketServerConfigModel): Promise<Result<string>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.WIFI,
      ProtocolType.WEBSOCKET,
      `WS Server :${config.serverPort}`,
      AppMode.EXPERT
    );
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    await this.startSession.execute(created.value.id);
    const started = await this.repository.startWebSocketServer(config);
    if (!started.success) {
      return Result.fail(started.error ?? new ResultError(WifiNetworkErrorCodes.PORT_IN_USE, 'WS server failed'));
    }
    return Result.ok(created.value.id);
  }

  observeClients(): Observable<WebSocketServerClientRecord[]> {
    return this.repository.observeWebSocketServerClients();
  }
}

export class StopWebSocketServerUseCase {
  private readonly repository: WifiNetworkRepositoryContract;
  constructor(repository: WifiNetworkRepositoryContract) {
    this.repository = repository;
  }
  async execute(): Promise<void> {
    await this.repository.stopWebSocketServer();
  }
}

export class ExecuteHttpSessionUseCase {
  private readonly repository: WifiNetworkRepositoryContract;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  constructor(
    repository: WifiNetworkRepositoryContract,
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
  }
  async execute(draft: HttpRequestDraft): Promise<Result<HttpResponseRecord>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    const input = new CreateSessionInput(
      SessionType.COMMAND,
      ModuleType.WIFI,
      ProtocolType.HTTP,
      `${draft.method} ${draft.url}`,
      AppMode.EXPERT
    );
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const sessionId = created.value.id;
    await this.startSession.execute(sessionId);
    await HttpNetworkLogger.logRequest(sessionId, draft);
    const result = await this.repository.executeHttp(draft);
    if (result.success && result.value !== undefined) {
      await HttpNetworkLogger.logResponse(sessionId, result.value);
    }
    return result;
  }
}

export class SaveHttpRequestTemplateUseCase {
  private readonly commandRepository: CommandRepository;
  constructor(commandRepository: CommandRepository = CommandRepository.getInstance()) {
    this.commandRepository = commandRepository;
  }
  async execute(name: string, draft: HttpRequestDraft): Promise<Result<void>> {
    const record = HttpRequestTemplateCodec.toTemplateRecord(IdGenerator.next('httptpl'), name, draft);
    return this.commandRepository.saveTemplate(record);
  }
}

export class ListHttpRequestTemplatesUseCase {
  private readonly commandRepository: CommandRepository;
  constructor(commandRepository: CommandRepository = CommandRepository.getInstance()) {
    this.commandRepository = commandRepository;
  }
  async execute(): Promise<Result<CommandTemplateRecord[]>> {
    const page = await this.commandRepository.listTemplates(0, 50);
    if (!page.success || page.value === undefined) {
      return Result.fail(page.error ?? new ResultError('YW-STORAGE-1001', 'Template list failed'));
    }
    const httpTemplates: CommandTemplateRecord[] = [];
    for (let i = 0; i < page.value.items.length; i++) {
      const item = page.value.items[i];
      if (item.module === 'wifi' && item.protocol === 'http') {
        httpTemplates.push(item);
      }
    }
    return Result.ok(httpTemplates);
  }
}

export class LoadHttpRequestTemplateUseCase {
  async execute(record: CommandTemplateRecord): Promise<Result<HttpRequestDraft>> {
    const draft = HttpRequestTemplateCodec.fromTemplateRecord(record);
    if (draft === undefined) {
      return Result.fail(new ResultError('YW-STORAGE-1002', 'Invalid HTTP template payload'));
    }
    return Result.ok(draft);
  }
}

export class ExportHttpExchangeUseCase {
  execute(draft: HttpRequestDraft, response?: HttpResponseRecord): Result<string> {
    return Result.ok(HttpRequestTemplateCodec.exportExchange(draft, response));
  }
}

export class ListDiscoveredServicesUseCase {
  private readonly repository: WifiNetworkRepositoryContract;
  constructor(repository: WifiNetworkRepositoryContract) {
    this.repository = repository;
  }
  execute(): DiscoveredNetworkService[] {
    const merged: DiscoveredNetworkService[] = [];
    const mdns = this.repository.listMdnsServices();
    const ssdp = this.repository.listSsdpServices();
    for (let i = 0; i < mdns.length; i++) {
      merged.push(mdns[i]);
    }
    for (let i = 0; i < ssdp.length; i++) {
      merged.push(ssdp[i]);
    }
    return merged;
  }
}
