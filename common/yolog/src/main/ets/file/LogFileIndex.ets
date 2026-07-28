import { fileIo } from '@kit.CoreFileKit';

/**
 * Lists log files under the yolog directory.
 */
export class LogFileIndex {
  private readonly logDir: string;

  constructor(logDir: string) {
    this.logDir = logDir;
  }

  getLogDir(): string {
    return this.logDir;
  }

  listFiles(): string[] {
    try {
      const names = fileIo.listFileSync(this.logDir);
      const paths: string[] = [];
      for (let i = 0; i < names.length; i++) {
        const name = names[i];
        if (name.endsWith('.log')) {
          paths.push(`${this.logDir}/${name}`);
        }
      }
      paths.sort();
      return paths;
    } catch (_err) {
      return [];
    }
  }
}
