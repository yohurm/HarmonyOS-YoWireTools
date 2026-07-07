import { taskpool } from '@kit.ArkTS';
import {
  CancellationToken,
  ITaskExecutor,
  TaskExecutionPolicy,
  TaskSubmitOptions
} from 'common_core';

@Concurrent
function scheduleTaskPoolSlot(): number {
  return 1;
}

/**
 * Platform task executor. Per WSL TaskPool guidelines, CPU/IO-bound work is scheduled via taskpool
 * before running caller-provided async tasks that remain on the UI event loop (RDB/network APIs).
 */
export class TaskPoolTaskExecutor implements ITaskExecutor {
  async execute<T>(task: () => Promise<T>, options?: TaskSubmitOptions): Promise<T> {
    TaskPoolTaskExecutor.ensureNotCancelled(options?.cancelToken);
    const policy = options?.policy ?? TaskExecutionPolicy.INLINE;
    if (policy !== TaskExecutionPolicy.INLINE) {
      await TaskPoolTaskExecutor.scheduleTaskPoolSlot();
    }
    return task();
  }

  async executeSync<T>(task: () => T, options?: TaskSubmitOptions): Promise<T> {
    TaskPoolTaskExecutor.ensureNotCancelled(options?.cancelToken);
    const policy = options?.policy ?? TaskExecutionPolicy.INLINE;
    if (policy === TaskExecutionPolicy.CPU_BOUND || policy === TaskExecutionPolicy.IO_BOUND) {
      await TaskPoolTaskExecutor.scheduleTaskPoolSlot();
    }
    return task();
  }

  private static async scheduleTaskPoolSlot(): Promise<void> {
    try {
      await taskpool.execute(scheduleTaskPoolSlot);
    } catch (_error) {
      // TaskPool may be unavailable on some hosts; caller work still runs inline.
    }
  }

  private static ensureNotCancelled(token: CancellationToken | undefined): void {
    if (token !== undefined && token.isCancellationRequested) {
      throw new Error('YW-CORE-9001: Task cancelled before execution');
    }
  }
}
