import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * Rotates the current log file when size exceeds the configured limit.
 */
export class LogRotator {
  private readonly logDir: string;
  private readonly currentFileName: string;
  private readonly maxFileSizeBytes: number;

  constructor(logDir: string, currentFileName: string, maxFileSizeBytes: number) {
    this.logDir = logDir;
    this.currentFileName = currentFileName;
    this.maxFileSizeBytes = maxFileSizeBytes;
  }

  currentPath(): string {
    return `${this.logDir}/${this.currentFileName}`;
  }

  needsRotate(): boolean {
    const path = this.currentPath();
    try {
      const st = fileIo.statSync(path);
      return st.size >= this.maxFileSizeBytes;
    } catch (_err) {
      return false;
    }
  }

  rotate(): string {
    const current = this.currentPath();
    const stamp = LogRotator.dateStamp(new Date());
    let index = 1;
    let target = `${this.logDir}/app.${stamp}.${index}.log`;
    while (LogRotator.exists(target)) {
      index++;
      target = `${this.logDir}/app.${stamp}.${index}.log`;
    }
    try {
      if (LogRotator.exists(current)) {
        fileIo.renameSync(current, target);
      }
    } catch (err) {
      const message = err instanceof Error ? err.message : 'rotate failed';
      hilog.error(0x596F, 'YoLog.File', 'rotate failed: %{public}s', message);
    }
    return target;
  }

  private static exists(path: string): boolean {
    try {
      fileIo.accessSync(path);
      return true;
    } catch (_err) {
      return false;
    }
  }

  private static dateStamp(date: Date): string {
    const y = date.getFullYear();
    const mo = date.getMonth() + 1;
    const d = date.getDate();
    const moStr = mo < 10 ? `0${mo}` : `${mo}`;
    const dStr = d < 10 ? `0${d}` : `${d}`;
    return `${y}-${moStr}-${dStr}`;
  }
}
