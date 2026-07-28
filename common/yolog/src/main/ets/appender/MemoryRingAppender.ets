import { LogRecord } from '../model/LogRecord';
import { LineFormatter } from '../format/LineFormatter';
import { ILogAppender } from './ILogAppender';

/**
 * In-memory ring buffer for recent log lines (crash-adjacent dump).
 */
export class MemoryRingAppender implements ILogAppender {
  private readonly capacity: number;
  private readonly lines: string[] = [];
  private nextIndex: number = 0;
  private filled: boolean = false;

  constructor(capacity: number) {
    this.capacity = capacity > 0 ? capacity : 200;
  }

  append(record: LogRecord): void {
    const line = LineFormatter.format(record);
    if (this.lines.length < this.capacity) {
      this.lines.push(line);
      this.nextIndex = this.lines.length % this.capacity;
      if (this.lines.length === this.capacity) {
        this.filled = true;
      }
      return;
    }
    this.lines[this.nextIndex] = line;
    this.nextIndex = (this.nextIndex + 1) % this.capacity;
    this.filled = true;
  }

  dump(): string[] {
    if (!this.filled) {
      return this.lines.slice();
    }
    const result: string[] = [];
    for (let i = 0; i < this.capacity; i++) {
      const idx = (this.nextIndex + i) % this.capacity;
      result.push(this.lines[idx]);
    }
    return result;
  }

  async flush(): Promise<void> {
    // memory only
  }

  async terminate(): Promise<void> {
    this.lines.length = 0;
    this.nextIndex = 0;
    this.filled = false;
  }
}
