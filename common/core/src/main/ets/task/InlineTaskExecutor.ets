import { CancellationToken } from '../cancellation/CancellationToken';
import { ITaskExecutor, TaskExecutionPolicy, TaskSubmitOptions } from './ITaskExecutor';

/**
 * Default executor: runs on the caller thread/event loop.
 */
export class InlineTaskExecutor implements ITaskExecutor {
  async execute<T>(task: () => Promise<T>, options?: TaskSubmitOptions): Promise<T> {
    InlineTaskExecutor.throwIfCancelled(options?.cancelToken);
    return task();
  }

  async executeSync<T>(task: () => T, options?: TaskSubmitOptions): Promise<T> {
    InlineTaskExecutor.throwIfCancelled(options?.cancelToken);
    return task();
  }

  private static throwIfCancelled(token: CancellationToken | undefined): void {
    if (token !== undefined && token.isCancellationRequested) {
      throw new Error('YW-CORE-9001: Task cancelled before execution');
    }
  }
}
