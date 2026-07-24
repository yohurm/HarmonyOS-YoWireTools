import { Result, ResultError } from 'common_core';
import {
  AppMode,
  CreateSessionInput,
  DebugTarget,
  ModuleType,
  ProtocolType,
  SessionType,
  StopSessionUseCase,
  TransportSessionRegistry
} from 'debug_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';
import { ConnectSppResult, SppConnectParams } from '../../model/SppConnectParams';
import { BluetoothTransportPolicy, BluetoothTransportType } from '../../model/BluetoothTransportType';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';
import { BluetoothSessionBootstrap } from '../shared/BluetoothSessionBootstrap';
import { ResolveSppTargetAddressUseCase } from './SppAddressUseCases';
import { CommandWriteQueue } from '../../service/queue/CommandWriteQueue';
import { SppActiveWritePolicy } from '../../service/spp/SppActiveWritePolicy';

export class ConnectSppUseCase {
  private readonly repository: BluetoothRepository;
  private readonly guard: BluetoothOperationGuard;
  private readonly sessionBootstrap: BluetoothSessionBootstrap;
  private readonly transportRegistry: TransportSessionRegistry;
  private readonly resolveAddress: ResolveSppTargetAddressUseCase;
  private readonly activeWritePolicy: SppActiveWritePolicy;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard(),
    sessionBootstrap: BluetoothSessionBootstrap = new BluetoothSessionBootstrap(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance(),
    resolveAddress: ResolveSppTargetAddressUseCase = new ResolveSppTargetAddressUseCase(),
    activeWritePolicy: SppActiveWritePolicy = new SppActiveWritePolicy()
  ) {
    this.repository = repository;
    this.guard = guard;
    this.sessionBootstrap = sessionBootstrap;
    this.transportRegistry = transportRegistry;
    this.resolveAddress = resolveAddress;
    this.activeWritePolicy = activeWritePolicy;
  }

  async execute(params: SppConnectParams): Promise<Result<ConnectSppResult>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    const canWrite = this.activeWritePolicy.ensureCanOpenNewWriter();
    if (!canWrite.success) {
      return Result.fail(canWrite.error ?? new ResultError(BluetoothErrorCodes.OPERATION_BUSY, 'SPP busy'));
    }
    const address = this.resolveAddress.executeFromAddress(params.classicDeviceId, params.transport);
    if (!address.success || address.value === undefined || address.value.length === 0) {
      return Result.fail(address.error ?? new ResultError(
        BluetoothErrorCodes.SPP_BLE_ADDRESS_REJECTED,
        'classic address required'
      ));
    }
    if (params.transport === BluetoothTransportType.LE) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_TARGET_LE_ONLY, 'LE-only rejected'));
    }
    if (params.transport !== BluetoothTransportType.UNKNOWN &&
      !BluetoothTransportPolicy.isClassicCandidate(params.transport)) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_TARGET_LE_ONLY, 'transport not classic'));
    }
    await this.repository.ensureClassicDiscoveryStopped();
    const classicId = address.value;
    const connectParams = new SppConnectParams(
      classicId,
      params.displayName,
      params.uuid,
      params.secure,
      params.timeoutMs,
      params.autoReconnect,
      params.reconnectPolicy,
      params.transport === BluetoothTransportType.UNKNOWN ?
        BluetoothTransportType.BR_EDR :
        params.transport,
      params.bleDeviceId
    );
    const target = new DebugTarget(
      classicId,
      ModuleType.BLUETOOTH,
      connectParams.displayName,
      ProtocolType.SPP,
      classicId,
      'virtual'
    );
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.BLUETOOTH,
      ProtocolType.SPP,
      `SPP ${connectParams.displayName}`,
      AppMode.EXPERT,
      target
    );
    const session = await this.sessionBootstrap.createAndStart(input);
    if (!session.success || session.value === undefined) {
      return Result.fail(session.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const transport = this.repository.createSppTransport(session.value.id, connectParams);
    try {
      await transport.connect(connectParams.toConnectRecord());
    } catch (error) {
      const err = error as Error;
      transport.destroy();
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_CONNECT_FAILED, err.message, err));
    }
    this.transportRegistry.register(session.value.id, transport);
    this.repository.recordRecentConnection(classicId, connectParams.displayName, 'spp');
    this.repository.republishClassicDevices();
    return Result.ok(new ConnectSppResult(session.value.id, transport.id));
  }
}

export class DisconnectSppUseCase {
  private readonly transportRegistry: TransportSessionRegistry;
  private readonly stopSession: StopSessionUseCase;
  private readonly repository: BluetoothRepository;

  constructor(
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance(),
    stopSession: StopSessionUseCase = new StopSessionUseCase(),
    repository: BluetoothRepository = BluetoothRepository.getInstance()
  ) {
    this.transportRegistry = transportRegistry;
    this.stopSession = stopSession;
    this.repository = repository;
  }

  async execute(sessionId: string): Promise<Result<void>> {
    const transport = this.transportRegistry.get(sessionId);
    if (transport !== undefined) {
      const writeQueue = new CommandWriteQueue(transport.id);
      writeQueue.reset();
      await transport.disconnect('user_disconnect');
      this.transportRegistry.remove(sessionId);
    }
    const stopped = await this.stopSession.execute(sessionId, 'spp_disconnected');
    this.repository.republishClassicDevices();
    return stopped;
  }
}
