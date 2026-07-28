import { LogLevel } from '../model/LogLevel';
import { LogRecord } from '../model/LogRecord';

/**
 * Drops records below the configured minimum level.
 */
export class LevelFilter {
  private minLevel: LogLevel;

  constructor(minLevel: LogLevel) {
    this.minLevel = minLevel;
  }

  setMinLevel(level: LogLevel): void {
    this.minLevel = level;
  }

  getMinLevel(): LogLevel {
    return this.minLevel;
  }

  accept(record: LogRecord): boolean {
    return record.level >= this.minLevel;
  }
}
