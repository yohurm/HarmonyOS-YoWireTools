import { CancellationToken } from './CancellationToken';
import { ICancellationSource } from './ICancellationSource';

/**
 * Creates and controls CancellationToken instances.
 */
export class CancellationTokenSource implements ICancellationSource {
  private cancelled: boolean = false;
  private readonly listeners: Array<() => void> = [];

  get isCancelled(): boolean {
    return this.cancelled;
  }

  get token(): CancellationToken {
    return new CancellationToken(this);
  }

  cancel(): void {
    if (this.cancelled) {
      return;
    }
    this.cancelled = true;
    const snapshot = this.listeners.slice();
    for (let i = 0; i < snapshot.length; i++) {
      try {
        snapshot[i]();
      } catch (_error) {
        // Listener failures must not block cancellation propagation.
      }
    }
    this.listeners.length = 0;
  }

  register(listener: () => void): () => void {
    if (this.cancelled) {
      listener();
      return () => {
      };
    }
    this.listeners.push(listener);
    return () => {
      const index = this.listeners.indexOf(listener);
      if (index >= 0) {
        this.listeners.splice(index, 1);
      }
    };
  }
}
