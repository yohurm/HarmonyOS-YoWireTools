import { Result, ResultError } from 'common_core';
import {
  AppMode,
  CreateSessionInput,
  DebugTarget,
  ModuleType,
  ProtocolType,
  SessionType
} from 'feature_debug_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';
import { ConnectGattResult } from '../../model/GattConnectParams';
import { BluetoothOperationGuard } from '../shared/BluetoothOperationGuard';
import { BluetoothSessionBootstrap } from '../shared/BluetoothSessionBootstrap';
import { DiscoverGattServicesUseCase } from './GattOperationUseCases';

export class ConnectGattBrowserUseCase {
  private readonly repository: BluetoothRepository;
  private readonly guard: BluetoothOperationGuard;
  private readonly sessionBootstrap: BluetoothSessionBootstrap;
  private readonly discoverServices: DiscoverGattServicesUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    guard: BluetoothOperationGuard = new BluetoothOperationGuard(),
    sessionBootstrap: BluetoothSessionBootstrap = new BluetoothSessionBootstrap(),
    discoverServices: DiscoverGattServicesUseCase = new DiscoverGattServicesUseCase()
  ) {
    this.repository = repository;
    this.guard = guard;
    this.sessionBootstrap = sessionBootstrap;
    this.discoverServices = discoverServices;
  }

  async execute(deviceId: string, displayName: string): Promise<Result<ConnectGattResult>> {
    const ready = await this.guard.ensureOperational();
    if (!ready.success) {
      return Result.fail(ready.error ?? new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Not ready'));
    }
    this.repository.stopBleScan();
    const target = new DebugTarget(
      deviceId,
      ModuleType.BLUETOOTH,
      displayName,
      ProtocolType.BLE_GATT,
      deviceId,
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
      return Result.fail(session.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const connected = await this.repository.connectGattBrowser(session.value.id, deviceId);
    if (!connected.success) {
      this.repository.releaseGattClient(session.value.id);
      return Result.fail(connected.error ?? new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, 'connect failed'));
    }
    const discovered = await this.discoverServices.execute(session.value.id, deviceId);
    if (!discovered.success) {
      this.repository.releaseGattClient(session.value.id);
      return Result.fail(discovered.error ?? new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'discover failed'));
    }
    this.repository.recordRecentConnection(deviceId, displayName, 'ble_gatt_browser');
    return Result.ok(new ConnectGattResult(session.value.id, session.value.id));
  }
}
