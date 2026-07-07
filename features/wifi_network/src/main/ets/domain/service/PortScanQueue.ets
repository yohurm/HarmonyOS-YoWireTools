import { CancellationToken } from 'common_core';

type AsyncTask<T> = () => Promise<T>;

/**
 * Limited concurrency task queue with cancellation per architecture wifi_network/02-§9.
 */
export class PortScanQueue {
  private readonly concurrency: number;
  private activeCount: number = 0;
  private readonly pending: AsyncTask<void>[] = [];
  private cancelled: boolean = false;
  private token: CancellationToken | undefined;

  constructor(concurrency: number) {
    this.concurrency = Math.max(1, concurrency);
  }

  bindToken(token: CancellationToken): void {
    this.token = token;
    token.onCancelled(() => {
      this.cancelled = true;
    });
  }

  enqueue(task: AsyncTask<void>): void {
    if (this.cancelled) {
      return;
    }
    this.pending.push(task);
    void this.pump();
  }

  async drain(): Promise<void> {
    while (this.activeCount > 0 || this.pending.length > 0) {
      await this.delay(50);
      if (this.cancelled) {
        break;
      }
    }
  }

  cancel(): void {
    this.cancelled = true;
    this.pending.length = 0;
  }

  isCancelled(): boolean {
    return this.cancelled || (this.token !== undefined && this.token.isCancellationRequested);
  }

  private async pump(): Promise<void> {
    while (!this.isCancelled() && this.activeCount < this.concurrency && this.pending.length > 0) {
      const task = this.pending.shift();
      if (task === undefined) {
        break;
      }
      this.activeCount++;
      void task().finally(() => {
        this.activeCount--;
        void this.pump();
      });
    }
  }

  private delay(ms: number): Promise<void> {
    return new Promise((resolve) => setTimeout(resolve, ms));
  }
}
