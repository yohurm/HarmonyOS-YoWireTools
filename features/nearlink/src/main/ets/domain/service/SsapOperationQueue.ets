/**
 * Serializes SSAP operations per architecture nearlink/02-§7.
 */
export class SsapOperationQueue {
  private pending: Promise<void> = Promise.resolve();

  enqueue<T>(task: () => Promise<T>): Promise<T> {
    const run = this.pending.then(() => task());
    this.pending = run.then(() => undefined, () => undefined);
    return run;
  }

  reset(): void {
    this.pending = Promise.resolve();
  }
}
