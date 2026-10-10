import { Result, ResultError } from 'common_core';
import {
  AppMode,
  CreateSessionInput,
  DebugTarget,
  ModuleType,
  ProtocolType,
  SessionType
} from 'debug_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothRepositoryContract } from '../../repository/BluetoothRepositoryContract';
import { bluetoothRepository } from '../../repository/BluetoothRepositories';
import { ConnectGattResult } from '../../model/GattConnectParams';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';
import { BluetoothSessionBootstrap } from '../shared/BluetoothSessionBootstrap';
import { DiscoverGattServicesUseCase } from './GattOperationUseCases';

export class ConnectGattBrowserUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly guard: BluetoothOperationGuard;
  private readonly sessionBootstrap: BluetoothSessionBootstrap;
  private readonly discoverServices: DiscoverGattServicesUseCase;

  constructor(
    repository: BluetoothRepositoryContract = bluetoothRepository(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard(),
    sessionBootstrap: BluetoothSessionBootstrap = new BluetoothSessionBootstrap(),
    discoverServices: DiscoverGattServicesUseCase = new DiscoverGattServicesUseCase()
  ) {
    this.repository = repository;
    this.guard = guard;
    this.sessionBootstrap = sessionBootstrap;
    this.discoverServices = discoverServices;
  }

  async execute(bleDeviceId: string, displayName: string): Promise<Result<ConnectGattResult>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    if (bleDeviceId.length === 0) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.GATT_CLASSIC_ADDRESS_REJECTED,
        'bleDeviceId required for GATT browser'
      ));
    }
    if (!this.repository.tryReserveBleConnection()) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.BLE_GATT_SESSION_LIMIT,
        'GATT session limit'
      ));
    }
    this.repository.stopBleScan('');
    const target = new DebugTarget(
      bleDeviceId,
      ModuleType.BLUETOOTH,
      displayName,
      ProtocolType.BLE_GATT,
      bleDeviceId,
      'virtual'
    );
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.BLUETOOTH,
      ProtocolType.BLE_GATT,
      `GATT Browser ${displayName}`,
      AppMode.EXPERT,
      target
    );
    const session = await this.sessionBootstrap.createAndStart(input);
    if (!session.success || session.value === undefined) {
      this.repository.releaseBleConnection();
      return Result.fail(session.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const connected = await this.repository.connectGattBrowser(session.value.id, bleDeviceId);
    if (!connected.success) {
      this.repository.releaseGattClient(session.value.id);
      this.repository.releaseBleConnection();
      return Result.fail(connected.error ?? new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, 'connect failed'));
    }
    const discovered = await this.discoverServices.execute(session.value.id, bleDeviceId);
    if (!discovered.success) {
      this.repository.releaseGattClient(session.value.id);
      this.repository.releaseBleConnection();
      return Result.fail(discovered.error ?? new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'discover failed'));
    }
    this.repository.recordRecentConnection(bleDeviceId, displayName, 'ble_gatt_browser');
    return Result.ok(new ConnectGattResult(session.value.id, session.value.id));
  }
}
