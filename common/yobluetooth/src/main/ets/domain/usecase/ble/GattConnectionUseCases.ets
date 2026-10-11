import { Result, ResultError } from 'common_core';
import {
  AppMode,
  CreateSessionInput,
  DebugTarget,
  ITransportSession,
  ModuleType,
  ProtocolType,
  SessionType,
  StopSessionUseCase,
  TransportSessionRegistry
} from 'debug_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothRepositoryContract } from '../../repository/BluetoothRepositoryContract';
import { ConnectGattResult, GattConnectParams } from '../../model/GattConnectParams';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';
import { BluetoothSessionBootstrap } from '../shared/BluetoothSessionBootstrap';

export class ConnectGattUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly guard: BluetoothOperationGuard;
  private readonly sessionBootstrap: BluetoothSessionBootstrap;
  private readonly transportRegistry: TransportSessionRegistry;

  constructor(
    repository: BluetoothRepositoryContract,
    guard: BluetoothOperationGuard,
    sessionBootstrap: BluetoothSessionBootstrap,
    transportRegistry: TransportSessionRegistry
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
    if (params.bleDeviceId.length === 0) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.GATT_CLASSIC_ADDRESS_REJECTED,
        'bleDeviceId required for GATT'
      ));
    }
    const scanned = this.repository.listBleDevices();
    for (let i = 0; i < scanned.length; i++) {
      const device = scanned[i];
      if (device.bleDeviceId === params.bleDeviceId && !device.connectable) {
        return Result.fail(new ResultError(
          BluetoothErrorCodes.NOT_CONNECTABLE,
          'Advertisement is not connectable'
        ));
      }
    }
    if (!this.repository.tryReserveBleConnection()) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.BLE_GATT_SESSION_LIMIT,
        `GATT session limit ${BluetoothConstants.GATT_MAX_SESSIONS}`
      ));
    }
    this.repository.stopBleScan('');
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
    const created = this.repository.createGattTransport(session.value.id);
    const transport = created as ITransportSession;
    try {
      await transport.connect(params.toConnectRecord());
    } catch (error) {
      const err = error as Error;
      transport.destroy();
      this.repository.releaseBleConnection();
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, err.message, err));
    }
    this.transportRegistry.register(session.value.id, transport);
    this.repository.recordRecentConnection(params.bleDeviceId, params.displayName, 'ble_gatt');
    return Result.ok(new ConnectGattResult(session.value.id, transport.id));
  }
}

export class DisconnectGattUseCase {
  private readonly transportRegistry: TransportSessionRegistry;
  private readonly stopSession: StopSessionUseCase;
  private readonly repository: BluetoothRepositoryContract;

  constructor(
    transportRegistry: TransportSessionRegistry,
    stopSession: StopSessionUseCase,
    repository: BluetoothRepositoryContract
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
