import { LogRecord } from '../model/LogRecord';

/**
 * Appender contract for YoLog pipeline.
 */
export interface ILogAppender {
  append(record: LogRecord): void;

  flush(): Promise<void>;

  terminate(): Promise<void>;
}
