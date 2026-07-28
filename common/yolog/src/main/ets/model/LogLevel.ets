/**
 * Log severity levels aligned with hilog.LogLevel numeric values.
 */
export enum LogLevel {
  DEBUG = 3,
  INFO = 4,
  WARN = 5,
  ERROR = 6,
  FATAL = 7
}

export function logLevelName(level: LogLevel): string {
  switch (level) {
    case LogLevel.DEBUG:
      return 'D';
    case LogLevel.INFO:
      return 'I';
    case LogLevel.WARN:
      return 'W';
    case LogLevel.ERROR:
      return 'E';
    case LogLevel.FATAL:
      return 'F';
    default:
      return 'I';
  }
}
