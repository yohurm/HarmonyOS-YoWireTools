import { CancellationToken } from '../cancellation/CancellationToken';
import { createPendingWork, PendingAsyncWork } from './PendingAsyncWork';

export type ConcurrentTask<T> = () => Promise<T>;

/**
 * Limits concurrent async tasks to a fixed maximum parallelism.
 */
export class LimitedConcurrencyExecutor {
  private readonly maxConcurrency: number;
  private readonly pending: PendingAsyncWork[] = [];
  private activeCount: number = 0;

  constructor(maxConcurrency: number) {
    this.maxConcurrency = Math.max(1, maxConcurrency);
  }

  get activeTasks(): number {
    return this.activeCount;
  }

  get queuedTasks(): number {
    return this.pending.length;
  }

  execute<T>(task: ConcurrentTask<T>, token: CancellationToken = CancellationToken.none()): Promise<T> {
    return new Promise<T>((resolve, reject) => {
      if (token.isCancellationRequested) {
        reject(new Error('Operation was cancelled'));
        return;
      }
      this.pending.push(createPendingWork(task, resolve, reject, token));
      this.schedule();
    });
  }

  cancelAll(reason: string = 'Executor cancelled'): void {
    const error = new Error(reason);
    while (this.pending.length > 0) {
      const entry = this.pending.shift();
      if (entry !== undefined) {
        entry.cancel(error);
      }
    }
  }

  private schedule(): void {
    while (this.activeCount < this.maxConcurrency && this.pending.length > 0) {
      const entry = this.pending.shift();
      if (entry === undefined) {
        return;
      }
      if (entry.token.isCancellationRequested) {
        entry.cancel(new Error('Operation was cancelled'));
        continue;
      }
      this.activeCount++;
      entry.execute()
        .finally(() => {
          this.activeCount--;
          this.schedule();
        });
    }
  }
}
