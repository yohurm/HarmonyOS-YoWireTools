import { CommandTemplateRecord } from 'common_storage';
import { HttpRequestDraft, HttpResponseRecord, KeyValueParam } from '../model/HttpModels';
interface HttpTemplatePayload {
  method: string;
  url: string;
  queryParams: KeyValueParam[];
  headers: KeyValueParam[];
  bodyText: string;
  connectTimeoutMs: number;
  readTimeoutMs: number;
  maxLimitBytes: number;
}
interface HttpExchangeExportPayload {
  method: string;
  url: string;
  queryParams: KeyValueParam[];
  headers: KeyValueParam[];
  requestBodyLength: number;
  responseCode?: number;
  latencyMs?: number;
  responseBodyLength?: number;
}

export class HttpRequestTemplateCodec {
  static toTemplateRecord(id: string, name: string, draft: HttpRequestDraft): CommandTemplateRecord {
    const payload: HttpTemplatePayload = {
      method: draft.method,
      url: draft.url,
      queryParams: draft.queryParams,
      headers: draft.headers,
      bodyText: draft.bodyText,
      connectTimeoutMs: draft.connectTimeoutMs,
      readTimeoutMs: draft.readTimeoutMs,
      maxLimitBytes: draft.maxLimitBytes
    };
    const now = Date.now();
    return new CommandTemplateRecord(
      id, name, 'wifi', 'http', 'json', JSON.stringify(payload),
      'none', 'once', '{}', draft.connectTimeoutMs, '[]', now, now
    );
  }
  static fromTemplateRecord(record: CommandTemplateRecord): HttpRequestDraft | undefined {
    try {
      const payload = JSON.parse(record.payload) as HttpTemplatePayload;
      return new HttpRequestDraft(
        record.id, payload.method, payload.url,
        payload.queryParams ?? [], payload.headers ?? [], payload.bodyText ?? '',
        payload.connectTimeoutMs ?? 30000, payload.readTimeoutMs ?? 30000,
        payload.maxLimitBytes ?? 5 * 1024 * 1024
      );
    } catch (_error) {
      return undefined;
    }
  }
  static exportExchange(draft: HttpRequestDraft, response?: HttpResponseRecord): string {
    const payload: HttpExchangeExportPayload = {
      method: draft.method,
      url: draft.url,
      queryParams: draft.queryParams,
      headers: draft.headers,
      requestBodyLength: draft.bodyText.length
    };
    if (response !== undefined) {
      payload.responseCode = response.responseCode;
      payload.latencyMs = response.latencyMs;
      payload.responseBodyLength = response.bodySize;
    }
    return JSON.stringify(payload);
  }
}
