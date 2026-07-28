/**
 * Serial async queue without depending on common_core.
 */
export class AsyncLogQueue {
  private readonly pending: Array<() => Promise<void>> = [];
  private running: boolean = false;

  enqueue(task: () => Promise<void>): void {
    this.pending.push(task);
    this.drain();
  }

  async flush(): Promise<void> {
    while (this.running || this.pending.length > 0) {
      await new Promise<void>((resolve) => {
        setTimeout(() => {
          resolve();
        }, 16);
      });
    }
  }

  private drain(): void {
    if (this.running) {
      return;
    }
    const next = this.pending.shift();
    if (next === undefined) {
      return;
    }
    this.running = true;
    next()
      .catch(() => {
        // Swallow IO errors; never break the queue.
      })
      .finally(() => {
        this.running = false;
        this.drain();
      });
  }
}
