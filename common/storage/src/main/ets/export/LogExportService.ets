import { common } from '@kit.AbilityKit';
import { Result, ResultError } from 'common_core';
import { ExportFileWriter } from '../file/ExportFileWriter';
import { LogIndexFilterUtil } from '../query/LogIndexFilterUtil';
import { LogQuery } from '../query/LogQuery';
import { LogRepository } from '../repository/LogRepository';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';
import { ExportFormat, ExportOptions } from './ExportFormat';
import { LogExportFormatter } from './LogExportFormatter';

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
    return this.fileWriter.writeText(fileName, content);
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
