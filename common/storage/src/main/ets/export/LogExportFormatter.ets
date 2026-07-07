import { EncodingUtil } from 'common_core';
import { LogIndexRecord } from '../domain/LogIndexRecord';
import { ExportFormat } from './ExportFormat';
import { LogExportJsonRow } from './LogExportJsonRow';

/**
 * Formats log records for TXT/CSV/JSON export.
 */
export class LogExportFormatter {
  static formatRecords(format: ExportFormat, records: LogIndexRecord[], payloadMap: Map<string, string>): string {
    switch (format) {
      case ExportFormat.CSV:
        return LogExportFormatter.toCsv(records, payloadMap);
      case ExportFormat.JSON:
        return LogExportFormatter.toJson(records, payloadMap);
      case ExportFormat.TXT:
      default:
        return LogExportFormatter.toTxt(records, payloadMap);
    }
  }

  private static toTxt(records: LogIndexRecord[], payloadMap: Map<string, string>): string {
    let output = '';
    for (let i = 0; i < records.length; i++) {
      const record = records[i];
      output += `[${record.timestampMs}] ${record.direction}/${record.recordType} ${record.summary}\n`;
      const payload = payloadMap.get(record.id);
      if (payload !== undefined && payload.length > 0) {
        output += `${payload}\n`;
      }
      output += '\n';
    }
    return output;
  }

  private static toCsv(records: LogIndexRecord[], payloadMap: Map<string, string>): string {
    let output = 'id,sessionId,timestampMs,direction,recordType,summary,appCode,nativeCode,payloadHex\n';
    for (let i = 0; i < records.length; i++) {
      const record = records[i];
      const payload = payloadMap.get(record.id) ?? '';
      output += `${LogExportFormatter.csvField(record.id)},` +
        `${LogExportFormatter.csvField(record.sessionId)},` +
        `${record.timestampMs},` +
        `${LogExportFormatter.csvField(record.direction)},` +
        `${LogExportFormatter.csvField(record.recordType)},` +
        `${LogExportFormatter.csvField(record.summary)},` +
        `${LogExportFormatter.csvField(record.appCode)},` +
        `${LogExportFormatter.csvField(record.nativeCode)},` +
        `${LogExportFormatter.csvField(payload)}\n`;
    }
    return output;
  }

  private static csvField(value: string): string {
    const escaped = value.replace(/"/g, '""');
    return `"${escaped}"`;
  }

  private static toJson(records: LogIndexRecord[], payloadMap: Map<string, string>): string {
    const rows: LogExportJsonRow[] = [];
    for (let i = 0; i < records.length; i++) {
      const record = records[i];
      rows.push(new LogExportJsonRow(
        record.id,
        record.sessionId,
        record.module,
        record.protocol,
        record.direction,
        record.recordType,
        record.timestampMs,
        record.summary,
        record.displayHint,
        record.appCode,
        record.nativeCode,
        record.attributesJson,
        payloadMap.get(record.id) ?? ''
      ));
    }
    return JSON.stringify(rows);
  }

  static bytesToHexSafe(bytes: Uint8Array): string {
    return EncodingUtil.bytesToHex(bytes);
  }
}
