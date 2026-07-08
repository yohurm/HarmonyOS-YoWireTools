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
} from 'feature_debug_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { GattTransportSession } from '../../../data/transport/GattTransportSession';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';
import { ConnectGattResult, GattConnectParams } from '../../model/GattConnectParams';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';
import { BluetoothSessionBootstrap } from '../shared/BluetoothSessionBootstrap';

export class ConnectGattUseCase {
  private readonly repository: BluetoothRepository;
  private readonly guard: BluetoothOperationGuard;
  private readonly sessionBootstrap: BluetoothSessionBootstrap;
  private readonly transportRegistry: TransportSessionRegistry;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard(),
    sessionBootstrap: BluetoothSessionBootstrap = new BluetoothSessionBootstrap(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.repository = repository;
    this.guard = guard;
    this.sessionBootstrap = sessionBootstrap;
    this.transportRegistry = transportRegistry;
  }

  async execute(params: GattConnectParams): Promise<Result<ConnectGattResult>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    this.repository.stopBleScan();
    const target = new DebugTarget(
      params.deviceId,
      ModuleType.BLUETOOTH,
      params.displayName,
      ProtocolType.BLE_GATT,
      params.deviceId,
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
      return Result.fail(session.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const transport = new GattTransportSession(session.value.id);
    try {
      await transport.connect(params.toConnectRecord());
    } catch (error) {
      const err = error as Error;
      transport.destroy();
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, err.message, err));
    }
    this.transportRegistry.register(session.value.id, transport);
    this.repository.recordRecentConnection(params.deviceId, params.displayName, 'ble_gatt');
    return Result.ok(new ConnectGattResult(session.value.id, transport.id));
  }
}

export class DisconnectGattUseCase {
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
      await transport.disconnect('user_disconnect');
      this.transportRegistry.remove(sessionId);
    }
    return this.stopSession.execute(sessionId, 'gatt_disconnected');
  }
}
