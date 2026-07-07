/**
 * Serializes GATT operations per architecture bluetooth/03-§4.4.
 */
export class GattOperationQueue {
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
