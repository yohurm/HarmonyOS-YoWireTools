import { LogLevel } from './LogLevel';

/**
 * Immutable structured log event passed through the pipeline.
 */
export class LogRecord {
  readonly level: LogLevel;
  readonly tag: string;
  readonly domain: number;
  readonly message: string;
  readonly timestampMs: number;

  constructor(level: LogLevel, tag: string, domain: number, message: string, timestampMs: number) {
    this.level = level;
    this.tag = tag;
    this.domain = domain;
    this.message = message;
    this.timestampMs = timestampMs;
  }
}
