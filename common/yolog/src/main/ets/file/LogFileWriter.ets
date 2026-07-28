import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * Low-level append writer for the current log file.
 */
export class LogFileWriter {
  private fd: number = -1;
  private path: string = '';

  open(path: string): void {
    this.close();
    this.path = path;
    try {
      const file = fileIo.openSync(path, fileIo.OpenMode.WRITE_ONLY | fileIo.OpenMode.CREATE | fileIo.OpenMode.APPEND);
      this.fd = file.fd;
    } catch (err) {
      this.fd = -1;
      const message = err instanceof Error ? err.message : 'open failed';
      hilog.error(0x596F, 'YoLog.File', 'open failed: %{public}s', message);
    }
  }

  isOpen(): boolean {
    return this.fd >= 0;
  }

  getPath(): string {
    return this.path;
  }

  async writeLine(line: string): Promise<void> {
    if (this.fd < 0) {
      return;
    }
    try {
      await fileIo.write(this.fd, `${line}\n`);
    } catch (err) {
      const message = err instanceof Error ? err.message : 'write failed';
      hilog.error(0x596F, 'YoLog.File', 'write failed: %{public}s', message);
    }
  }

  close(): void {
    if (this.fd < 0) {
      return;
    }
    try {
      fileIo.closeSync(this.fd);
    } catch (_err) {
      // ignore
    }
    this.fd = -1;
  }
}
