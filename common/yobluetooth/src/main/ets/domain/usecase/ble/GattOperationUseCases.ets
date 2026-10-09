import { Result, ResultError } from 'common_core';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { GattPlatformMapper } from '../../../data/mapper/GattPlatformMapper';
import { BluetoothRepository } from '../../../data/repository/BluetoothRepository';
import { ConnectionParamPreset } from '../../model/ConnectionParamPreset';
import { GattServiceTreeSnapshot } from '../../model/GattServiceTree';
import { GattOperationQueue } from '../../service/GattOperationQueue';
import { GattWriteChunker } from '../../service/GattWriteChunker';
import { MtuBounds } from '../../model/MtuBounds';

export class DiscoverGattServicesUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  async execute(sessionId: string, bleDeviceId: string, mtu: number = 23): Promise<Result<GattServiceTreeSnapshot>> {
    return this.repository.discoverGattServices(sessionId, bleDeviceId, mtu);
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
    if (!client.hasServiceTree()) {
      return Result.fail(new ResultError(BluetoothErrorCodes.GATT_SEQUENCE, 'Service discovery is not finished'));
    }
    const characteristic = client.findCharacteristic(serviceUuid, characteristicUuid);
    if (characteristic === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.GATT_SERVICE_MISSING, 'Characteristic not in discovered services'));
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
    bytes: Uint8Array,
    noResponse: boolean = false
  ): Promise<Result<void>> {
    const client = this.repository.getGattClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT not connected'));
    }
    if (!client.hasServiceTree()) {
      return Result.fail(new ResultError(BluetoothErrorCodes.GATT_SEQUENCE, 'Service discovery is not finished'));
    }
    const characteristic = client.findCharacteristic(serviceUuid, characteristicUuid);
    if (characteristic === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.GATT_SERVICE_MISSING, 'Characteristic not in discovered services'));
    }
    const tree = this.repository.getGattTree(sessionId);
    const mtu = tree?.mtu ?? BluetoothConstants.BLE_DEFAULT_MTU;
    const chunks = GattWriteChunker.chunk(bytes, mtu);
    for (let i = 0; i < chunks.length; i++) {
      const chunkResult = await this.queue.enqueue(() =>
        client.writeCharacteristic(characteristic, chunks[i], noResponse)
      );
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
    if (!client.hasServiceTree()) {
      return Result.fail(new ResultError(BluetoothErrorCodes.GATT_SEQUENCE, 'Service discovery is not finished'));
    }
    const characteristic = client.findCharacteristic(serviceUuid, characteristicUuid);
    if (characteristic === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.GATT_SERVICE_MISSING, 'Characteristic not in discovered services'));
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
    if (!client.hasServiceTree()) {
      return Result.fail(new ResultError(BluetoothErrorCodes.GATT_SEQUENCE, 'Service discovery is not finished'));
    }
    const descriptor = client.findDescriptor(serviceUuid, characteristicUuid, descriptorUuid);
    if (descriptor === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.GATT_SERVICE_MISSING, 'Descriptor not in discovered services'));
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
    if (!client.hasServiceTree()) {
      return Result.fail(new ResultError(BluetoothErrorCodes.GATT_SEQUENCE, 'Service discovery is not finished'));
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
    const bounds = MtuBounds.accept(mtu);
    if (!bounds.success) {
      return Result.fail(bounds.error ?? new ResultError(BluetoothErrorCodes.MTU_OUT_OF_RANGE, 'MTU out of range'));
    }
    const client = this.repository.getGattClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT not connected'));
    }
    const result = await this.queue.enqueue(() => client.requestMtu(mtu));
    if (result.success) {
      const tree = this.repository.getGattTree(sessionId);
      if (tree !== undefined) {
        await this.repository.discoverGattServices(sessionId, tree.bleDeviceId, client.currentMtu());
      }
    }
    return result;
  }
}

export class ReadGattRssiUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  async execute(sessionId: string): Promise<Result<number>> {
    const client = this.repository.getGattClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT not connected'));
    }
    return client.readRssi();
  }
}

export class UpdateGattConnectionParamUseCase {
  private readonly repository: BluetoothRepository;

  constructor(repository: BluetoothRepository = BluetoothRepository.getInstance()) {
    this.repository = repository;
  }

  async execute(sessionId: string, preset: ConnectionParamPreset): Promise<Result<void>> {
    const client = this.repository.getGattClient(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT not connected'));
    }
    return client.updateConnectionParam(preset);
  }
}
