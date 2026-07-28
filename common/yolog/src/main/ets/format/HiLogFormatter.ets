import { hilog } from '@kit.PerformanceAnalysisKit';
import { LogLevel } from '../model/LogLevel';
import { ByteSplitter } from './ByteSplitter';

const HILOG_MAX_BYTES: number = 4000;

/**
 * Writes message segments to hilog with privacy-public format.
 */
export class HiLogFormatter {
  static write(domain: number, tag: string, level: LogLevel, message: string): void {
    const segments = ByteSplitter.splitByByteLimit(message, HILOG_MAX_BYTES);
    for (let i = 0; i < segments.length; i++) {
      const line = segments.length > 1 ? `[part${i + 1}] ${segments[i]}` : segments[i];
      HiLogFormatter.writeOne(domain, tag, level, line);
    }
  }

  private static writeOne(domain: number, tag: string, level: LogLevel, line: string): void {
    switch (level) {
      case LogLevel.DEBUG:
        if (hilog.isLoggable(domain, tag, hilog.LogLevel.DEBUG)) {
          hilog.debug(domain, tag, '%{public}s', line);
        }
        break;
      case LogLevel.INFO:
        if (hilog.isLoggable(domain, tag, hilog.LogLevel.INFO)) {
          hilog.info(domain, tag, '%{public}s', line);
        }
        break;
      case LogLevel.WARN:
        if (hilog.isLoggable(domain, tag, hilog.LogLevel.WARN)) {
          hilog.warn(domain, tag, '%{public}s', line);
        }
        break;
      case LogLevel.ERROR:
        if (hilog.isLoggable(domain, tag, hilog.LogLevel.ERROR)) {
          hilog.error(domain, tag, '%{public}s', line);
        }
        break;
      case LogLevel.FATAL:
        if (hilog.isLoggable(domain, tag, hilog.LogLevel.FATAL)) {
          hilog.fatal(domain, tag, '%{public}s', line);
        }
        break;
      default:
        if (hilog.isLoggable(domain, tag, hilog.LogLevel.INFO)) {
          hilog.info(domain, tag, '%{public}s', line);
        }
        break;
    }
  }
}
