import { CommandRepository, CommandTemplateRecord } from 'common_storage';
import { AbilityContextRegistry } from 'common_platform';
import { IdGenerator, Result, ResultError } from 'common_core';
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
  TransportSessionRegistry
} from 'debug_core';
import { MulticastSessionCoordinator } from '../../data/transport/MulticastSessionCoordinator';
import { MdnsDataSource } from '../../data/datasource/MdnsDataSource';
import { MulticastSocketDataSource } from '../../data/datasource/MulticastSocketDataSource';
import { SsdpDiscoveryDataSource } from '../../data/datasource/SsdpDiscoveryDataSource';
import { UdpSocketDataSource } from '../../data/datasource/UdpSocketDataSource';
import { WebSocketServerDataSource } from '../../data/datasource/WebSocketServerDataSource';
import { UdpTransportSession } from '../../data/transport/UdpTransportSession';
import { WifiNetworkRepository } from '../../data/repository/WifiNetworkRepository';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { HttpRequestDraft, HttpResponseRecord } from '../model/HttpModels';
import { MulticastSessionConfig, UdpSessionConfig } from '../model/SocketModels';
import { DiscoveredNetworkService } from '../model/MqttModels';
import { WebSocketServerConfigModel } from '../model/WebSocketModels';
import { HttpNetworkLogger } from '../service/HttpNetworkLogger';
import { HttpRequestTemplateCodec } from '../service/HttpRequestTemplateCodec';

export class UdpSessionOpenResult {
  readonly sessionId: string;
  readonly transport: UdpTransportSession;
  constructor(sessionId: string, transport: UdpTransportSession) {
    this.sessionId = sessionId;
    this.transport = transport;
  }
}

export class MulticastSessionOpenResult {
  readonly sessionId: string;
  constructor(sessionId: string) {
    this.sessionId = sessionId;
  }
}

export class OpenUdpSessionUseCase {
  private readonly udpDataSource: UdpSocketDataSource;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  private readonly transportRegistry: TransportSessionRegistry;
  constructor(
    udpDataSource: UdpSocketDataSource = UdpSocketDataSource.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.udpDataSource = udpDataSource;
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
    this.transportRegistry = transportRegistry;
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
    const bound = await this.udpDataSource.bind(config.localPort, config.allowBroadcast);
    if (!bound.success || bound.value === undefined) {
      return Result.fail(bound.error ?? new ResultError(WifiNetworkErrorCodes.UDP_NOT_BOUND, 'UDP bind failed'));
    }
    const transport = new UdpTransportSession(created.value.id);
    transport.bindSocket(bound.value, config.remoteHost, config.remotePort);
    this.transportRegistry.register(created.value.id, transport);
    return Result.ok(new UdpSessionOpenResult(created.value.id, transport));
  }
}

export class CloseUdpSessionUseCase {
  private readonly transportRegistry: TransportSessionRegistry;
  private readonly stopSession: StopSessionUseCase;
  constructor(
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance(),
    stopSession: StopSessionUseCase = new StopSessionUseCase()
  ) {
    this.transportRegistry = transportRegistry;
    this.stopSession = stopSession;
  }
  async execute(sessionId: string): Promise<Result<void>> {
    const transport = this.transportRegistry.get(sessionId);
    if (transport !== undefined) {
      await transport.disconnect('close');
      this.transportRegistry.remove(sessionId);
    }
    return this.stopSession.execute(sessionId, 'udp_closed');
  }
}

export class OpenMulticastSessionUseCase {
  private readonly multicastDataSource: MulticastSocketDataSource;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  constructor(
    multicastDataSource: MulticastSocketDataSource = MulticastSocketDataSource.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase()
  ) {
    this.multicastDataSource = multicastDataSource;
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
    const joined = await this.multicastDataSource.bindAndJoin(config.localPort, config.groupAddress);
    if (!joined.success || joined.value === undefined) {
      return Result.fail(joined.error ?? new ResultError(WifiNetworkErrorCodes.SOCKET_ERRNO, 'Multicast join failed'));
    }
    MulticastSessionCoordinator.getInstance().attach(created.value.id, joined.value);
    return Result.ok(new MulticastSessionOpenResult(created.value.id));
  }
  getDataSource(): MulticastSocketDataSource {
    return this.multicastDataSource;
  }
}

export class LeaveMulticastSessionUseCase {
  private readonly stopSession: StopSessionUseCase;
  constructor(stopSession: StopSessionUseCase = new StopSessionUseCase()) {
    this.stopSession = stopSession;
  }
  async execute(sessionId: string): Promise<Result<void>> {
    await MulticastSessionCoordinator.getInstance().detach();
    if (sessionId.length > 0) {
      return this.stopSession.execute(sessionId, 'multicast_left');
    }
    return Result.ok(undefined);
  }
}

export class StartMdnsDiscoveryUseCase {
  private readonly mdnsDataSource: MdnsDataSource;
  private readonly ensurePermission: EnsurePermissionUseCase;
  constructor(
    mdnsDataSource: MdnsDataSource = MdnsDataSource.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.mdnsDataSource = mdnsDataSource;
    this.ensurePermission = ensurePermission;
  }
  async execute(serviceType: string): Promise<Result<void>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    const context = AbilityContextRegistry.getInstance().get();
    if (context === undefined) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.SCAN_LIMITED, 'Ability context not bound'));
    }
    return this.mdnsDataSource.startDiscovery(context, serviceType);
  }
  getDataSource(): MdnsDataSource {
    return this.mdnsDataSource;
  }
}

export class StopMdnsDiscoveryUseCase {
  private readonly mdnsDataSource: MdnsDataSource;
  constructor(mdnsDataSource: MdnsDataSource = MdnsDataSource.getInstance()) {
    this.mdnsDataSource = mdnsDataSource;
  }
  async execute(): Promise<void> {
    await this.mdnsDataSource.stopDiscovery();
  }
}

export class StartSsdpDiscoveryUseCase {
  private readonly ssdpDataSource: SsdpDiscoveryDataSource;
  private readonly ensurePermission: EnsurePermissionUseCase;
  constructor(
    ssdpDataSource: SsdpDiscoveryDataSource = SsdpDiscoveryDataSource.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.ssdpDataSource = ssdpDataSource;
    this.ensurePermission = ensurePermission;
  }
  async execute(): Promise<Result<void>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    return this.ssdpDataSource.startDiscovery();
  }
  getDataSource(): SsdpDiscoveryDataSource {
    return this.ssdpDataSource;
  }
}

export class StopSsdpDiscoveryUseCase {
  private readonly ssdpDataSource: SsdpDiscoveryDataSource;
  constructor(ssdpDataSource: SsdpDiscoveryDataSource = SsdpDiscoveryDataSource.getInstance()) {
    this.ssdpDataSource = ssdpDataSource;
  }
  async execute(): Promise<void> {
    await this.ssdpDataSource.stopDiscovery();
  }
}

export class OpenWebSocketServerUseCase {
  private readonly serverDataSource: WebSocketServerDataSource;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  constructor(
    serverDataSource: WebSocketServerDataSource = WebSocketServerDataSource.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase()
  ) {
    this.serverDataSource = serverDataSource;
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
    const started = await this.serverDataSource.start(config);
    if (!started.success) {
      return Result.fail(started.error ?? new ResultError(WifiNetworkErrorCodes.PORT_IN_USE, 'WS server failed'));
    }
    return Result.ok(created.value.id);
  }
  getDataSource(): WebSocketServerDataSource {
    return this.serverDataSource;
  }
}

export class StopWebSocketServerUseCase {
  private readonly serverDataSource: WebSocketServerDataSource;
  constructor(serverDataSource: WebSocketServerDataSource = WebSocketServerDataSource.getInstance()) {
    this.serverDataSource = serverDataSource;
  }
  async execute(): Promise<void> {
    await this.serverDataSource.stop();
  }
}

export class ExecuteHttpSessionUseCase {
  private readonly repository: WifiNetworkRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  constructor(
    repository: WifiNetworkRepository = WifiNetworkRepository.getInstance(),
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
  private readonly mdnsDataSource: MdnsDataSource;
  private readonly ssdpDataSource: SsdpDiscoveryDataSource;
  constructor(
    mdnsDataSource: MdnsDataSource = MdnsDataSource.getInstance(),
    ssdpDataSource: SsdpDiscoveryDataSource = SsdpDiscoveryDataSource.getInstance()
  ) {
    this.mdnsDataSource = mdnsDataSource;
    this.ssdpDataSource = ssdpDataSource;
  }
  execute(): DiscoveredNetworkService[] {
    const merged: DiscoveredNetworkService[] = [];
    const mdns = this.mdnsDataSource.getServices();
    const ssdp = this.ssdpDataSource.getServices();
    for (let i = 0; i < mdns.length; i++) {
      merged.push(mdns[i]);
    }
    for (let i = 0; i < ssdp.length; i++) {
      merged.push(ssdp[i]);
    }
    return merged;
  }
}
