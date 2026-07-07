import { Result, ResultError } from 'common_core';
import {
  AppMode,
  CreateSessionInput,
  CreateSessionUseCase,
  DebugLogRecord,
  DebugTarget,
  EnsurePermissionUseCase,
  ModuleType,
  PermissionScenario,
  ProtocolType,
  SendCommandInput,
  SendCommandUseCase,
  SessionType,
  StartSessionUseCase,
  StopSessionUseCase
} from 'feature_debug_core';
import { DeviceFavoriteRecord } from 'common_storage';
import { PermissionDecision } from 'common_platform';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';
import { BluetoothRepository } from '../../data/repository/BluetoothRepository';
import { GattPlatformMapper } from '../../data/mapper/GattPlatformMapper';
import { GattOperationQueue } from '../service/GattOperationQueue';
import { GattWriteChunker } from '../service/GattWriteChunker';
import { GattServiceTreeSnapshot } from '../model/GattServiceTree';
import { BluetoothDevice, BluetoothCapabilitySnapshot } from '../model/BluetoothDevice';
import { BleScanFilter } from '../model/BleScanFilter';
import { ConnectGattResult } from '../model/GattConnectParams';

export class ResolveBluetoothCapabilityUseCase {
  private readonly repository: BluetoothRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  async execute(): Promise<Result<BluetoothCapabilitySnapshot>> {
    const permission: PermissionDecision =
      await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    const adapter = await this.repository.loadAdapterState();
    const adapterOn = adapter.success && adapter.value !== undefined && adapter.value.enabled;
    return Result.ok(new BluetoothCapabilitySnapshot(permission.granted, adapterOn === true));
  }
}

export class SendSppCommandUseCase {
  private readonly sendCommand: SendCommandUseCase;

  constructor(sendCommand: SendCommandUseCase = new SendCommandUseCase()) {
    this.sendCommand = sendCommand;
  }

  async execute(input: SendCommandInput): Promise<Result<DebugLogRecord>> {
    return this.sendCommand.execute(input);
  }
}

export class StartBleScanWithFilterUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  execute(sessionId: string, filter: BleScanFilter): Result<void> {
    return this.repository.startBleScan(sessionId, filter);
  }
}

export class DiscoverGattServicesUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  async execute(sessionId: string, deviceId: string, mtu: number = 23): Promise<Result<GattServiceTreeSnapshot>> {
    return this.repository.discoverGattServices(sessionId, deviceId, mtu);
  }
}

export class ReadGattCharacteristicUseCase {
  private readonly repository: BluetoothRepository;
  private readonly queue: GattOperationQueue;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    queue: GattOperationQueue = new GattOperationQueue()
  ) {
    this.repository = repository;
    this.queue = queue;
  }

  async execute(
    sessionId: string,
    serviceUuid: string,
    characteristicUuid: string
  ): Promise<Result<string>> {
    const client = this.repository.getGattClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT not connected'));
    }
    const characteristic = client.findCharacteristic(serviceUuid, characteristicUuid);
    if (characteristic === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'Characteristic not found'));
    }
    const readResult = await this.queue.enqueue(() => client.readCharacteristic(characteristic));
    if (!readResult.success || readResult.value === undefined) {
      return Result.fail(readResult.error ?? new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'Read failed'));
    }
    return Result.ok(GattPlatformMapper.valueToHex(readResult.value.characteristicValue));
  }
}

export class WriteGattCharacteristicUseCase {
  private readonly repository: BluetoothRepository;
  private readonly queue: GattOperationQueue;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    queue: GattOperationQueue = new GattOperationQueue()
  ) {
    this.repository = repository;
    this.queue = queue;
  }

  async execute(
    sessionId: string,
    serviceUuid: string,
    characteristicUuid: string,
    bytes: Uint8Array
  ): Promise<Result<void>> {
    const client = this.repository.getGattClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT not connected'));
    }
    const characteristic = client.findCharacteristic(serviceUuid, characteristicUuid);
    if (characteristic === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'Characteristic not found'));
    }
    const tree = this.repository.getGattTree(sessionId);
    const mtu = tree?.mtu ?? 23;
    const chunks = GattWriteChunker.chunk(bytes, mtu);
    for (let i = 0; i < chunks.length; i++) {
      const chunkResult = await this.queue.enqueue(() => client.writeCharacteristic(characteristic, chunks[i]));
      if (!chunkResult.success) {
        return chunkResult;
      }
    }
    return Result.ok(undefined);
  }
}

export class SetGattNotificationUseCase {
  private readonly repository: BluetoothRepository;
  private readonly queue: GattOperationQueue;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    queue: GattOperationQueue = new GattOperationQueue()
  ) {
    this.repository = repository;
    this.queue = queue;
  }

  async execute(
    sessionId: string,
    serviceUuid: string,
    characteristicUuid: string,
    enable: boolean,
    useIndication: boolean = false
  ): Promise<Result<void>> {
    const client = this.repository.getGattClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT not connected'));
    }
    const characteristic = client.findCharacteristic(serviceUuid, characteristicUuid);
    if (characteristic === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'Characteristic not found'));
    }
    if (useIndication) {
      return this.queue.enqueue(() =>
        enable ? client.enableIndication(characteristic) : client.disableIndication(characteristic)
      );
    }
    return this.queue.enqueue(() =>
      enable ? client.enableNotification(characteristic) : client.disableNotification(characteristic)
    );
  }
}

export class ReadGattDescriptorUseCase {
  private readonly repository: BluetoothRepository;
  private readonly queue: GattOperationQueue;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    queue: GattOperationQueue = new GattOperationQueue()
  ) {
    this.repository = repository;
    this.queue = queue;
  }

  async execute(
    sessionId: string,
    serviceUuid: string,
    characteristicUuid: string,
    descriptorUuid: string
  ): Promise<Result<string>> {
    const client = this.repository.getGattClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT not connected'));
    }
    const descriptor = client.findDescriptor(serviceUuid, characteristicUuid, descriptorUuid);
    if (descriptor === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'Descriptor not found'));
    }
    const readResult = await this.queue.enqueue(() => client.readDescriptor(descriptor));
    if (!readResult.success || readResult.value === undefined) {
      return Result.fail(readResult.error ?? new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'Read failed'));
    }
    return Result.ok(GattPlatformMapper.valueToHex(readResult.value.descriptorValue));
  }
}

export class WriteGattDescriptorUseCase {
  private readonly repository: BluetoothRepository;
  private readonly queue: GattOperationQueue;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    queue: GattOperationQueue = new GattOperationQueue()
  ) {
    this.repository = repository;
    this.queue = queue;
  }

  async execute(
    sessionId: string,
    serviceUuid: string,
    characteristicUuid: string,
    descriptorUuid: string,
    bytes: Uint8Array
  ): Promise<Result<void>> {
    const client = this.repository.getGattClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT not connected'));
    }
    return this.queue.enqueue(() =>
      client.writeDescriptorByUuid(serviceUuid, characteristicUuid, descriptorUuid, bytes)
    );
  }
}

export class RequestBleMtuUseCase {
  private readonly repository: BluetoothRepository;
  private readonly queue: GattOperationQueue;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    queue: GattOperationQueue = new GattOperationQueue()
  ) {
    this.repository = repository;
    this.queue = queue;
  }

  async execute(sessionId: string, mtu: number): Promise<Result<number>> {
    const client = this.repository.getGattClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT not connected'));
    }
    const result = await this.queue.enqueue(() => client.requestMtu(mtu));
    if (result.success) {
      const tree = this.repository.getGattTree(sessionId);
      if (tree !== undefined) {
        await this.repository.discoverGattServices(sessionId, tree.deviceId, mtu);
      }
    }
    return result;
  }
}

export class SaveBluetoothFavoriteUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  async execute(device: BluetoothDevice, alias: string, protocol: string, uuid: string = ''): Promise<Result<void>> {
    return this.repository.saveFavorite(device, alias, protocol, uuid);
  }

  listFavorites(): DeviceFavoriteRecord[] {
    return this.repository.listFavorites();
  }
}

export class LoadRemoteProfileUuidsUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  async execute(deviceId: string): Promise<Result<string[]>> {
    return this.repository.getRemoteProfileUuids(deviceId);
  }
}

export class ConnectGattBrowserUseCase {
  private readonly repository: BluetoothRepository;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly createSession: CreateSessionUseCase;
  private readonly startSession: StartSessionUseCase;
  private readonly discoverServices: DiscoverGattServicesUseCase;

  constructor(
    repository: BluetoothRepository = BluetoothRepository.getInstance(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    createSession: CreateSessionUseCase = new CreateSessionUseCase(),
    startSession: StartSessionUseCase = new StartSessionUseCase(),
    discoverServices: DiscoverGattServicesUseCase = new DiscoverGattServicesUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
    this.createSession = createSession;
    this.startSession = startSession;
    this.discoverServices = discoverServices;
  }

  async execute(deviceId: string, displayName: string): Promise<Result<ConnectGattResult>> {
    const permission: PermissionDecision =
      await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    if (!permission.granted) {
      return Result.fail(new ResultError(BluetoothErrorCodes.PERMISSION_DENIED, 'Bluetooth permission denied'));
    }
    const adapter = await this.repository.loadAdapterState();
    if (!adapter.success || adapter.value === undefined || !adapter.value.enabled) {
      return Result.fail(new ResultError(BluetoothErrorCodes.ADAPTER_OFF, 'Bluetooth adapter is off'));
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
    const created = await this.createSession.execute(input);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError('YW-SESSION-1001', 'Session create failed'));
    }
    const started = await this.startSession.execute(created.value.id);
    if (!started.success) {
      return Result.fail(started.error ?? new ResultError('YW-SESSION-1003', 'Session start failed'));
    }
    const connected = await this.repository.connectGattBrowser(created.value.id, deviceId);
    if (!connected.success) {
      this.repository.releaseGattClient(created.value.id);
      return Result.fail(connected.error ?? new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, 'connect failed'));
    }
    const discovered = await this.discoverServices.execute(created.value.id, deviceId);
    if (!discovered.success) {
      this.repository.releaseGattClient(created.value.id);
      return Result.fail(discovered.error ?? new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'discover failed'));
    }
    this.repository.recordRecentConnection(deviceId, displayName, 'ble_gatt_browser');
    return Result.ok(new ConnectGattResult(created.value.id, created.value.id));
  }
}
