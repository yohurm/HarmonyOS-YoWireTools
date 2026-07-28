import { logLevelName } from '../model/LogLevel';
import { LogRecord } from '../model/LogRecord';

/**
 * Formats a LogRecord into a single file line with wall-clock timestamp.
 */
export class LineFormatter {
  static format(record: LogRecord): string {
    const ts = LineFormatter.formatTimestamp(record.timestampMs);
    return `${ts} ${logLevelName(record.level)} ${record.tag} ${record.message}`;
  }

  private static formatTimestamp(ms: number): string {
    const date = new Date(ms);
    const y = date.getFullYear();
    const mo = LineFormatter.pad2(date.getMonth() + 1);
    const d = LineFormatter.pad2(date.getDate());
    const h = LineFormatter.pad2(date.getHours());
    const mi = LineFormatter.pad2(date.getMinutes());
    const s = LineFormatter.pad2(date.getSeconds());
    const msPart = LineFormatter.pad3(date.getMilliseconds());
    return `${y}-${mo}-${d}T${h}:${mi}:${s}.${msPart}`;
  }

  private static pad2(n: number): string {
    return n < 10 ? `0${n}` : `${n}`;
  }

  private static pad3(n: number): string {
    if (n < 10) {
      return `00${n}`;
    }
    if (n < 100) {
      return `0${n}`;
    }
    return `${n}`;
  }
}
