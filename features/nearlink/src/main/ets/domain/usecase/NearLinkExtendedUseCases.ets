import { Result, ResultError, Subscription } from 'common_core';

import {
  AppMode,
  CreateSessionInput,
  CreateSessionUseCase,
  DebugTarget,
  Direction,
  EnsurePermissionUseCase,
  ModuleType,
  PermissionScenario,
  ProtocolType,
  SessionType,
  StartSessionUseCase,
  StopSessionUseCase,
  TransportSessionRegistry,
  DebugLogRecord,
  LineEndingMode,
  PayloadEncoding,
  SendCommandInput,
  SendCommandUseCase
} from 'debug_core';
import { DeviceFavoriteRecord } from 'common_storage';

import { PermissionDecision } from 'common_platform';

import { NearLinkConstants } from '../../constants/NearLinkConstants';

import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';

import { NearLinkRepository } from '../../data/repository/NearLinkRepository';

import { SsapTransportSession } from '../../data/transport/SsapTransportSession';

import { RemoteDeviceDataSource } from '../../data/datasource/platform/RemoteDeviceDataSource';

import { SsapOperationQueue } from '../service/SsapOperationQueue';

import { NearLinkEventLogger } from '../service/NearLinkEventLogger';

import { NearLinkAdvParser } from '../service/NearLinkAdvParser';

import { SsapPropertyNotifyPayload } from '../model/SsapPropertyNotifyPayload';

import { NearLinkDevice } from '../model/NearLinkDevice';

import {
  DataTransferPortConfig,
  CongestionPolicy,
  DataTransferPacket
} from '../model/DataTransferPortConfig';
import { ConnectDataTransferResult } from '../model/ConnectDataTransferResult';

import { NearLinkSecurityState, NearLinkEncryptionLabel } from '../model/NearLinkSecurityState';
export class SaveNearLinkFavoriteUseCase {
  private readonly repository: NearLinkRepository;
  constructor(repository: NearLinkRepository = NearLinkRepository.getInstance()) {
    this.repository = repository;
  }
  async execute(device: NearLinkDevice, alias: string, protocol: string, uuid: string = ''): Promise<Result<void>> {
    return this.repository.saveFavorite(device, alias, protocol, uuid);
  }
  listFavorites(): DeviceFavoriteRecord[] {
    return this.repository.listFavorites();
  }
}

export class ConnectSsapClientUseCase {
  private readonly repository: NearLinkRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  private readonly transportRegistry: TransportSessionRegistry;
  constructor(
    repository: NearLinkRepository = NearLinkRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
    this.transportRegistry = transportRegistry;
  }
  async execute(deviceId: string, displayName: string): Promise<Result<string>> {
    const permission: PermissionDecision = await this.ensurePermission.execute(PermissionScenario.NEARLINK_ACCESS);
    if (!permission.granted) {
      return Result.fail(new ResultError(NearLinkErrorCodes.PERMISSION_DENIED, 'NearLink permission denied'));
    }
    const target = new DebugTarget(deviceId, ModuleType.NEARLINK, displayName, ProtocolType.SSAP, deviceId, 'random');
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.NEARLINK,
      ProtocolType.SSAP,
      `SSAP ${displayName}`,
      AppMode.EXPERT,
      target
    );
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const sessionId = created.value.id;
    const started = await this.startSession.execute(sessionId);
    if (!started.success) {
      return Result.fail(started.error ?? new ResultError('YW-SESSION-1003', 'Session start failed'));
    }
    const clientResult = this.repository.getOrCreateSsapClient(sessionId, deviceId);
    if (!clientResult.success || clientResult.value === undefined) {
      return Result.fail(clientResult.error ?? new ResultError(NearLinkErrorCodes.SSAP_CREATE_FAILED, 'create failed'));
    }
    const client = clientResult.value;
    const wired = this.repository.wireSsapClientSession(sessionId, deviceId);
    if (!wired.success) {
      return Result.fail(wired.error ?? new ResultError(NearLinkErrorCodes.SSAP_CONNECT_FAILED, 'wire failed'));
    }
    const connected = await client.connect();
    if (!connected.success) {
      return Result.fail(connected.error ?? new ResultError(NearLinkErrorCodes.SSAP_CONNECT_FAILED, 'connect failed'));
    }
    await NearLinkEventLogger.logSsapState(sessionId, 'SSAP connected, discovering services');
    await this.repository.discoverSsapServices(sessionId, deviceId, NearLinkConstants.DEFAULT_MTU);
    const transport = this.repository.createSsapTransport(sessionId);
    if (transport !== undefined) {
      const attachParams: Record<string, string | number | boolean> = {};
      await transport.connect(attachParams);
      this.transportRegistry.register(sessionId, transport);
    }
    this.repository.recordRecentConnection(deviceId, displayName, 'ssap');
    return Result.ok(sessionId);
  }
}

export class DisconnectSsapClientUseCase {
  private readonly repository: NearLinkRepository;
  private readonly stopSession: StopSessionUseCase;
  private readonly transportRegistry: TransportSessionRegistry;
  constructor(
    repository: NearLinkRepository = NearLinkRepository.getInstance(),
    stopSession: StopSessionUseCase = new StopSessionUseCase(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.repository = repository;
    this.stopSession = stopSession;
    this.transportRegistry = transportRegistry;
  }
  async execute(sessionId: string): Promise<Result<void>> {
    if (this.transportRegistry.get(sessionId) !== undefined) {
      this.transportRegistry.remove(sessionId);
    }
    this.repository.releaseSsapClient(sessionId);
    return this.stopSession.execute(sessionId, 'ssap_disconnected');
  }
}

export class BindSsapTransportUseCase {
  private readonly repository: NearLinkRepository;
  private readonly transportRegistry: TransportSessionRegistry;
  constructor(
    repository: NearLinkRepository = NearLinkRepository.getInstance(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.repository = repository;
    this.transportRegistry = transportRegistry;
  }
  execute(sessionId: string, serviceUuid: string, propertyUuid: string): Result<void> {
    const transport = this.transportRegistry.get(sessionId);
    if (transport === undefined || transport.protocol !== ProtocolType.SSAP) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP transport not registered'));
    }
    const ssapTransport = transport as SsapTransportSession;
    return ssapTransport.bindEndpoints(serviceUuid, propertyUuid);
  }
}

export class ReadSsapPropertyUseCase {
  private readonly repository: NearLinkRepository;
  private readonly queue: SsapOperationQueue = new SsapOperationQueue();
  constructor(repository: NearLinkRepository = NearLinkRepository.getInstance()) {
    this.repository = repository;
  }
  async execute(sessionId: string, serviceUuid: string, propertyUuid: string): Promise<Result<string>> {
    const client = this.repository.getSsapClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP not connected'));
    }
    const result = await this.queue.enqueue(() => client.readProperty(serviceUuid, propertyUuid));
    if (!result.success || result.value === undefined) {
      return Result.fail(result.error ?? new ResultError(NearLinkErrorCodes.SSAP_READ_FAILED, 'read failed'));
    }
    const bytes = NearLinkExtendedUseCases.hexToBytes(result.value);
    void NearLinkEventLogger.logSsapPayload(sessionId, Direction.INBOUND, serviceUuid, propertyUuid, bytes);
    return Result.ok(result.value);
  }
}

export class WriteSsapPropertyUseCase {
  private readonly repository: NearLinkRepository;
  private readonly queue: SsapOperationQueue = new SsapOperationQueue();
  constructor(repository: NearLinkRepository = NearLinkRepository.getInstance()) {
    this.repository = repository;
  }
  async execute(sessionId: string, serviceUuid: string, propertyUuid: string, hex: string): Promise<Result<void>> {
    const client = this.repository.getSsapClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP not connected'));
    }
    const buffer = NearLinkExtendedUseCases.hexToArrayBuffer(hex);
    const bytes = new Uint8Array(buffer);
    const result = await this.queue.enqueue(() => client.writeProperty(serviceUuid, propertyUuid, buffer));
    if (result.success) {
      void NearLinkEventLogger.logSsapPayload(sessionId, Direction.OUTBOUND, serviceUuid, propertyUuid, bytes);
    }
    return result;
  }
}

export class SetSsapNotificationUseCase {
  private readonly repository: NearLinkRepository;
  private readonly queue: SsapOperationQueue = new SsapOperationQueue();
  private readonly bindTransport: BindSsapTransportUseCase;
  constructor(
    repository: NearLinkRepository = NearLinkRepository.getInstance(),
    bindTransport: BindSsapTransportUseCase = new BindSsapTransportUseCase()
  ) {
    this.repository = repository;
    this.bindTransport = bindTransport;
  }
  async execute(
    sessionId: string,
    serviceUuid: string,
    propertyUuid: string,
    enable: boolean
  ): Promise<Result<void>> {
    const client = this.repository.getSsapClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP not connected'));
    }
    const result = await this.queue.enqueue(() => client.setPropertyNotification(serviceUuid, propertyUuid, enable));
    if (result.success && enable) {
      this.bindTransport.execute(sessionId, serviceUuid, propertyUuid);
    }
    return result;
  }
}

export class RequestSsapMtuUseCase {
  private readonly repository: NearLinkRepository;
  private readonly queue: SsapOperationQueue = new SsapOperationQueue();
  constructor(repository: NearLinkRepository = NearLinkRepository.getInstance()) {
    this.repository = repository;
  }
  async execute(sessionId: string, mtu: number): Promise<Result<number>> {
    const client = this.repository.getSsapClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP not connected'));
    }
    return this.queue.enqueue(() => client.requestMtuSize(mtu));
  }
}

export class ObserveSsapPropertyNotifyUseCase {
  private readonly repository: NearLinkRepository;
  constructor(repository: NearLinkRepository = NearLinkRepository.getInstance()) {
    this.repository = repository;
  }
  execute(sessionId: string, listener: (payload: SsapPropertyNotifyPayload) => void): Subscription {
    return this.repository.observeSsapPropertyNotify(sessionId).subscribe(listener);
  }
}

export class ObserveDataTransferPacketsUseCase {
  private readonly repository: NearLinkRepository;
  constructor(repository: NearLinkRepository = NearLinkRepository.getInstance()) {
    this.repository = repository;
  }
  execute(listener: (packet: DataTransferPacket) => void): Subscription {
    return this.repository.observeDataTransferPackets().subscribe(listener);
  }
}

export class ConnectDataTransferUseCase {
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  private readonly remoteDeviceSource: RemoteDeviceDataSource = new RemoteDeviceDataSource();
  private readonly repository: NearLinkRepository = NearLinkRepository.getInstance();
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
  async execute(
    address: string,
    displayName: string,
    config: DataTransferPortConfig
  ): Promise<Result<ConnectDataTransferResult>> {
    const permission: PermissionDecision = await this.ensurePermission.execute(PermissionScenario.NEARLINK_ACCESS);
    if (!permission.granted) {
      return Result.fail(new ResultError(NearLinkErrorCodes.PERMISSION_DENIED, 'NearLink permission denied'));
    }
    let securityState = config.secureRequired ? NearLinkSecurityState.UNKNOWN : NearLinkSecurityState.NOT_REQUIRED;
    if (config.secureRequired) {
      const security = await this.ensureEncrypted(address);
      if (!security.success || security.value === undefined) {
        return Result.fail(security.error ??
          new ResultError(NearLinkErrorCodes.ENCRYPTION_UNVERIFIED, NearLinkEncryptionLabel.UNVERIFIED));
      }
      securityState = security.value;
    }
    const target = new DebugTarget(address, ModuleType.NEARLINK, displayName, ProtocolType.DATA_TRANSFER, address, 'random');
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.NEARLINK,
      ProtocolType.DATA_TRANSFER,
      `DT ${displayName}`,
      AppMode.EXPERT,
      target
    );
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const sessionId = created.value.id;
    const started = await this.startSession.execute(sessionId);
    if (!started.success) {
      return Result.fail(started.error ?? new ResultError('YW-SESSION-1003', 'Session start failed'));
    }
    const transport = this.repository.createDataTransferTransport(sessionId, config.congestionPolicy);
    const connectParams: Record<string, string | number | boolean> = {
      'address': address,
      'uuid': config.uuid,
      'mtu': config.mtu
    };
    try {
      await transport.connect(connectParams);
    } catch (error) {
      const err = error as Error;
      transport.destroy();
      return Result.fail(new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, err.message));
    }
    this.repository.attachDataTransferIncoming(sessionId, transport);
    this.transportRegistry.register(sessionId, transport);
    await NearLinkEventLogger.logDataTransferState(sessionId, 'dataTransfer connected');
    if (config.secureRequired) {
      await NearLinkEventLogger.logSecurity(sessionId, `ACB=${securityState}`, NearLinkErrorCodes.ENCRYPTION_UNVERIFIED);
    }
    this.repository.recordRecentConnection(address, displayName, 'data_transfer');
    return Result.ok(new ConnectDataTransferResult(sessionId, securityState));
  }
  async ensureEncrypted(address: string): Promise<Result<NearLinkSecurityState>> {
    const created = this.remoteDeviceSource.createRemoteDevice(address);
    if (!created.success) {
      return Result.fail(created.error ?? new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'remote device failed'));
    }
    const pairing = await this.remoteDeviceSource.startPairing();
    if (!pairing.success) {
      return Result.fail(pairing.error ?? new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'pairing failed'));
    }
    const acb = this.remoteDeviceSource.getAcbState();
    if (!acb.success || acb.value === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.ENCRYPTION_UNVERIFIED, NearLinkEncryptionLabel.UNVERIFIED));
    }
    const state = this.remoteDeviceSource.resolveSecurityState(acb.value);
    if (state !== NearLinkSecurityState.ENCRYPTED) {
      return Result.fail(new ResultError(NearLinkErrorCodes.ENCRYPTION_UNVERIFIED, NearLinkEncryptionLabel.UNVERIFIED));
    }
    return Result.ok(state);
  }
}

export class WriteDataTransferUseCase {
  private readonly transportRegistry: TransportSessionRegistry;
  constructor(transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()) {
    this.transportRegistry = transportRegistry;
  }
  async execute(sessionId: string, hex: string): Promise<Result<void>> {
    const transport = this.transportRegistry.get(sessionId);
    if (transport === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'dataTransfer not connected'));
    }
    const bytes = NearLinkExtendedUseCases.hexToBytes(hex);
    const written = await transport.write(bytes);
    if (!written.success) {
      return Result.fail(new ResultError(written.appCode, written.message));
    }
    void NearLinkEventLogger.logDataTransferPayload(
      sessionId,
      Direction.OUTBOUND,
      '',
      bytes,
      written.appCode
    );
    return Result.ok(undefined);
  }
}

export class DisconnectDataTransferUseCase {
  private readonly stopSession: StopSessionUseCase;
  private readonly transportRegistry: TransportSessionRegistry;
  private readonly repository: NearLinkRepository;
  constructor(
    stopSession: StopSessionUseCase = new StopSessionUseCase(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance(),
    repository: NearLinkRepository = NearLinkRepository.getInstance()
  ) {
    this.stopSession = stopSession;
    this.transportRegistry = transportRegistry;
    this.repository = repository;
  }
  async execute(sessionId: string, uuid: string): Promise<Result<void>> {
    this.repository.detachDataTransferIncoming(sessionId);
    if (this.transportRegistry.get(sessionId) !== undefined) {
      this.transportRegistry.remove(sessionId);
    }
    this.repository.releaseDataTransferSource(sessionId, uuid);
    return this.stopSession.execute(sessionId, 'data_transfer_disconnected');
  }
}

export class PairNearLinkDeviceUseCase {
  private readonly remoteDeviceSource: RemoteDeviceDataSource = new RemoteDeviceDataSource();
  async execute(address: string): Promise<Result<NearLinkSecurityState>> {
    const created = this.remoteDeviceSource.createRemoteDevice(address);
    if (!created.success) {
      return Result.fail(created.error ?? new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'remote device failed'));
    }
    const pairing = await this.remoteDeviceSource.startPairing();
    if (!pairing.success) {
      return Result.fail(pairing.error ?? new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'pairing failed'));
    }
    const acb = this.remoteDeviceSource.getAcbState();
    if (!acb.success || acb.value === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.ENCRYPTION_UNVERIFIED, NearLinkEncryptionLabel.UNVERIFIED));
    }
    return Result.ok(this.remoteDeviceSource.resolveSecurityState(acb.value));
  }
}

export class SendNearLinkCommandUseCase {
  private readonly sendCommand: SendCommandUseCase;
  private readonly writeDataTransfer: WriteDataTransferUseCase;
  constructor(
    sendCommand: SendCommandUseCase = new SendCommandUseCase(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.sendCommand = sendCommand;
    this.writeDataTransfer = new WriteDataTransferUseCase(transportRegistry);
  }
  async execute(
    sessionId: string,
    payload: string,
    encoding: PayloadEncoding = PayloadEncoding.TEXT,
    lineEnding: LineEndingMode = LineEndingMode.LF
  ): Promise<Result<DebugLogRecord | void>> {
    const transport = TransportSessionRegistry.getInstance().get(sessionId);
    if (transport === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'Transport not connected'));
    }
    if (encoding === PayloadEncoding.HEX) {
      const written = await this.writeDataTransfer.execute(sessionId, payload);
      return written.success ? Result.ok(undefined) : Result.fail(written.error ?? new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'send failed'));
    }
    const input = new SendCommandInput(sessionId, transport, payload, encoding, lineEnding);
    return this.sendCommand.execute(input);
  }
}

export class NearLinkExtendedUseCases {
  static hexToBytes(hex: string): Uint8Array {
    const normalized = hex.replace(/\s/g, '');
    const bytes = new Uint8Array(normalized.length / 2);
    for (let i = 0; i < bytes.length; i++) {
      bytes[i] = parseInt(normalized.substring(i * 2, i * 2 + 2), 16);
    }
    return bytes;
  }
  static hexToArrayBuffer(hex: string): ArrayBuffer {
    const bytes = NearLinkExtendedUseCases.hexToBytes(hex);
    return bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
  }
  static sleep(ms: number): Promise<void> {
    return new Promise((resolve: () => void) => setTimeout(resolve, ms));
  }
}
