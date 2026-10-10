import { PageQuery, PageResult, Result, ResultError } from 'common_core';
import { AbilityContextRegistry } from 'common_platform';
import {
  ExportFormat,
  ExportOptions,
  LogCleanupPolicy,
  LogExportService,
  LogQuery,
  LogRepository,
  StoreErrorCodes
} from 'common_storage';
import { SessionLogQuery } from '../../domain/model/SessionLogQuery';
import { SessionLogRepositoryContract } from '../../domain/repository/SessionLogRepositoryContract';
import { WorkbenchLogLine } from '../../domain/model/WorkbenchLogLine';

/**
 * The only debug_core caller of the session log table.
 */
export class SessionLogRepository implements SessionLogRepositoryContract {
  private readonly logs: LogRepository;

  constructor(logs: LogRepository = LogRepository.getInstance()) {
    this.logs = logs;
  }

  async list(query: SessionLogQuery): Promise<Result<PageResult<WorkbenchLogLine>>> {
    const listed = await this.logs.list(SessionLogRepository.toStorageQuery(query));
    if (!listed.success || listed.value === undefined) {
      return Result.fail(listed.error ?? new ResultError(StoreErrorCodes.RDB_READ_FAILED, 'List failed'));
    }
    const lines: WorkbenchLogLine[] = [];
    const items = listed.value.items;
    for (let i = 0; i < items.length; i++) {
      const record = items[i];
      lines.push(new WorkbenchLogLine(
        record.id,
        record.timestampMs,
        record.direction,
        record.summary,
        record.payloadSize,
        record.appCode,
        record.nativeCode,
        record.module,
        record.protocol,
        record.sessionId
      ));
    }
    return Result.ok(new PageResult(lines, listed.value.total, new PageQuery(query.offset, query.limit)));
  }

  async deleteBySession(sessionId: string): Promise<Result<void>> {
    return this.logs.deleteBySession(sessionId);
  }

  async cleanup(retentionDays: number): Promise<Result<number>> {
    const cleaned = await this.logs.cleanup(new LogCleanupPolicy(retentionDays, 0));
    if (!cleaned.success || cleaned.value === undefined) {
      return Result.fail(cleaned.error ?? new ResultError(StoreErrorCodes.RDB_WRITE_FAILED, 'Cleanup failed'));
    }
    return Result.ok(cleaned.value.deletedLogs);
  }

  async exportSession(sessionId: string, module: string, keyword: string): Promise<Result<string>> {
    const context = AbilityContextRegistry.getInstance().get();
    if (context === undefined) {
      return Result.fail(new ResultError(StoreErrorCodes.EXPORT_FAILED, 'Ability context not bound'));
    }
    const service = new LogExportService(context, this.logs);
    return service.exportLogs(new ExportOptions(
      ExportFormat.TXT,
      false,
      false,
      true,
      sessionId,
      0,
      0,
      '',
      module,
      '',
      keyword
    ));
  }

  private static toStorageQuery(query: SessionLogQuery): LogQuery {
    return new LogQuery(
      query.sessionId,
      query.offset,
      query.limit,
      query.direction,
      query.recordType,
      query.startMs,
      query.endMs,
      query.module,
      query.keyword,
      ''
    );
  }
}
