import { IdGenerator, TimeUtil } from 'common_core';
import {
  DebugEvent,
  Direction,
  ErrorSeverity,
  LogCaptureService,
  LogRecordType,
  ModuleType
} from 'debug_core';
import { HttpHeaderSanitizer } from './HttpHeaderSanitizer';
import { HttpRequestDraft, HttpResponseRecord, KeyValueParam } from '../model/HttpModels';

/**
 * HTTP exchange logger per architecture 03-§7.3.
 * Headers/status go to summary; body bytes are preserved (truncated if huge).
 */
export class HttpNetworkLogger {
  private static readonly logCapture: LogCaptureService = LogCaptureService.getInstance();
  private static readonly MAX_BODY_BYTES: number = 256 * 1024;

  static async logRequest(sessionId: string, draft: HttpRequestDraft): Promise<void> {
    const sanitized = HttpHeaderSanitizer.sanitize(
      HttpNetworkLogger.headersToRecord(draft.headers)
    );
    const bodyBytes = HttpNetworkLogger.textToBytes(draft.bodyText);
    const truncated = bodyBytes.length > HttpNetworkLogger.MAX_BODY_BYTES;
    const stored = truncated ? bodyBytes.subarray(0, HttpNetworkLogger.MAX_BODY_BYTES) : bodyBytes;
    const summary = truncated ?
      `${draft.method} ${draft.url} headers=${JSON.stringify(sanitized)} body=${draft.bodyText.length} truncated=${HttpNetworkLogger.MAX_BODY_BYTES}` :
      `${draft.method} ${draft.url} headers=${JSON.stringify(sanitized)} body=${draft.bodyText.length}`;
    await HttpNetworkLogger.capture(sessionId, Direction.OUTBOUND, summary, stored);
  }

  static async logResponse(sessionId: string, response: HttpResponseRecord): Promise<void> {
    const bodyBytes = HttpNetworkLogger.textToBytes(response.bodyText);
    const truncated = bodyBytes.length > HttpNetworkLogger.MAX_BODY_BYTES;
    const stored = truncated ? bodyBytes.subarray(0, HttpNetworkLogger.MAX_BODY_BYTES) : bodyBytes;
    const summary = truncated ?
      `HTTP ${response.responseCode} ${response.latencyMs}ms size=${response.bodySize} truncated=${HttpNetworkLogger.MAX_BODY_BYTES}` :
      `HTTP ${response.responseCode} ${response.latencyMs}ms size=${response.bodySize}`;
    await HttpNetworkLogger.capture(
      sessionId,
      Direction.INBOUND,
      summary,
      stored,
      response.appCode,
      response.nativeCode > 0 ? `${response.nativeCode}` : ''
    );
  }

  private static headersToRecord(headers: KeyValueParam[]): Record<string, string> {
    const record: Record<string, string> = {};
    for (let i = 0; i < headers.length; i++) {
      if (headers[i].enabled) {
        record[headers[i].key] = headers[i].value;
      }
    }
    return record;
  }

  private static async capture(
    sessionId: string,
    direction: Direction,
    summary: string,
    payload: Uint8Array,
    appCode: string = '',
    nativeCode: string = ''
  ): Promise<void> {
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
      nativeCode,
      appCode,
      {}
    );
    await HttpNetworkLogger.logCapture.captureEvent(event, payload);
  }

  private static textToBytes(text: string): Uint8Array {
    if (text.length === 0) {
      return new Uint8Array(0);
    }
    const bytes = new Uint8Array(text.length);
    for (let i = 0; i < text.length; i++) {
      bytes[i] = text.charCodeAt(i) & 0xff;
    }
    return bytes;
  }
}
