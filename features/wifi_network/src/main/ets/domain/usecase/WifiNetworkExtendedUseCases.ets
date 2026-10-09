import { Observable, Result, ResultError } from 'common_core';
import { IdGenerator } from 'common_core';
import {
  AppMode,
  CreateSessionInput,
  CreateSessionUseCase,
  Direction,
  EnsurePermissionUseCase,
  ModuleType,
  PermissionScenario,
  ProtocolType,
  SessionType,
  StartSessionUseCase,
  StopSessionUseCase,
  TransportSessionRegistry,
  TransportState,
  TransportStateSnapshot,
  WriteResult
} from 'debug_core';
import { DeviceFavoriteRecord, TargetRepository } from 'common_storage';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { MqttClientDataSource } from '../../data/datasource/MqttClientDataSource';
import { TcpClientSessionCoordinator } from '../../data/transport/TcpClientSessionCoordinator';
import { TcpClientTransportSession } from '../../data/transport/TcpClientTransportSession';
import { TcpServerSessionCoordinator } from '../../data/transport/TcpServerSessionCoordinator';
import { MqttConnectConfig } from '../model/MqttModels';
import { SocketConnectionParams, TcpServerClientRecord } from '../model/SocketModels';
import { WifiMessageLogger } from '../service/WifiMessageLogger';

export class OpenTcpServerUseCase {
  private readonly ensurePermission: EnsurePermissionUseCase;
  private knownClientIds: string[] = [];

  constructor(
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.ensurePermission = ensurePermission;
  }

  watchClients(
    onConnect: (address: string, port: number) => void,
    onBytes: (address: string, port: number, byteCount: number) => void
  ): void {
    this.knownClientIds = [];
    const coordinator = TcpServerSessionCoordinator.getInstance();
    coordinator.setCallbacks((clientId: string, text: string) => {
      const record = this.findClient(clientId);
      if (record !== undefined) {
        onBytes(record.remoteAddress, record.remotePort, text.length);
      }
    }, () => {
      const clients = coordinator.listClients();
      for (let i = 0; i < clients.length; i++) {
        const client = clients[i];
        if (!this.clientKnown(client.id)) {
          this.knownClientIds.push(client.id);
          onConnect(client.remoteAddress, client.remotePort);
        }
      }
    });
  }

  async execute(port: number): Promise<Result<void>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    return TcpServerSessionCoordinator.getInstance().start(port);
  }

  private findClient(clientId: string): TcpServerClientRecord | undefined {
    const clients = TcpServerSessionCoordinator.getInstance().listClients();
    for (let i = 0; i < clients.length; i++) {
      if (clients[i].id === clientId) {
        return clients[i];
      }
    }
    return undefined;
  }

  private clientKnown(clientId: string): boolean {
    for (let i = 0; i < this.knownClientIds.length; i++) {
      if (this.knownClientIds[i] === clientId) {
        return true;
      }
    }
    return false;
  }
}

export class OpenMqttSessionUseCase {
  private readonly mqttDataSource: MqttClientDataSource;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  private readonly stopSession: StopSessionUseCase;
  private activeSessionId: string = '';

  constructor(
    mqttDataSource: MqttClientDataSource = MqttClientDataSource.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase(),
    stopSession: StopSessionUseCase = new StopSessionUseCase()
  ) {
    this.mqttDataSource = mqttDataSource;
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
    this.stopSession = stopSession;
  }

  async execute(config: MqttConnectConfig): Promise<Result<string>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.WIFI,
      ProtocolType.MQTT,
      `MQTT ${config.brokerHost}`,
      AppMode.EXPERT
    );
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    await this.startSession.execute(created.value.id);
    const connected = await this.mqttDataSource.connect(config);
    if (!connected.success) {
      await this.stopSession.execute(created.value.id, 'mqtt_connect_failed');
      return Result.fail(connected.error ?? new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'MQTT connect failed'));
    }
    this.activeSessionId = created.value.id;
    return Result.ok(created.value.id);
  }

  async disconnect(sessionId: string): Promise<Result<void>> {
    await this.mqttDataSource.disconnect();
    this.activeSessionId = '';
    if (sessionId.length > 0) {
      return this.stopSession.execute(sessionId, 'mqtt_disconnected');
    }
    return Result.ok(undefined);
  }

  onMessage(listener: (payload: string) => void): Result<void> {
    return this.mqttDataSource.onMessage((payload: string) => {
      if (this.activeSessionId.length > 0) {
        void WifiMessageLogger.logText(
          this.activeSessionId,
          ProtocolType.MQTT,
          Direction.INBOUND,
          payload,
          'mqtt_publish'
        );
      }
      listener(payload);
    });
  }

  async publish(topic: string, payload: string): Promise<Result<void>> {
    const result = await this.mqttDataSource.publish(topic, payload);
    if (result.success && this.activeSessionId.length > 0) {
      void WifiMessageLogger.logText(
        this.activeSessionId,
        ProtocolType.MQTT,
        Direction.OUTBOUND,
        payload,
        `mqtt_publish topic=${topic}`
      );
    }
    return result;
  }
}

export class SaveNetworkTargetUseCase {
  private readonly targetRepository: TargetRepository;

  constructor(targetRepository: TargetRepository = TargetRepository.getInstance()) {
    this.targetRepository = targetRepository;
  }

  async execute(
    displayName: string,
    host: string,
    port: number,
    protocol: string,
    alias: string = ''
  ): Promise<Result<void>> {
    const record = new DeviceFavoriteRecord(
      IdGenerator.next('netfav'),
      ModuleType.WIFI,
      protocol,
      displayName,
      alias.length > 0 ? alias : displayName,
      host,
      'real',
      '',
      port,
      '',
      '{}',
      Date.now()
    );
    return this.targetRepository.saveFavorite(record);
  }
}

export class OpenTcpClientSessionUseCase {
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  private readonly transportRegistry: TransportSessionRegistry;

  constructor(
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
    this.transportRegistry = transportRegistry;
  }

  async execute(params: SocketConnectionParams): Promise<Result<string>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.WIFI,
      ProtocolType.TCP_CLIENT,
      `TCP ${params.host}:${params.port}`,
      AppMode.EXPERT
    );
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    await this.startSession.execute(created.value.id);
    return Result.ok(created.value.id);
  }

  registerTransport(sessionId: string, transport: TcpClientTransportSession): void {
    this.transportRegistry.register(sessionId, transport);
  }
}

export class ConnectTcpClientUseCase {
  private readonly openTcpSession: OpenTcpClientSessionUseCase;
  private readonly tcpCoordinator: TcpClientSessionCoordinator;
  private readonly stopSession: StopSessionUseCase;
  private readonly transportRegistry: TransportSessionRegistry;

  constructor(
    openTcpSession: OpenTcpClientSessionUseCase = new OpenTcpClientSessionUseCase(),
    tcpCoordinator: TcpClientSessionCoordinator = TcpClientSessionCoordinator.getInstance(),
    stopSession: StopSessionUseCase = new StopSessionUseCase(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.openTcpSession = openTcpSession;
    this.tcpCoordinator = tcpCoordinator;
    this.stopSession = stopSession;
    this.transportRegistry = transportRegistry;
  }

  observeState(sessionId: string): Observable<TransportStateSnapshot> | undefined {
    const transport = this.transportRegistry.get(sessionId);
    if (transport === undefined) {
      return undefined;
    }
    return transport.observeState();
  }

  async sendText(sessionId: string, text: string): Promise<WriteResult> {
    const transport = this.transportRegistry.get(sessionId);
    if (transport === undefined || transport.state !== TransportState.CONNECTED) {
      return new WriteResult(false, 0, WifiNetworkErrorCodes.NOT_CONNECTED, '发送不可用');
    }
    return transport.write(ConnectTcpClientUseCase.toBytes(text));
  }

  async execute(params: SocketConnectionParams): Promise<Result<string>> {
    const session = await this.openTcpSession.execute(params);
    if (!session.success || session.value === undefined) {
      return Result.fail(session.error ?? new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'Session open failed'));
    }
    const connected = await this.tcpCoordinator.connectSession(session.value, params);
    if (!connected.success) {
      await this.stopSession.execute(session.value, 'tcp_connect_failed');
      return Result.fail(connected.error ?? new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'Connect failed'));
    }
    return Result.ok(session.value);
  }

  private static toBytes(text: string): Uint8Array {
    const bytes = new Uint8Array(text.length);
    for (let i = 0; i < text.length; i++) {
      bytes[i] = text.charCodeAt(i) & 0xff;
    }
    return bytes;
  }
}

export class DisconnectTcpClientSessionUseCase {
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
      await transport.disconnect('tcp_disconnected');
      this.transportRegistry.remove(sessionId);
    }
    return this.stopSession.execute(sessionId, 'tcp_disconnected');
  }
}

export class StopTcpServerSessionUseCase {
  async execute(): Promise<Result<void>> {
    await TcpServerSessionCoordinator.getInstance().stop();
    return Result.ok(undefined);
  }
}
