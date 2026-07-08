import { CancellationToken } from '../cancellation/CancellationToken';
export enum TaskExecutionPolicy {
  INLINE = 'inline',
  IO_BOUND = 'io_bound',
  CPU_BOUND = 'cpu_bound'
}

export class TaskSubmitOptions {
  readonly policy: TaskExecutionPolicy;
  readonly label: string;
  readonly cancelToken: CancellationToken | undefined;
  constructor(
    policy: TaskExecutionPolicy = TaskExecutionPolicy.INLINE,
    label: string = '',
    cancelToken: CancellationToken | undefined = undefined
  ) {
    this.policy = policy;
    this.label = label;
    this.cancelToken = cancelToken;
  }
}

/**
 * Cross-module task execution contract. Platform adapts TaskPool/Worker per WSL guidelines.
 */
export interface ITaskExecutor {
  execute<T>(task: () => Promise<T>, options?: TaskSubmitOptions): Promise<T>;
  executeSync<T>(task: () => T, options?: TaskSubmitOptions): Promise<T>;
}
