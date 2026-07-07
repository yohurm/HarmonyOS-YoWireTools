import { ICancellationSource } from './ICancellationSource';

/**
 * Cooperative cancellation token shared across async tasks and queues.
 */
export class CancellationToken {
  private readonly source: ICancellationSource | undefined;
  private readonly parent: CancellationToken | undefined;

  constructor(source?: ICancellationSource, parent?: CancellationToken) {
    this.source = source;
    this.parent = parent;
  }

  static none(): CancellationToken {
    return new CancellationToken();
  }

  get isCancellationRequested(): boolean {
    if (this.source !== undefined && this.source.isCancelled) {
      return true;
    }
    if (this.parent !== undefined && this.parent.isCancellationRequested) {
      return true;
    }
    return false;
  }

  throwIfCancellationRequested(): void {
    if (this.isCancellationRequested) {
      throw new Error('Operation was cancelled');
    }
  }

  onCancelled(listener: () => void): () => void {
    if (this.source === undefined) {
      return () => {
      };
    }
    return this.source.register(listener);
  }
}
