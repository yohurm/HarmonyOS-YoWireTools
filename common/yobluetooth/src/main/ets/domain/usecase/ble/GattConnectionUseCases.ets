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
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';
import { ConnectGattResult, GattConnectParams } from '../../model/GattConnectParams';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';
import { BluetoothSessionBootstrap } from '../shared/BluetoothSessionBootstrap';

export class ConnectGattUseCase {
  private readonly repository: BluetoothRepository;
  private readonly guard: BluetoothOperationGuard;
  private readonly sessionBootstrap: BluetoothSessionBootstrap;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard(),
    sessionBootstrap: BluetoothSessionBootstrap = new BluetoothSessionBootstrap()
  ) {
    this.repository = repository;
    this.guard = guard;
    this.sessionBootstrap = sessionBootstrap;
  }

  async execute(params: GattConnectParams): Promise<Result<ConnectGattResult>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    if (params.bleDeviceId.length === 0) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.GATT_CLASSIC_ADDRESS_REJECTED,
        'bleDeviceId required for GATT'
      ));
    }
    if (!this.repository.tryReserveBleConnection()) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.BLE_GATT_SESSION_LIMIT,
        `GATT session limit ${BluetoothConstants.GATT_MAX_SESSIONS}`
      ));
    }
    this.repository.stopBleScan();
    const target = new DebugTarget(
      params.bleDeviceId,
      ModuleType.BLUETOOTH,
      params.displayName,
      ProtocolType.BLE_GATT,
      params.bleDeviceId,
      'virtual'
    );
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.BLUETOOTH,
      ProtocolType.BLE_GATT,
      `GATT ${params.displayName}`,
      AppMode.EXPERT,
      target
    );
    const session = await this.sessionBootstrap.createAndStart(input);
    if (!session.success || session.value === undefined) {
      this.repository.releaseBleConnection();
      return Result.fail(session.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const opened = await this.repository.connectGattTransport(session.value.id, params.toConnectRecord());
    if (!opened.success || opened.value === undefined) {
      this.repository.releaseBleConnection();
      return Result.fail(opened.error ?? new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, 'GATT connect failed'));
    }
    this.repository.recordRecentConnection(params.bleDeviceId, params.displayName, 'ble_gatt');
    return Result.ok(new ConnectGattResult(session.value.id, opened.value));
  }
}

export class DisconnectGattUseCase {
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
      await transport.disconnect('user_disconnect');
      this.transportRegistry.remove(sessionId);
      this.repository.releaseBleConnection();
    }
    return this.stopSession.execute(sessionId, 'gatt_disconnected');
  }
}
