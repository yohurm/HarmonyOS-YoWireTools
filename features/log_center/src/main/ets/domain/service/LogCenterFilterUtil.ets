import { ExportFormat, ExportOptions, LogIndexFilterUtil, LogIndexRecord } from 'common_storage';
import { LogDirectionFilter } from '../model/LogDirectionFilter';

/**
 * Pure filter helpers for LogCenterViewModel (unit-testable).
 */
export class LogCenterFilterUtil {
  static sessionLabel(sessionId: string): string {
    if (sessionId.length === 0) {
      return '全部会话';
    }
    return sessionId.length > 16 ? `${sessionId.substring(0, 16)}...` : sessionId;
  }

  static queryDirection(filter: LogDirectionFilter): string {
    if (filter === LogDirectionFilter.INBOUND) {
      return 'INBOUND';
    }
    if (filter === LogDirectionFilter.OUTBOUND) {
      return 'OUTBOUND';
    }
    return '';
  }

  static applyClientFilters(
    items: LogIndexRecord[],
    module: string,
    protocol: string,
    keyword: string
  ): LogIndexRecord[] {
    return LogIndexFilterUtil.applyClientFilters(items, module, protocol, keyword);
  }

  static buildExportOptions(
    format: ExportFormat,
    sessionId: string,
    directionFilter: LogDirectionFilter,
    module: string,
    protocol: string,
    keyword: string,
    maskAddress: boolean = false,
    maskHeaders: boolean = true
  ): ExportOptions {
    return new ExportOptions(
      format,
      false,
      maskAddress,
      maskHeaders,
      sessionId,
      0,
      0,
      LogCenterFilterUtil.queryDirection(directionFilter),
      module,
      protocol,
      keyword
    );
  }

  static buildStatusMessage(
    visibleCount: number,
    totalCount: number,
    keyword: string,
    module: string,
    protocol: string
  ): string {
    const hasClientFilter = keyword.trim().length > 0 || module.length > 0 || protocol.length > 0;
    if (hasClientFilter) {
      return `显示 ${visibleCount} 条 · 共 ${totalCount} 条日志`;
    }
    return `共 ${totalCount} 条日志`;
  }

  static collectSessionIds(logs: LogIndexRecord[], existing: string[]): string[] {
    return LogCenterFilterUtil.collectFieldValues(logs, 'sessionId', existing);
  }

  static collectFieldValues(
    logs: LogIndexRecord[],
    field: 'sessionId' | 'module' | 'protocol',
    existing: string[]
  ): string[] {
    const values: string[] = [];
    const seen: Set<string> = new Set();
    for (let i = 0; i < existing.length; i++) {
      if (existing[i].length > 0 && !seen.has(existing[i])) {
        seen.add(existing[i]);
        values.push(existing[i]);
      }
    }
    for (let i = 0; i < logs.length; i++) {
      const value = field === 'sessionId'
        ? logs[i].sessionId
        : (field === 'module' ? logs[i].module : logs[i].protocol);
      if (value.length > 0 && !seen.has(value)) {
        seen.add(value);
        values.push(value);
      }
    }
    return values;
  }
}
