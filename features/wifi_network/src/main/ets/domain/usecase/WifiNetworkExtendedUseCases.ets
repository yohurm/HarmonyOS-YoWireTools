import { Result, ResultError } from 'common_core';
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
  TransportSessionRegistry
} from 'debug_core';
import { DeviceFavoriteRecord, TargetRepository } from 'common_storage';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { WifiNetworkRepository } from '../../data/repository/WifiNetworkRepository';
import { WifiNetworkRepositoryContract } from '../repository/WifiNetworkRepositoryContract';
import { MqttConnectConfig } from '../model/MqttModels';
import { SocketConnectionParams } from '../model/SocketModels';
import { WifiMessageLogger } from '../service/WifiMessageLogger';

export class OpenTcpServerUseCase {
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly repository: WifiNetworkRepositoryContract;

  constructor(
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    repository: WifiNetworkRepositoryContract = WifiNetworkRepository.getInstance()
  ) {
    this.ensurePermission = ensurePermission;
    this.repository = repository;
  }

  async execute(port: number): Promise<Result<void>> {
    const perm = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!perm.granted) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'INTERNET permission required'));
    }
    return this.repository.startTcpServer(port);
  }
}

export class OpenMqttSessionUseCase {
  private readonly repository: WifiNetworkRepositoryContract;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  private readonly stopSession: StopSessionUseCase;
  private activeSessionId: string = '';

  constructor(
    repository: WifiNetworkRepositoryContract = WifiNetworkRepository.getInstance(),
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
    const connected = await this.repository.createMqttSession(config);
    if (!connected.success) {
      await this.stopSession.execute(created.value.id, 'mqtt_connect_failed');
      return Result.fail(connected.error ?? new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'MQTT connect failed'));
    }
    this.activeSessionId = created.value.id;
    return Result.ok(created.value.id);
  }

  async disconnect(sessionId: string): Promise<Result<void>> {
    await this.repository.disconnectMqtt();
    this.activeSessionId = '';
    if (sessionId.length > 0) {
      return this.stopSession.execute(sessionId, 'mqtt_disconnected');
    }
    return Result.ok(undefined);
  }

  onMessage(listener: (payload: string) => void): Result<void> {
    return this.repository.onMqttMessage((payload: string) => {
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
    const result = await this.repository.publishMqtt(topic, payload);
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
  constructor(
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase()
  ) {
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
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
}

export class ConnectTcpClientUseCase {
  private readonly openTcpSession: OpenTcpClientSessionUseCase;
  private readonly repository: WifiNetworkRepositoryContract;
  private readonly stopSession: StopSessionUseCase;

  constructor(
    openTcpSession: OpenTcpClientSessionUseCase = new OpenTcpClientSessionUseCase(),
    repository: WifiNetworkRepositoryContract = WifiNetworkRepository.getInstance(),
    stopSession: StopSessionUseCase = new StopSessionUseCase()
  ) {
    this.openTcpSession = openTcpSession;
    this.repository = repository;
    this.stopSession = stopSession;
  }

  async execute(params: SocketConnectionParams): Promise<Result<string>> {
    const session = await this.openTcpSession.execute(params);
    if (!session.success || session.value === undefined) {
      return Result.fail(session.error ?? new ResultError(WifiNetworkErrorCodes.NO_INTERNET, 'Session open failed'));
    }
    const connected = await this.repository.connectTcpClient(session.value, params);
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
  private readonly repository: WifiNetworkRepositoryContract;

  constructor(repository: WifiNetworkRepositoryContract = WifiNetworkRepository.getInstance()) {
    this.repository = repository;
  }

  async execute(): Promise<Result<void>> {
    await this.repository.stopTcpServer();
    return Result.ok(undefined);
  }
}
