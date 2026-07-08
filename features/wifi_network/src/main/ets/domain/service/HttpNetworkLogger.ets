import { IdGenerator, TimeUtil } from 'common_core';
import {
  DebugEvent,
  Direction,
  ErrorSeverity,
  LogCaptureService,
  LogRecordType,
  ModuleType,
  ProtocolType
} from 'feature_debug_core';
import { HttpHeaderSanitizer } from './HttpHeaderSanitizer';
import { HttpRequestDraft, HttpResponseRecord } from '../model/HttpModels';

/**
 * HTTP exchange logger per architecture 03-§7.3.
 */

export class HttpNetworkLogger {
  private static readonly logCapture: LogCaptureService = LogCaptureService.getInstance();
  static async logRequest(sessionId: string, draft: HttpRequestDraft): Promise<void> {
    const sanitized = HttpHeaderSanitizer.sanitize(
      HttpNetworkLogger.headersToRecord(draft.headers)
    );
    const summary = `${draft.method} ${draft.url} headers=${JSON.stringify(sanitized)}`;
    await HttpNetworkLogger.capture(sessionId, Direction.OUTBOUND, summary);
    if (draft.bodyText.length > 0) {
      await HttpNetworkLogger.capture(sessionId, Direction.OUTBOUND, `body(${draft.bodyText.length})`);
    }
  }
  static async logResponse(sessionId: string, response: HttpResponseRecord): Promise<void> {
    const summary = `HTTP ${response.responseCode} ${response.latencyMs}ms size=${response.bodySize}`;
    await HttpNetworkLogger.capture(sessionId, Direction.INBOUND, summary);
  }
  private static headersToRecord(headers: import('../model/HttpModels').KeyValueParam[]): Record<string, string> {
    const record: Record<string, string> = {};
    for (let i = 0; i < headers.length; i++) {
      if (headers[i].enabled) {
        record[headers[i].key] = headers[i].value;
      }
    }
    return record;
  }
  private static async capture(sessionId: string, direction: Direction, summary: string): Promise<void> {
    const event = new DebugEvent(
      IdGenerator.next('evt'),
      sessionId,
      ModuleType.WIFI,
      LogRecordType.TEXT,
      direction,
      TimeUtil.nowMs(),
      ErrorSeverity.INFO,
      summary,
      undefined,
      '',
      '',
      {}
    );
    await HttpNetworkLogger.logCapture.captureEvent(event);
  }
}
