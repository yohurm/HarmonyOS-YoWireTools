import { LogLevel } from '../model/LogLevel';
import { LogRecord } from '../model/LogRecord';
import { HiLogFormatter } from '../format/HiLogFormatter';
import { ILogAppender } from './ILogAppender';

/**
 * Routes records to HarmonyOS hilog.
 */
export class HiLogAppender implements ILogAppender {
  private enabled: boolean = true;
  private minLevel: LogLevel = LogLevel.INFO;

  configure(enabled: boolean, minLevel: LogLevel): void {
    this.enabled = enabled;
    this.minLevel = minLevel;
  }

  append(record: LogRecord): void {
    if (!this.enabled || record.level < this.minLevel) {
      return;
    }
    HiLogFormatter.write(record.domain, record.tag, record.level, record.message);
  }

  async flush(): Promise<void> {
    // hilog has no app-level flush
  }

  async terminate(): Promise<void> {
    // no-op
  }
}
