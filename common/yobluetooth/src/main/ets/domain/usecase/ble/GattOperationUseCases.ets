import { Result, ResultError } from 'common_core';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { ConnectionParamPreset } from '../../model/ConnectionParamPreset';
import { GattServiceTreeSnapshot } from '../../model/GattServiceTree';
import { MtuBounds } from '../../model/MtuBounds';
import { BluetoothRepositoryContract } from '../../repository/BluetoothRepositoryContract';
import { GattOperationQueue } from '../../service/GattOperationQueue';
import { GattWriteChunker } from '../../service/GattWriteChunker';

export class DiscoverGattServicesUseCase {
  private readonly repository: BluetoothRepositoryContract;

  constructor(repository: BluetoothRepositoryContract) {
    this.repository = repository;
  }

  async execute(sessionId: string, bleDeviceId: string, mtu: number = 23): Promise<Result<GattServiceTreeSnapshot>> {
    return this.repository.discoverGattServices(sessionId, bleDeviceId, mtu);
  }
}

export class ReadGattCharacteristicUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly queue: GattOperationQueue;

  constructor(
    repository: BluetoothRepositoryContract,
    queue: GattOperationQueue
  ) {
    this.repository = repository;
    this.queue = queue;
  }

  async execute(
    sessionId: string,
    serviceUuid: string,
    characteristicUuid: string
  ): Promise<Result<string>> {
    return this.queue.enqueue(() =>
      this.repository.readGattCharacteristicHex(sessionId, serviceUuid, characteristicUuid)
    );
  }
}

export class WriteGattCharacteristicUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly queue: GattOperationQueue;

  constructor(
    repository: BluetoothRepositoryContract,
    queue: GattOperationQueue
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
    const tree = this.repository.getGattTree(sessionId);
    const mtu = tree !== undefined ? tree.mtu : BluetoothConstants.BLE_DEFAULT_MTU;
    const chunks = GattWriteChunker.chunk(bytes, mtu);
    for (let i = 0; i < chunks.length; i++) {
      const chunkResult = await this.queue.enqueue(() =>
        this.repository.writeGattCharacteristicChunk(
          sessionId,
          serviceUuid,
          characteristicUuid,
          chunks[i],
          noResponse
        )
      );
      if (!chunkResult.success) {
        return chunkResult;
      }
    }
    return Result.ok(undefined);
  }
}

export class SetGattNotificationUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly queue: GattOperationQueue;

  constructor(
    repository: BluetoothRepositoryContract,
    queue: GattOperationQueue
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
    return this.queue.enqueue(() =>
      this.repository.setGattNotification(sessionId, serviceUuid, characteristicUuid, enable, useIndication)
    );
  }
}

export class ReadGattDescriptorUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly queue: GattOperationQueue;

  constructor(
    repository: BluetoothRepositoryContract,
    queue: GattOperationQueue
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
    return this.queue.enqueue(() =>
      this.repository.readGattDescriptorHex(sessionId, serviceUuid, characteristicUuid, descriptorUuid)
    );
  }
}

export class WriteGattDescriptorUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly queue: GattOperationQueue;

  constructor(
    repository: BluetoothRepositoryContract,
    queue: GattOperationQueue
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
    return this.queue.enqueue(() =>
      this.repository.writeGattDescriptor(sessionId, serviceUuid, characteristicUuid, descriptorUuid, bytes)
    );
  }
}

export class RequestBleMtuUseCase {
  private readonly repository: BluetoothRepositoryContract;
  private readonly queue: GattOperationQueue;

  constructor(
    repository: BluetoothRepositoryContract,
    queue: GattOperationQueue
  ) {
    this.repository = repository;
    this.queue = queue;
  }

  async execute(sessionId: string, mtu: number): Promise<Result<number>> {
    const bounds = MtuBounds.accept(mtu);
    if (!bounds.success) {
      return Result.fail(bounds.error ?? new ResultError(BluetoothErrorCodes.MTU_OUT_OF_RANGE, 'MTU out of range'));
    }
    const result = await this.queue.enqueue(() => this.repository.requestGattMtu(sessionId, mtu));
    if (result.success) {
      const tree = this.repository.getGattTree(sessionId);
      if (tree !== undefined) {
        await this.repository.discoverGattServices(sessionId, tree.bleDeviceId, this.repository.gattCurrentMtu(sessionId));
      }
    }
    return result;
  }
}

export class ReadGattRssiUseCase {
  private readonly repository: BluetoothRepositoryContract;

  constructor(repository: BluetoothRepositoryContract) {
    this.repository = repository;
  }

  async execute(sessionId: string): Promise<Result<number>> {
    return this.repository.readGattRssi(sessionId);
  }
}

export class UpdateGattConnectionParamUseCase {
  private readonly repository: BluetoothRepositoryContract;

  constructor(repository: BluetoothRepositoryContract) {
    this.repository = repository;
  }

  async execute(sessionId: string, preset: ConnectionParamPreset): Promise<Result<void>> {
    return this.repository.updateGattConnectionParam(sessionId, preset);
  }
}
