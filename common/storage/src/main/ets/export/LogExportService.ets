import { common } from '@kit.AbilityKit';
import { Result, ResultError } from 'common_core';
import { YoLog, YoLogTag, LogParams } from 'yolog';
import { ExportFileWriter } from '../file/ExportFileWriter';
import { LogIndexFilterUtil } from '../query/LogIndexFilterUtil';
import { LogQuery } from '../query/LogQuery';
import { LogRepository } from '../repository/LogRepository';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';
import { ExportFormat, ExportOptions } from './ExportFormat';
import { LogExportFormatter } from './LogExportFormatter';

const logger = YoLog.tag(YoLogTag.SESSION);

/**
 * Serial log export service per architecture §5.6 and ExportQueue semantics.
 */
export class LogExportService {
  private readonly context: common.Context;
  private readonly logRepository: LogRepository;
  private readonly fileWriter: ExportFileWriter;

  constructor(context: common.Context, logRepository: LogRepository = LogRepository.getInstance()) {
    this.context = context;
    this.logRepository = logRepository;
    this.fileWriter = new ExportFileWriter(context);
  }

  async exportLogs(options: ExportOptions): Promise<Result<string>> {
    logger.params('export_start', LogParams.create()
      .put('sessionId', options.sessionId)
      .put('format', `${options.format}`)
      .put('includePayload', options.includePayloadBytes));
    const query = new LogQuery(
      options.sessionId,
      0,
      10000,
      options.direction,
      '',
      options.startMs,
      options.endMs
    );
    const listed = await this.logRepository.list(query);
    if (!listed.success || listed.value === undefined) {
      logger.error(`export_failed code=${listed.error?.code ?? StoreErrorCodes.EXPORT_FAILED}`);
      return Result.fail(listed.error ?? new ResultError(StoreErrorCodes.EXPORT_FAILED, 'List logs failed'));
    }
    const filteredItems = LogIndexFilterUtil.applyClientFilters(
      listed.value.items,
      options.module,
      options.protocol,
      options.keyword
    );
    const payloadMap = new Map<string, string>();
    if (options.includePayloadBytes) {
      for (let i = 0; i < filteredItems.length; i++) {
        const record = filteredItems[i];
        if (record.payloadRef !== undefined) {
          const payload = await this.logRepository.getPayload(record.payloadRef);
          if (payload.success && payload.value !== undefined) {
            payloadMap.set(record.id, LogExportFormatter.bytesToHexSafe(payload.value));
          }
        }
      }
    }
    const content = LogExportFormatter.formatRecords(options.format, filteredItems, payloadMap);
    const fileName = LogExportService.fileNameForFormat(options.format);
    const written = await this.fileWriter.writeText(fileName, content);
    if (!written.success) {
      logger.error(`export_failed code=${written.error?.code ?? StoreErrorCodes.EXPORT_FAILED}`);
      return written;
    }
    logger.params('export_success', LogParams.create()
      .put('sessionId', options.sessionId)
      .put('count', filteredItems.length)
      .put('path', written.value ?? ''));
    return written;
  }

  private static fileNameForFormat(format: ExportFormat): string {
    switch (format) {
      case ExportFormat.CSV:
        return 'logs.csv';
      case ExportFormat.JSON:
        return 'logs.json';
      case ExportFormat.TXT:
      default:
        return 'logs.txt';
    }
  }
}
