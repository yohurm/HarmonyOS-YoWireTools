import { LogLevel } from '../model/LogLevel';
import { LogDomain } from '../model/LogDomain';

/**
 * Runtime configuration for YoLog bootstrap.
 */
export class YoLogConfig {
  domain: number = LogDomain.YOWIRE;
  globalMinLevel: LogLevel = LogLevel.INFO;
  hilogEnabled: boolean = true;
  hilogMinLevel: LogLevel = LogLevel.INFO;
  fileEnabled: boolean = true;
  fileMinLevel: LogLevel = LogLevel.INFO;
  fileDir: string = '';
  maxFileSizeBytes: number = 5 * 1024 * 1024;
  maxFileCount: number = 10;
  bufferCapacity: number = 64;
  flushIntervalMs: number = 800;
  ringCapacity: number = 200;
  rateLimitWindowMs: number = 1000;
  rateLimitMaxCount: number = 40;
  currentFileName: string = 'app.current.log';

  static forDebug(filesDir: string): YoLogConfig {
    const config = new YoLogConfig();
    config.fileDir = `${filesDir}/yolog`;
    config.globalMinLevel = LogLevel.DEBUG;
    config.hilogMinLevel = LogLevel.DEBUG;
    config.fileMinLevel = LogLevel.DEBUG;
    return config;
  }

  static forRelease(filesDir: string): YoLogConfig {
    const config = new YoLogConfig();
    config.fileDir = `${filesDir}/yolog`;
    config.globalMinLevel = LogLevel.INFO;
    config.hilogMinLevel = LogLevel.INFO;
    config.fileMinLevel = LogLevel.INFO;
    return config;
  }
}
