import { CancellationToken } from '../cancellation/CancellationToken';
import { createPendingWork, PendingAsyncWork } from './PendingAsyncWork';

export type QueueTask<T> = () => Promise<T>;

/**
 * Serial async queue: one task runs at a time in enqueue order.
 */
export class AsyncSerialQueue {
  private readonly pending: PendingAsyncWork[] = [];
  private running: boolean = false;

  get pendingCount(): number {
    return this.pending.length;
  }

  get isRunning(): boolean {
    return this.running;
  }

  enqueue<T>(task: QueueTask<T>, token: CancellationToken = CancellationToken.none()): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      if (token.isCancellationRequested) {
        reject(new Error('Operation was cancelled'));
        return;
      }
      this.pending.push(createPendingWork(task, resolve, reject, token));
      this.drain();
    });
  }

  clear(): void {
    while (this.pending.length > 0) {
      const entry = this.pending.shift();
      if (entry !== undefined) {
        entry.cancel(new Error('Queue cleared'));
      }
    }
  }

  private drain(): void {
    if (this.running) {
      return;
    }
    const next = this.pending.shift();
    if (next === undefined) {
      return;
    }
    if (next.token.isCancellationRequested) {
      next.cancel(new Error('Operation was cancelled'));
      this.drain();
      return;
    }
    this.running = true;
    next.execute()
      .finally(() => {
        this.running = false;
        this.drain();
      });
  }
}
