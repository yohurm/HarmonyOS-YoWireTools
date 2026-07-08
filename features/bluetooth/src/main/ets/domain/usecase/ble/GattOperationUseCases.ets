import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { GattPlatformMapper } from '../../../data/mapper/GattPlatformMapper';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';
import { GattServiceTreeSnapshot } from '../../model/GattServiceTree';
import { GattOperationQueue } from '../../service/GattOperationQueue';
import { GattWriteChunker } from '../../service/GattWriteChunker';

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
