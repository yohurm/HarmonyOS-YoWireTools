import { ITaskExecutor } from './ITaskExecutor';
import { InlineTaskExecutor } from './InlineTaskExecutor';

/**
 * Global task executor registry. Platform bootstrap should register TaskPool adapter.
 */
export class TaskExecutorRegistry {
  private static executor: ITaskExecutor = new InlineTaskExecutor();

  static register(executor: ITaskExecutor): void {
    TaskExecutorRegistry.executor = executor;
  }

  static get(): ITaskExecutor {
    return TaskExecutorRegistry.executor;
  }

  static resetForTest(): void {
    TaskExecutorRegistry.executor = new InlineTaskExecutor();
  }
}
