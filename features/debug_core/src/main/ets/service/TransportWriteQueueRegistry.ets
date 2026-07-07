import { AsyncSerialQueue } from 'common_core';

/**
 * Per-transport command write queues per architecture §13.2.
 */
export class TransportWriteQueueRegistry {
  private static instance: TransportWriteQueueRegistry | undefined;
  private readonly queues: Map<string, AsyncSerialQueue> = new Map();

  private constructor() {
  }

  static getInstance(): TransportWriteQueueRegistry {
    if (TransportWriteQueueRegistry.instance === undefined) {
      TransportWriteQueueRegistry.instance = new TransportWriteQueueRegistry();
    }
    return TransportWriteQueueRegistry.instance;
  }

  getQueue(transportId: string): AsyncSerialQueue {
    let queue = this.queues.get(transportId);
    if (queue === undefined) {
      queue = new AsyncSerialQueue();
      this.queues.set(transportId, queue);
    }
    return queue;
  }

  removeQueue(transportId: string): void {
    const queue = this.queues.get(transportId);
    if (queue !== undefined) {
      queue.clear();
      this.queues.delete(transportId);
    }
  }

  clear(): void {
    this.queues.forEach((queue: AsyncSerialQueue) => {
      queue.clear();
    });
    this.queues.clear();
  }
}
