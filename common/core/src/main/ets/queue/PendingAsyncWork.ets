import { CancellationToken } from '../cancellation/CancellationToken';

/**
 * Type-erased pending unit for serial / bounded-concurrency executors.
 * Factory closes over typed resolve/reject — queue storage needs no generic erasure.
 */
export class PendingAsyncWork {
  readonly token: CancellationToken;
  private readonly run: () => Promise<void>;
  private readonly cancelAction: (reason: Error) => void;

  private constructor(
    token: CancellationToken,
    run: () => Promise<void>,
    cancelAction: (reason: Error) => void
  ) {
    this.token = token;
    this.run = run;
    this.cancelAction = cancelAction;
  }

  static create<T>(
    task: () => Promise<T>,
    resolve: (value: T) => void,
    reject: (reason: Error) => void,
    token: CancellationToken
  ): PendingAsyncWork {
    let settled = false;
    const settleReject = (reason: Error): void => {
      if (settled) {
        return;
      }
      settled = true;
      reject(reason);
    };
    const settleResolve = (value: T): void => {
      if (settled) {
        return;
      }
      settled = true;
      resolve(value);
    };
    const run = async (): Promise<void> => {
      if (settled) {
        return;
      }
      if (token.isCancellationRequested) {
        settleReject(new Error('Operation was cancelled'));
        return;
      }
      try {
        settleResolve(await task());
      } catch (error) {
        settleReject(error as Error);
      }
    };
    return new PendingAsyncWork(token, run, settleReject);
  }

  cancel(reason: Error): void {
    this.cancelAction(reason);
  }

  execute(): Promise<void> {
    return this.run();
  }
}

export function createPendingWork<T>(
  task: () => Promise<T>,
  resolve: (value: T) => void,
  reject: (reason: Error) => void,
  token: CancellationToken
): PendingAsyncWork {
  return PendingAsyncWork.create(task, resolve, reject, token);
}
