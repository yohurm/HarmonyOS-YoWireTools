import { hilog } from '@kit.PerformanceAnalysisKit';
import { LogDomain } from './LogDomain';
import { LogParams } from './LogParams';
const MAX_TAG_BYTES: number = 31;
const MAX_LINE_CHARS: number = 160;

/**
 * HiLog facade enforcing architecture §11: ASCII tag, no payload, state transitions, split long lines.
 */
export class AppLogger {
  private readonly tag: string;
  private readonly domain: number;

  constructor(tag: string, domain: number = LogDomain.YOWIRE) {
    this.tag = AppLogger.normalizeTag(tag);
    this.domain = domain;
  }

  debug(message: string): void {
    if (hilog.isLoggable(this.domain, this.tag, hilog.LogLevel.DEBUG)) {
      AppLogger.splitAndWrite((line: string) => {
        hilog.debug(this.domain, this.tag, '%{public}s', line);
      }, message);
    }
  }

  info(message: string): void {
    if (hilog.isLoggable(this.domain, this.tag, hilog.LogLevel.INFO)) {
      AppLogger.splitAndWrite((line: string) => {
        hilog.info(this.domain, this.tag, '%{public}s', line);
      }, message);
    }
  }

  warn(message: string): void {
    if (hilog.isLoggable(this.domain, this.tag, hilog.LogLevel.WARN)) {
      AppLogger.splitAndWrite((line: string) => {
        hilog.warn(this.domain, this.tag, '%{public}s', line);
      }, message);
    }
  }

  error(message: string): void {
    if (hilog.isLoggable(this.domain, this.tag, hilog.LogLevel.ERROR)) {
      AppLogger.splitAndWrite((line: string) => {
        hilog.error(this.domain, this.tag, '%{public}s', line);
      }, message);
    }
  }

  stateTransition(stateName: string, fromState: string, toState: string, reason: string = ''): void {
    let message = `${stateName}:${fromState}->${toState}`;
    if (reason.length > 0) {
      message += `, reason=${reason}`;
    }
    this.info(message);
  }

  params(event: string, bag: LogParams): void {
    this.info(`${event}, ${AppLogger.formatParams(bag)}`);
  }

  private static formatParams(bag: LogParams): string {
    const pairs = bag.toRecord();
    const keys = Object.keys(pairs);
    let body = '';
    for (let i = 0; i < keys.length; i++) {
      const key = keys[i];
      if (i > 0) {
        body += ', ';
      }
      body += `${key}=${pairs[key]}`;
    }
    return body;
  }
  private static normalizeTag(tag: string): string {
    if (tag.length <= MAX_TAG_BYTES) {
      return tag;
    }
    return tag.substring(0, MAX_TAG_BYTES);
  }

  private static splitAndWrite(writer: (line: string) => void, message: string): void {
    if (message.length <= MAX_LINE_CHARS) {
      writer(message);
      return;
    }
    let offset = 0;
    let part = 1;
    while (offset < message.length) {
      const end = Math.min(offset + MAX_LINE_CHARS, message.length);
      writer(`[part${part}] ${message.substring(offset, end)}`);
      offset = end;
      part++;
    }
  }
}
