import { AsyncSerialQueue, Result, ResultError } from 'common_core';
import { TransportWriteQueueRegistry, WriteResult } from 'feature_debug_core';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';

export type CommandWriteTask = () => Promise<WriteResult>;

/**
 * Bluetooth TX write queue with backpressure (architecture bluetooth/05).
 * Bridges feature_debug_core TransportWriteQueueRegistry; adds maxDepth reject policy.
 */
export class CommandWriteQueue {
  private readonly transportId: string;
  private readonly maxDepth: number;
  private readonly registry: TransportWriteQueueRegistry;

  constructor(
    transportId: string,
    maxDepth: number = BluetoothConstants.COMMAND_WRITE_QUEUE_MAX_DEPTH,
    registry: TransportWriteQueueRegistry = TransportWriteQueueRegistry.getInstance()
  ) {
    this.transportId = transportId;
    this.maxDepth = maxDepth;
    this.registry = registry;
  }

  get pendingCount(): number {
    return this.underlying().pendingCount;
  }

  async enqueue(task: CommandWriteTask): Promise<Result<WriteResult>> {
    const queue = this.underlying();
    if (queue.pendingCount >= this.maxDepth) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.WRITE_QUEUE_FULL,
        `TX queue full (max ${this.maxDepth})`
      ));
    }
    try {
      const writeResult = await queue.enqueue(task);
      return Result.ok(writeResult);
    } catch (error) {
      const err = error as Error;
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_IO_ERROR, err.message, err));
    }
  }

  reset(): void {
    this.registry.removeQueue(this.transportId);
  }

  private underlying(): AsyncSerialQueue {
    return this.registry.getQueue(this.transportId);
  }
}
