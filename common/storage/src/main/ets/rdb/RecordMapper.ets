import { StoragePayloadKind, StoragePayloadRef } from '../domain/StoragePayloadRef';
import { LogIndexRecord } from '../domain/LogIndexRecord';
import { SessionRecord } from '../domain/SessionRecord';
import { PayloadChunkRecord } from '../domain/PayloadChunkRecord';
import { CapabilityResultRecord } from '../domain/CapabilityResultRecord';
import { DeviceFavoriteRecord } from '../domain/DeviceFavoriteRecord';
import { CommandTemplateRecord } from '../domain/CommandTemplateRecord';
import { CommandHistoryRecord } from '../domain/CommandHistoryRecord';
import { JsonUtil } from 'common_core';
import { relationalStore } from '@kit.ArkData';
import { RdbResultSetReader } from './RdbResultSetReader';
interface PayloadRefJson {
  storageType: string;
  inlineBytesBase64?: string;
  filePath?: string;
  offset?: number;
  length: number;
  sha256?: string;
}

/**
 * Maps between RDB rows and storage records.
 */

export class RecordMapper {
  static sessionToBucket(record: SessionRecord): relationalStore.ValuesBucket {
    return {
      id: record.id,
      type: record.type,
      module: record.module,
      protocol: record.protocol,
      target_id: record.targetId,
      display_name: record.displayName,
      state: record.state,
      start_at_ms: record.startAtMs,
      end_at_ms: record.endAtMs,
      result: record.resultJson,
      error: record.errorJson,
      attributes: record.attributesJson
    };
  }
  static sessionFromRow(set: relationalStore.ResultSet): SessionRecord {
    return new SessionRecord(
      RdbResultSetReader.readString(set, 'id'),
      RdbResultSetReader.readString(set, 'type'),
      RdbResultSetReader.readString(set, 'module'),
      RdbResultSetReader.readString(set, 'protocol'),
      RdbResultSetReader.readString(set, 'target_id'),
      RdbResultSetReader.readString(set, 'display_name'),
      RdbResultSetReader.readString(set, 'state'),
      RdbResultSetReader.readLong(set, 'start_at_ms'),
      RdbResultSetReader.readLong(set, 'end_at_ms'),
      RdbResultSetReader.readString(set, 'result'),
      RdbResultSetReader.readString(set, 'error'),
      RdbResultSetReader.readString(set, 'attributes')
    );
  }
  static logToBucket(record: LogIndexRecord): relationalStore.ValuesBucket {
    let payloadRefText = '';
    if (record.payloadRef !== undefined) {
      payloadRefText = RecordMapper.payloadRefToJson(record.payloadRef);
    }
    return {
      id: record.id,
      session_id: record.sessionId,
      module: record.module,
      protocol: record.protocol,
      direction: record.direction,
      record_type: record.recordType,
      timestamp_ms: record.timestampMs,
      payload_ref: payloadRefText,
      payload_size: record.payloadSize,
      summary: record.summary,
      display_hint: record.displayHint,
      app_code: record.appCode,
      native_code: record.nativeCode,
      attributes: record.attributesJson
    };
  }
  static logFromRow(set: relationalStore.ResultSet): LogIndexRecord {
    const payloadRefText = RdbResultSetReader.readString(set, 'payload_ref');
    const payloadRef = RecordMapper.payloadRefFromJson(payloadRefText);
    return new LogIndexRecord(
      RdbResultSetReader.readString(set, 'id'),
      RdbResultSetReader.readString(set, 'session_id'),
      RdbResultSetReader.readString(set, 'module'),
      RdbResultSetReader.readString(set, 'protocol'),
      RdbResultSetReader.readString(set, 'direction'),
      RdbResultSetReader.readString(set, 'record_type'),
      RdbResultSetReader.readLong(set, 'timestamp_ms'),
      RdbResultSetReader.readLong(set, 'payload_size'),
      RdbResultSetReader.readString(set, 'summary'),
      RdbResultSetReader.readString(set, 'display_hint'),
      payloadRef,
      RdbResultSetReader.readString(set, 'app_code'),
      RdbResultSetReader.readString(set, 'native_code'),
      RdbResultSetReader.readString(set, 'attributes')
    );
  }
  static chunkToBucket(record: PayloadChunkRecord): relationalStore.ValuesBucket {
    return {
      id: record.id,
      session_id: record.sessionId,
      chunk_path: record.chunkPath,
      chunk_index: record.chunkIndex,
      chunk_offset: record.chunkOffset,
      chunk_length: record.chunkLength,
      sha256: record.sha256,
      created_at_ms: record.createdAtMs
    };
  }
  static chunkFromRow(set: relationalStore.ResultSet): PayloadChunkRecord {
    return new PayloadChunkRecord(
      RdbResultSetReader.readString(set, 'id'),
      RdbResultSetReader.readString(set, 'session_id'),
      RdbResultSetReader.readString(set, 'chunk_path'),
      RdbResultSetReader.readLong(set, 'chunk_index'),
      RdbResultSetReader.readLong(set, 'chunk_offset'),
      RdbResultSetReader.readLong(set, 'chunk_length'),
      RdbResultSetReader.readString(set, 'sha256'),
      RdbResultSetReader.readLong(set, 'created_at_ms')
    );
  }
  static capabilityFromRow(set: relationalStore.ResultSet): CapabilityResultRecord {
    return new CapabilityResultRecord(
      RdbResultSetReader.readString(set, 'capability_id'),
      RdbResultSetReader.readString(set, 'module'),
      RdbResultSetReader.readString(set, 'status'),
      RdbResultSetReader.readString(set, 'reason'),
      RdbResultSetReader.readString(set, 'required_permission'),
      RdbResultSetReader.readString(set, 'api_level'),
      RdbResultSetReader.readString(set, 'native_code'),
      RdbResultSetReader.readLong(set, 'verified_at_ms')
    );
  }
  static deviceFavoriteFromRow(set: relationalStore.ResultSet): DeviceFavoriteRecord {
    return new DeviceFavoriteRecord(
      RdbResultSetReader.readString(set, 'id'),
      RdbResultSetReader.readString(set, 'module'),
      RdbResultSetReader.readString(set, 'protocol'),
      RdbResultSetReader.readString(set, 'display_name'),
      RdbResultSetReader.readString(set, 'alias'),
      RdbResultSetReader.readString(set, 'address'),
      RdbResultSetReader.readString(set, 'address_type'),
      RdbResultSetReader.readString(set, 'host'),
      RdbResultSetReader.readLong(set, 'port'),
      RdbResultSetReader.readString(set, 'uuid'),
      RdbResultSetReader.readString(set, 'attributes'),
      RdbResultSetReader.readLong(set, 'updated_at_ms')
    );
  }
  static commandTemplateFromRow(set: relationalStore.ResultSet): CommandTemplateRecord {
    return new CommandTemplateRecord(
      RdbResultSetReader.readString(set, 'id'),
      RdbResultSetReader.readString(set, 'name'),
      RdbResultSetReader.readString(set, 'module'),
      RdbResultSetReader.readString(set, 'protocol'),
      RdbResultSetReader.readString(set, 'payload_encoding'),
      RdbResultSetReader.readString(set, 'payload'),
      RdbResultSetReader.readString(set, 'line_ending'),
      RdbResultSetReader.readString(set, 'write_mode'),
      RdbResultSetReader.readString(set, 'repeat_policy'),
      RdbResultSetReader.readLong(set, 'timeout_ms'),
      RdbResultSetReader.readString(set, 'tags'),
      RdbResultSetReader.readLong(set, 'created_at_ms'),
      RdbResultSetReader.readLong(set, 'updated_at_ms')
    );
  }
  static commandHistoryFromRow(set: relationalStore.ResultSet): CommandHistoryRecord {
    return new CommandHistoryRecord(
      RdbResultSetReader.readString(set, 'id'),
      RdbResultSetReader.readString(set, 'template_id'),
      RdbResultSetReader.readString(set, 'session_id'),
      RdbResultSetReader.readString(set, 'module'),
      RdbResultSetReader.readString(set, 'protocol'),
      RdbResultSetReader.readString(set, 'payload'),
      RdbResultSetReader.readString(set, 'payload_encoding'),
      RdbResultSetReader.readLong(set, 'sent_at_ms'),
      RdbResultSetReader.readString(set, 'result'),
      RdbResultSetReader.readString(set, 'attributes')
    );
  }
  static payloadRefToJson(ref: StoragePayloadRef): string {
    const json: PayloadRefJson = {
      storageType: ref.storageType,
      length: ref.length,
      inlineBytesBase64: ref.inlineBytesBase64,
      filePath: ref.filePath,
      offset: ref.offset,
      sha256: ref.sha256
    };
    const result = JsonUtil.stringify(json as Object);
    return result.success && result.value !== undefined ? result.value : '{}';
  }
  static payloadRefFromJson(text: string): StoragePayloadRef | undefined {
    if (text.length === 0) {
      return undefined;
    }
    const parsed = JsonUtil.parse<PayloadRefJson>(text);
    if (!parsed.success || parsed.value === undefined) {
      return undefined;
    }
    const data = parsed.value;
    const storageType = data.storageType === StoragePayloadKind.FILE ?
      StoragePayloadKind.FILE : StoragePayloadKind.INLINE;
    return new StoragePayloadRef(
      storageType,
      data.length,
      data.inlineBytesBase64 ?? '',
      data.filePath ?? '',
      data.offset ?? 0,
      data.sha256 ?? ''
    );
  }
}
