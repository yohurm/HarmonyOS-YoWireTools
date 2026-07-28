import { LogLevel } from '../model/LogLevel';
import { LogDomain } from '../model/LogDomain';
import { LogParams } from '../model/LogParams';
import { LogRecord } from '../model/LogRecord';
import { YoLogConfig } from '../config/YoLogConfig';
import { LevelFilter } from '../filter/LevelFilter';
import { RateLimitFilter } from '../filter/RateLimitFilter';
import { HiLogAppender } from '../appender/HiLogAppender';
import { FileAppender } from '../appender/FileAppender';
import { MemoryRingAppender } from '../appender/MemoryRingAppender';
import BuildProfile from '../../../../BuildProfile';

const MAX_TAG_BYTES: number = 31;

export type LazyMessage = string | (() => string);

/**
 * Tagged logger instance used by call sites.
 */
export class YoLogger {
  private readonly tag: string;
  private readonly domain: number;

  constructor(tag: string, domain: number = LogDomain.YOWIRE) {
    this.tag = YoLogger.normalizeTag(tag);
    this.domain = domain;
  }

  d(message: LazyMessage): void {
    this.emit(LogLevel.DEBUG, message);
  }

  i(message: LazyMessage): void {
    this.emit(LogLevel.INFO, message);
  }

  w(message: LazyMessage): void {
    this.emit(LogLevel.WARN, message);
  }

  e(message: LazyMessage): void {
    this.emit(LogLevel.ERROR, message);
  }

  f(message: LazyMessage): void {
    this.emit(LogLevel.FATAL, message);
  }

  debug(message: LazyMessage): void {
    this.d(message);
  }

  info(message: LazyMessage): void {
    this.i(message);
  }

  warn(message: LazyMessage): void {
    this.w(message);
  }

  error(message: LazyMessage): void {
    this.e(message);
  }

  fatal(message: LazyMessage): void {
    this.f(message);
  }

  state(stateName: string, fromState: string, toState: string, reason: string = ''): void {
    let message = `${stateName}:${fromState}->${toState}`;
    if (reason.length > 0) {
      message += `, reason=${reason}`;
    }
    this.i(message);
  }

  stateTransition(stateName: string, fromState: string, toState: string, reason: string = ''): void {
    this.state(stateName, fromState, toState, reason);
  }

  params(event: string, bag: LogParams): void {
    this.i(`${event}, ${bag.format()}`);
  }

  private emit(level: LogLevel, message: LazyMessage): void {
    if (!YoLog.isEnabled(level)) {
      return;
    }
    const text = typeof message === 'string' ? message : message();
    const record = new LogRecord(level, this.tag, this.domain, text, Date.now());
    YoLog.dispatch(record);
  }

  private static normalizeTag(tag: string): string {
    if (tag.length <= MAX_TAG_BYTES) {
      return tag;
    }
    return tag.substring(0, MAX_TAG_BYTES);
  }
}

/**
 * Global observability logging facade.
 */
export class YoLog {
  private static bootstrapped: boolean = false;
  private static config: YoLogConfig = new YoLogConfig();
  private static levelFilter: LevelFilter = new LevelFilter(LogLevel.INFO);
  private static rateLimit: RateLimitFilter = new RateLimitFilter(1000, 40);
  private static hilogAppender: HiLogAppender = new HiLogAppender();
  private static fileAppender: FileAppender = new FileAppender();
  private static ringAppender: MemoryRingAppender = new MemoryRingAppender(200);
  private static readonly loggerCache: Map<string, YoLogger> = new Map();

  static bootstrap(config: YoLogConfig): void {
    YoLog.config = config;
    YoLog.levelFilter = new LevelFilter(config.globalMinLevel);
    YoLog.rateLimit = new RateLimitFilter(config.rateLimitWindowMs, config.rateLimitMaxCount);
    YoLog.hilogAppender.configure(config.hilogEnabled, config.hilogMinLevel);
    YoLog.ringAppender = new MemoryRingAppender(config.ringCapacity);
    YoLog.fileAppender.configure(config);
    YoLog.bootstrapped = true;
  }

  /**
   * Convenience bootstrap from application filesDir and BuildProfile.DEBUG.
   */
  static bootstrapFromFilesDir(filesDir: string): void {
    const config = BuildProfile.DEBUG ? YoLogConfig.forDebug(filesDir) : YoLogConfig.forRelease(filesDir);
    YoLog.bootstrap(config);
  }

  static ensureBootstrapped(filesDir: string): void {
    if (!YoLog.bootstrapped) {
      YoLog.bootstrapFromFilesDir(filesDir);
    }
  }

  static isBootstrapped(): boolean {
    return YoLog.bootstrapped;
  }

  static setMinLevel(level: LogLevel): void {
    YoLog.levelFilter.setMinLevel(level);
    YoLog.config.globalMinLevel = level;
  }

  static isEnabled(level: LogLevel): boolean {
    return level >= YoLog.levelFilter.getMinLevel();
  }

  static tag(tag: string): YoLogger {
    return YoLog.of(tag, LogDomain.YOWIRE);
  }

  static of(tag: string, domain: number = LogDomain.YOWIRE): YoLogger {
    const key = `${domain}:${tag}`;
    let logger = YoLog.loggerCache.get(key);
    if (logger === undefined) {
      logger = new YoLogger(tag, domain);
      YoLog.loggerCache.set(key, logger);
    }
    return logger;
  }

  static dispatch(record: LogRecord): void {
    if (!YoLog.levelFilter.accept(record)) {
      return;
    }
    const rateKey = `${record.level}|${record.tag}|${record.message}`;
    if (!YoLog.rateLimit.accept(rateKey, record.timestampMs)) {
      return;
    }
    YoLog.hilogAppender.append(record);
    YoLog.ringAppender.append(record);
    YoLog.fileAppender.append(record);
  }

  static async flush(): Promise<void> {
    await YoLog.fileAppender.flush();
    await YoLog.hilogAppender.flush();
    await YoLog.ringAppender.flush();
  }

  static async terminate(): Promise<void> {
    await YoLog.fileAppender.terminate();
    await YoLog.hilogAppender.terminate();
    await YoLog.ringAppender.terminate();
    YoLog.bootstrapped = false;
  }

  static getLogDir(): string {
    return YoLog.fileAppender.getLogDir();
  }

  static listFiles(): string[] {
    return YoLog.fileAppender.listFiles();
  }

  static clean(): void {
    YoLog.fileAppender.cleanNow();
  }

  static dumpRing(): string[] {
    return YoLog.ringAppender.dump();
  }

  static resetForTest(): void {
    YoLog.bootstrapped = false;
    YoLog.loggerCache.clear();
    YoLog.config = new YoLogConfig();
    YoLog.levelFilter = new LevelFilter(LogLevel.INFO);
  }
}
