import { LogIndexRecord } from '../domain/LogIndexRecord';

/**
 * Client-side log index filters shared by list UI and export.
 */
export class LogIndexFilterUtil {
  static applyClientFilters(
    items: LogIndexRecord[],
    module: string,
    protocol: string,
    keyword: string
  ): LogIndexRecord[] {
    const trimmedKeyword = keyword.trim().toLowerCase();
    const filtered: LogIndexRecord[] = [];
    for (let i = 0; i < items.length; i++) {
      const record = items[i];
      if (module.length > 0 && record.module !== module) {
        continue;
      }
      if (protocol.length > 0 && record.protocol !== protocol) {
        continue;
      }
      if (trimmedKeyword.length > 0 && !record.summary.toLowerCase().includes(trimmedKeyword)) {
        continue;
      }
      filtered.push(record);
    }
    return filtered;
  }
}
