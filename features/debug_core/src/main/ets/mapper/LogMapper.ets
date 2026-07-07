import { JsonUtil } from 'common_core';
import { LogIndexRecord } from 'common_storage';
import { DebugLogRecord } from '../domain/model/DebugLogRecord';
import {
  Direction,
  DisplayHint,
  LogRecordType,
  ModuleType,
  ProtocolType
} from '../domain/enums/DomainEnums';
import { PayloadRefMapper } from './PayloadRefMapper';

/**
 * Maps domain DebugLogRecord <-> storage LogIndexRecord.
 */
export class LogMapper {
  static toIndexRecord(record: DebugLogRecord): LogIndexRecord {
    return new LogIndexRecord(
      record.id,
      record.sessionId,
      record.module,
      record.protocol,
      record.direction,
      record.recordType,
      record.timestampMs,
      record.payloadSize,
      record.summary,
      record.displayHint,
      PayloadRefMapper.toStorage(record.payloadRef),
      record.appCode,
      record.nativeCode,
      JsonUtil.stringify(record.attributes).value ?? '{}'
    );
  }

  static fromIndexRecord(record: LogIndexRecord): DebugLogRecord {
    return new DebugLogRecord(
      record.id,
      record.sessionId,
      record.module as ModuleType,
      record.protocol as ProtocolType,
      record.direction as Direction,
      record.recordType as LogRecordType,
      record.timestampMs,
      record.payloadSize,
      record.summary,
      record.displayHint as DisplayHint,
      PayloadRefMapper.toDomain(record.payloadRef),
      0,
      record.appCode,
      record.nativeCode,
      LogMapper.parseAttributes(record.attributesJson)
    );
  }

  private static parseAttributes(json: string): Record<string, string | number | boolean> {
    const parsed = JsonUtil.parse<Record<string, string | number | boolean>>(json);
    return parsed.success && parsed.value !== undefined ? parsed.value : {};
  }
}
