import { fileIo } from '@kit.CoreFileKit';
import { hilog } from '@kit.PerformanceAnalysisKit';

/**
 * Deletes oldest rotated log files beyond maxFileCount (excluding current).
 */
export class LogCleaner {
  private readonly logDir: string;
  private readonly currentFileName: string;
  private readonly maxFileCount: number;

  constructor(logDir: string, currentFileName: string, maxFileCount: number) {
    this.logDir = logDir;
    this.currentFileName = currentFileName;
    this.maxFileCount = maxFileCount;
  }

  clean(): void {
    try {
      const names = fileIo.listFileSync(this.logDir);
      const rotated: string[] = [];
      for (let i = 0; i < names.length; i++) {
        const name = names[i];
        if (name === this.currentFileName) {
          continue;
        }
        if (name.startsWith('app.') && name.endsWith('.log')) {
          rotated.push(name);
        }
      }
      rotated.sort();
      while (rotated.length > this.maxFileCount) {
        const victim = rotated.shift();
        if (victim === undefined) {
          break;
        }
        try {
          fileIo.unlinkSync(`${this.logDir}/${victim}`);
        } catch (_err) {
          // ignore single delete failure
        }
      }
    } catch (err) {
      const message = err instanceof Error ? err.message : 'clean failed';
      hilog.error(0x596F, 'YoLog.File', 'clean failed: %{public}s', message);
    }
  }
}
