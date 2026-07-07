import { Result, ResultError, Subscription } from 'common_core';
import {
  AppMode,
  CreateSessionInput,
  CreateSessionUseCase,
  DebugTarget,
  EnsurePermissionUseCase,
  ModuleType,
  PermissionScenario,
  ProtocolType,
  SessionType,
  StartSessionUseCase,
  StopSessionUseCase,
  TransportSessionRegistry
} from 'feature_debug_core';
import { PermissionDecision } from 'common_platform';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';
import { BluetoothRepository } from '../../data/repository/BluetoothRepository';
import { GattTransportSession } from '../../data/transport/GattTransportSession';
import { BluetoothDevice } from '../model/BluetoothDevice';
import { ConnectSppResult, SppConnectParams } from '../model/SppConnectParams';
import { ConnectGattResult, GattConnectParams } from '../model/GattConnectParams';
import { BleScanFilter } from '../model/BleScanFilter';
import { PairingCoordinator } from '../service/PairingCoordinator';
import { PairingEvent } from '../model/PairingState';
import { BluetoothScanLogger } from '../service/BluetoothScanLogger';

export class StartClassicScanUseCase {
  private readonly repository: BluetoothRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
  }

  async execute(): Promise<Result<string>> {
    const permission: PermissionDecision = await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    if (!permission.granted) {
      return Result.fail(new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Bluetooth permission denied'));
    }
    const adapter = await this.repository.loadAdapterState();
    if (!adapter.success || adapter.value === undefined || !adapter.value.enabled) {
      return Result.fail(new ResultError(BluetoothErrorCodes.ADAPTER_OFF, 'Bluetooth adapter is off'));
    }
    await this.repository.loadPairedDevices();
    const input = new CreateSessionInput(
      SessionType.SCAN,
      ModuleType.BLUETOOTH,
      ProtocolType.CLASSIC_SCAN,
      'Classic Bluetooth Scan',
      AppMode.EXPERT
    );
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const started = await this.startSession.execute(created.value.id);
    if (!started.success) {
      return Result.fail(started.error ?? new ResultError('YW-SESSION-1003', 'Session start failed'));
    }
    const discovery = await this.repository.startClassicDiscovery(created.value.id);
    if (!discovery.success) {
      return Result.fail(discovery.error ?? new ResultError(BluetoothErrorCodes.SCAN_RESOURCE_FAILED, 'Scan failed'));
    }
    await BluetoothScanLogger.logClassic(created.value.id, 'Classic scan started');
    return Result.ok(created.value.id);
  }
}

export class StopClassicScanUseCase {
  private readonly repository: BluetoothRepository;
  private readonly stopSession: StopSessionUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    stopSession: StopSessionUseCase = new StopSessionUseCase()
  ) {
    this.repository = repository;
    this.stopSession = stopSession;
  }

  async execute(sessionId: string): Promise<Result<void>> {
    const stopped = await this.repository.stopClassicDiscovery();
    if (!stopped.success) {
      return stopped;
    }
    if (sessionId.length > 0) {
      await BluetoothScanLogger.logClassic(
        sessionId,
        `Classic scan stopped, devices=${this.repository.listClassicDevices().length}`
      );
      await this.stopSession.execute(sessionId, 'scan_stopped');
    }
    this.repository.resetClassicScanPhase();
    return Result.ok(undefined);
  }
}

export class PairBluetoothDeviceUseCase {
  private readonly repository: BluetoothRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(deviceId: string): Promise<Result<void>> {
    const permission: PermissionDecision = await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    if (!permission.granted) {
      return Result.fail(new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Bluetooth permission denied'));
    }
    return this.repository.pairDevice(deviceId);
  }
}

export class ObservePairingEventsUseCase {
  private readonly coordinator: PairingCoordinator;

  constructor(coordinator: PairingCoordinator = PairingCoordinator.getInstance()) {
    this.coordinator = coordinator;
  }

  execute(listener: (event: PairingEvent) => void) {
    return this.coordinator.subscribe(listener);
  }
}

export class StartBleScanUseCase {
  private readonly repository: BluetoothRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
  }

  async execute(serviceUuid: string = '', filter?: BleScanFilter): Promise<Result<string>> {
    const permission: PermissionDecision = await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    if (!permission.granted) {
      return Result.fail(new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Bluetooth permission denied'));
    }
    const adapter = await this.repository.loadAdapterState();
    if (!adapter.success || adapter.value === undefined || !adapter.value.enabled) {
      return Result.fail(new ResultError(BluetoothErrorCodes.ADAPTER_OFF, 'Bluetooth adapter is off'));
    }
    const input = new CreateSessionInput(
      SessionType.SCAN,
      ModuleType.BLUETOOTH,
      ProtocolType.BLE_SCAN,
      'BLE Scan',
      AppMode.EXPERT
    );
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const started = await this.startSession.execute(created.value.id);
    if (!started.success) {
      return Result.fail(started.error ?? new ResultError('YW-SESSION-1003', 'Session start failed'));
    }
    const scanFilter = filter ?? new BleScanFilter('', '', serviceUuid);
    const scan = this.repository.startBleScan(created.value.id, scanFilter);
    if (!scan.success) {
      return Result.fail(scan.error ?? new ResultError(BluetoothErrorCodes.BLE_SCAN_FAILED, 'BLE scan failed'));
    }
    await BluetoothScanLogger.logBle(created.value.id, 'BLE scan started');
    return Result.ok(created.value.id);
  }
}

export class StopBleScanUseCase {
  private readonly repository: BluetoothRepository;
  private readonly stopSession: StopSessionUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    stopSession: StopSessionUseCase = new StopSessionUseCase()
  ) {
    this.repository = repository;
    this.stopSession = stopSession;
  }

  async execute(sessionId: string): Promise<Result<void>> {
    const stopped = this.repository.stopBleScan();
    if (!stopped.success) {
      return stopped;
    }
    if (sessionId.length > 0) {
      await BluetoothScanLogger.logBle(
        sessionId,
        `BLE scan stopped, devices=${this.repository.listBleDevices().length}`
      );
      await this.stopSession.execute(sessionId, 'ble_scan_stopped');
    }
    this.repository.resetBleScanPhase();
    return Result.ok(undefined);
  }
}

export class ConnectSppUseCase {
  private readonly repository: BluetoothRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  private readonly transportRegistry: TransportSessionRegistry;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
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

  async execute(params: SppConnectParams): Promise<Result<ConnectSppResult>> {
    const permission: PermissionDecision = await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    if (!permission.granted) {
      return Result.fail(new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Bluetooth permission denied'));
    }
    const adapter = await this.repository.loadAdapterState();
    if (!adapter.success || adapter.value === undefined || !adapter.value.enabled) {
      return Result.fail(new ResultError(BluetoothErrorCodes.ADAPTER_OFF, 'Bluetooth adapter is off'));
    }
    await this.repository.ensureClassicDiscoveryStopped();
    const target = new DebugTarget(
      params.deviceId,
      ModuleType.BLUETOOTH,
      params.displayName,
      ProtocolType.SPP,
      params.deviceId,
      'virtual'
    );
    const input = new CreateSessionInput(
      SessionType.CONNECTION,
      ModuleType.BLUETOOTH,
      ProtocolType.SPP,
      `SPP ${params.displayName}`,
      AppMode.EXPERT,
      target
    );
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const started = await this.startSession.execute(created.value.id);
    if (!started.success) {
      return Result.fail(started.error ?? new ResultError('YW-SESSION-1003', 'Session start failed'));
    }
    const transport = this.repository.createSppTransport(created.value.id, params);
    try {
      await transport.connect(params.toConnectRecord());
    } catch (error) {
      const err = error as Error;
      transport.destroy();
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_CONNECT_FAILED, err.message, err));
    }
    this.transportRegistry.register(created.value.id, transport);
    this.repository.recordRecentConnection(params.deviceId, params.displayName, 'spp');
    return Result.ok(new ConnectSppResult(created.value.id, transport.id));
  }
}

export class DisconnectSppUseCase {
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
    return this.stopSession.execute(sessionId, 'spp_disconnected');
  }
}

export class ConnectGattUseCase {
  private readonly repository: BluetoothRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  private readonly transportRegistry: TransportSessionRegistry;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
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

  async execute(params: GattConnectParams): Promise<Result<ConnectGattResult>> {
    const permission: PermissionDecision = await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    if (!permission.granted) {
      return Result.fail(new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Bluetooth permission denied'));
    }
    const adapter = await this.repository.loadAdapterState();
    if (!adapter.success || adapter.value === undefined || !adapter.value.enabled) {
      return Result.fail(new ResultError(BluetoothErrorCodes.ADAPTER_OFF, 'Bluetooth adapter is off'));
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
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const started = await this.startSession.execute(created.value.id);
    if (!started.success) {
      return Result.fail(started.error ?? new ResultError('YW-SESSION-1003', 'Session start failed'));
    }
    const transport = new GattTransportSession(created.value.id);
    try {
      await transport.connect(params.toConnectRecord());
    } catch (error) {
      const err = error as Error;
      transport.destroy();
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, err.message, err));
    }
    this.transportRegistry.register(created.value.id, transport);
    this.repository.recordRecentConnection(params.deviceId, params.displayName, 'ble_gatt');
    return Result.ok(new ConnectGattResult(created.value.id, transport.id));
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

export class LoadBluetoothOverviewUseCase {
  private readonly repository: BluetoothRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(): Promise<Result<BluetoothDevice[]>> {
    const permission: PermissionDecision = await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    if (!permission.granted) {
      return Result.ok([]);
    }
    return this.repository.loadPairedDevices();
  }
}

export class BluetoothSubscriptionBundle {
  readonly classicDevices: Subscription;
  readonly bleDevices: Subscription;

  constructor(classicDevices: Subscription, bleDevices: Subscription) {
    this.classicDevices = classicDevices;
    this.bleDevices = bleDevices;
  }

  dispose(): void {
    this.classicDevices.dispose();
    this.bleDevices.dispose();
  }
}

export class ObserveBluetoothDevicesUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  execute(
    onClassic: (devices: BluetoothDevice[]) => void,
    onBle: (devices: BluetoothDevice[]) => void
  ): BluetoothSubscriptionBundle {
    const classic = this.repository.observeClassicDevices().subscribe(onClassic);
    const ble = this.repository.observeBleDevices().subscribe(onBle);
    return new BluetoothSubscriptionBundle(classic, ble);
  }
}
