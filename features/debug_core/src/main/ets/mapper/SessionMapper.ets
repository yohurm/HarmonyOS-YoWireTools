import { JsonUtil } from 'common_core';
import { SessionRecord } from 'common_storage';
import { DebugSession } from '../domain/model/DebugSession';
import { SessionResult } from '../domain/model/SessionResult';
import { DebugError } from '../domain/model/DebugError';
import {
  AppMode,
  ModuleType,
  ProtocolType,
  SessionState,
  SessionType
} from '../domain/enums/DomainEnums';

/**
 * Maps domain DebugSession <-> storage SessionRecord.
 */
export class SessionMapper {
  static toRecord(session: DebugSession): SessionRecord {
    return new SessionRecord(
      session.id,
      session.type,
      session.module,
      session.protocol,
      session.target?.id ?? '',
      session.displayName,
      session.state,
      session.startAtMs,
      session.endAtMs,
      session.result ? JSON.stringify({ success: session.result.success, summary: session.result.summary }) : '',
      session.error ? JSON.stringify({
        appCode: session.error.appCode,
        message: session.error.message,
        userAction: session.error.userAction,
        nativeCode: session.error.nativeCode,
        severity: session.error.severity,
        retryable: session.error.retryable
      }) : '',
      JsonUtil.stringify(session.attributes).value ?? '{}'
    );
  }

  static fromRecord(record: SessionRecord): DebugSession {
    return new DebugSession(
      record.id,
      record.type as SessionType,
      record.module as ModuleType,
      record.protocol as ProtocolType,
      record.displayName,
      AppMode.EXPERT,
      record.state as SessionState,
      record.startAtMs,
      record.endAtMs,
      undefined,
      SessionMapper.parseResult(record.resultJson),
      SessionMapper.parseError(record.errorJson),
      [],
      SessionMapper.parseAttributes(record.attributesJson)
    );
  }

  private static parseResult(json: string): SessionResult | undefined {
    if (json.length === 0) {
      return undefined;
    }
    const parsed = JsonUtil.parse<SessionResult>(json);
    return parsed.success ? parsed.value : undefined;
  }

  private static parseError(json: string): DebugError | undefined {
    if (json.length === 0) {
      return undefined;
    }
    const parsed = JsonUtil.parse<DebugError>(json);
    return parsed.success ? parsed.value : undefined;
  }

  private static parseAttributes(json: string): Record<string, string | number | boolean> {
    const parsed = JsonUtil.parse<Record<string, string | number | boolean>>(json);
    return parsed.success && parsed.value !== undefined ? parsed.value : {};
  }
}
