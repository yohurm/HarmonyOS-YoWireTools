import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { LogLevel } from '../model/LogLevel';
import { LogRecord } from '../model/LogRecord';
import { YoLogConfig } from '../config/YoLogConfig';
import { LineFormatter } from '../format/LineFormatter';
import { AsyncLogQueue } from '../queue/AsyncLogQueue';
import { LogFileWriter } from '../file/LogFileWriter';
import { LogRotator } from '../file/LogRotator';
import { LogCleaner } from '../file/LogCleaner';
import { LogFileIndex } from '../file/LogFileIndex';
import { ILogAppender } from './ILogAppender';

/**
 * Buffered, serial file appender with size-based rotation.
 */
export class FileAppender implements ILogAppender {
  private enabled: boolean = false;
  private minLevel: LogLevel = LogLevel.INFO;
  private readonly buffer: string[] = [];
  private bufferCapacity: number = 64;
  private flushIntervalMs: number = 800;
  private timerId: number = -1;
  private readonly queue: AsyncLogQueue = new AsyncLogQueue();
  private writer: LogFileWriter = new LogFileWriter();
  private rotator: LogRotator | undefined = undefined;
  private cleaner: LogCleaner | undefined = undefined;
  private index: LogFileIndex | undefined = undefined;
  private logDir: string = '';
  private currentFileName: string = 'app.current.log';

  configure(config: YoLogConfig): void {
    this.enabled = config.fileEnabled && config.fileDir.length > 0;
    this.minLevel = config.fileMinLevel;
    this.bufferCapacity = config.bufferCapacity;
    this.flushIntervalMs = config.flushIntervalMs;
    this.logDir = config.fileDir;
    this.currentFileName = config.currentFileName;
    if (!this.enabled) {
      this.stopTimer();
      return;
    }
    this.ensureDir();
    this.rotator = new LogRotator(this.logDir, this.currentFileName, config.maxFileSizeBytes);
    this.cleaner = new LogCleaner(this.logDir, this.currentFileName, config.maxFileCount);
    this.index = new LogFileIndex(this.logDir);
    this.writer.open(this.rotator.currentPath());
    this.startTimer();
  }

  append(record: LogRecord): void {
    if (!this.enabled || record.level < this.minLevel) {
      return;
    }
    this.buffer.push(LineFormatter.format(record));
    const forceFlush = record.level >= LogLevel.ERROR;
    if (forceFlush || this.buffer.length >= this.bufferCapacity) {
      this.scheduleFlush();
    }
  }

  async flush(): Promise<void> {
    this.scheduleFlush();
    await this.queue.flush();
  }

  async terminate(): Promise<void> {
    this.stopTimer();
    await this.flush();
    this.writer.close();
  }

  getLogDir(): string {
    return this.logDir;
  }

  listFiles(): string[] {
    if (this.index === undefined) {
      return [];
    }
    return this.index.listFiles();
  }

  cleanNow(): void {
    if (this.cleaner !== undefined) {
      this.cleaner.clean();
    }
  }

  private scheduleFlush(): void {
    if (this.buffer.length === 0) {
      return;
    }
    const batch = this.buffer.splice(0, this.buffer.length);
    this.queue.enqueue(async () => {
      await this.writeBatch(batch);
    });
  }

  private async writeBatch(batch: string[]): Promise<void> {
    if (this.rotator === undefined) {
      return;
    }
    try {
      if (this.rotator.needsRotate()) {
        this.writer.close();
        this.rotator.rotate();
        if (this.cleaner !== undefined) {
          this.cleaner.clean();
        }
        this.writer.open(this.rotator.currentPath());
      }
      if (!this.writer.isOpen()) {
        this.writer.open(this.rotator.currentPath());
      }
      for (let i = 0; i < batch.length; i++) {
        await this.writer.writeLine(batch[i]);
      }
    } catch (err) {
      const message = err instanceof Error ? err.message : 'batch write failed';
      hilog.error(0x596F, 'YoLog.File', 'batch write failed: %{public}s', message);
    }
  }

  private ensureDir(): void {
    try {
      fileIo.mkdirSync(this.logDir, true);
    } catch (err2) {
      // Directory may already exist; verify with access.
      try {
        fileIo.accessSync(this.logDir);
      } catch (_err) {
        const message = err2 instanceof Error ? err2.message : 'mkdir failed';
        hilog.error(0x596F, 'YoLog.File', 'mkdir failed: %{public}s', message);
        this.enabled = false;
      }
    }
  }

  private startTimer(): void {
    this.stopTimer();
    this.timerId = setInterval(() => {
      this.scheduleFlush();
    }, this.flushIntervalMs);
  }

  private stopTimer(): void {
    if (this.timerId >= 0) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }
}
