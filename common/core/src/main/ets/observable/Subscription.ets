/**
 * Lightweight subscription handle for observable streams.
 */
export class Subscription {
  private disposed: boolean = false;
  private readonly disposeAction: () => void;

  constructor(disposeAction: () => void) {
    this.disposeAction = disposeAction;
  }

  get isDisposed(): boolean {
    return this.disposed;
  }

  dispose(): void {
    if (this.disposed) {
      return;
    }
    this.disposed = true;
    this.disposeAction();
  }
}
