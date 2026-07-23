import { Result, ResultError } from 'common_core';
import { IdGenerator } from 'common_core';
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
import { DeviceFavoriteRecord, TargetRepository } from 'common_storage';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { MqttClientDataSource } from '../../data/datasource/MqttClientDataSource';
import { TcpClientSessionCoordinator } from '../../data/transport/TcpClientSessionCoordinator';
import { TcpClientTransportSession } from '../../data/transport/TcpClientTransportSession';
import { TcpServerSessionCoordinator } from '../../data/transport/TcpServerSessionCoordinator';
import { MqttConnectConfig } from '../model/MqttModels';
import { SocketConnectionParams } from '../model/SocketModels';

export class OpenTcpServerUseCase {
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.ensurePermission = ensurePermission;
  }

  async execute(port: number): Promise<Result<void>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    return TcpServerSessionCoordinator.getInstance().start(port);
  }
}

export class OpenMqttSessionUseCase {
  private readonly mqttDataSource: MqttClientDataSource;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  private readonly stopSession: StopSessionUseCase;

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
    return Result.ok(created.value.id);
  }

  async disconnect(sessionId: string): Promise<Result<void>> {
    await this.mqttDataSource.disconnect();
    if (sessionId.length > 0) {
      return this.stopSession.execute(sessionId, 'mqtt_disconnected');
    }
    return Result.ok(undefined);
  }

  onMessage(listener: (payload: string) => void): Result<void> {
    return this.mqttDataSource.onMessage(listener);
  }

  async publish(topic: string, payload: string): Promise<Result<void>> {
    return this.mqttDataSource.publish(topic, payload);
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

  constructor(
    openTcpSession: OpenTcpClientSessionUseCase = new OpenTcpClientSessionUseCase(),
    tcpCoordinator: TcpClientSessionCoordinator = TcpClientSessionCoordinator.getInstance(),
    stopSession: StopSessionUseCase = new StopSessionUseCase()
  ) {
    this.openTcpSession = openTcpSession;
    this.tcpCoordinator = tcpCoordinator;
    this.stopSession = stopSession;
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
    if (this.transportRegistry.get(sessionId) !== undefined) {
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
