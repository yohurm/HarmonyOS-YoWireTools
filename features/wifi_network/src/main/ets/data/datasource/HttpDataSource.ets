import { http } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { HttpRequestDraft, HttpResponseRecord, KeyValueParam } from '../../domain/model/HttpModels';
import { HttpHeaderSanitizer } from '../../domain/service/HttpHeaderSanitizer';
import { NetworkKitEventBridge } from '../kit/NetworkKitEventBridge';

/**
 * HTTP request wrapper — createHttp/request/destroy in finally per architecture wifi_network/03.
 */
export class HttpDataSource {
  private static instance: HttpDataSource | undefined;

  static getInstance(): HttpDataSource {
    if (HttpDataSource.instance === undefined) {
      HttpDataSource.instance = new HttpDataSource();
    }
    return HttpDataSource.instance;
  }

  buildUrl(draft: HttpRequestDraft): string {
    let url: string = draft.url;
    const enabledParams: string[] = [];
    for (let i = 0; i < draft.queryParams.length; i++) {
      const param: KeyValueParam = draft.queryParams[i];
      if (param.enabled && param.key.length > 0) {
        enabledParams.push(`${encodeURIComponent(param.key)}=${encodeURIComponent(param.value)}`);
      }
    }
    if (enabledParams.length > 0) {
      const separator = url.indexOf('?') >= 0 ? '&' : '?';
      url = `${url}${separator}${enabledParams.join('&')}`;
    }
    return url;
  }

  buildHeaders(draft: HttpRequestDraft): Record<string, string> {
    const headers: Record<string, string> = {};
    for (let i = 0; i < draft.headers.length; i++) {
      const item: KeyValueParam = draft.headers[i];
      if (item.enabled && item.key.length > 0) {
        headers[item.key] = item.value;
      }
    }
    return headers;
  }

  async execute(draft: HttpRequestDraft): Promise<Result<HttpResponseRecord>> {
    const client = http.createHttp();
    const start = Date.now();
    let headersHandler: ((data: object) => void) | undefined;
    try {
      const url = this.buildUrl(draft);
      const header = this.buildHeaders(draft);
      const options: http.HttpRequestOptions = {
        method: draft.method as http.RequestMethod,
        header: header,
        connectTimeout: draft.connectTimeoutMs,
        readTimeout: draft.readTimeoutMs,
        maxLimit: draft.maxLimitBytes,
        extraData: draft.bodyText.length > 0 ? draft.bodyText : undefined
      };
      const response = await client.request(url, options);
      const latency = Date.now() - start;
      const responseHeaders: Record<string, string> = HttpHeaderSanitizer.sanitize(
        response.header as Record<string, string>
      );
      const bodyText = `${response.result ?? ''}`;
      return Result.ok(new HttpResponseRecord(
        draft.id,
        response.responseCode,
        responseHeaders,
        bodyText,
        bodyText.length,
        latency
      ));
    } catch (error) {
      const err = error as BusinessError;
      const latency = Date.now() - start;
      let appCode: string = WifiNetworkErrorCodes.CONNECT_TIMEOUT;
      if (err.code === 2300006) {
        appCode = WifiNetworkErrorCodes.DNS_FAILED;
      } else if (err.code === 2300028) {
        appCode = WifiNetworkErrorCodes.CONNECT_TIMEOUT;
      } else if (err.code !== undefined && err.code >= 2300000) {
        appCode = WifiNetworkErrorCodes.HTTP_SIZE_LIMIT;
      }
      return Result.fail(ResultError.fromError(appCode, err as Error));
    } finally {
      if (headersHandler !== undefined) {
        NetworkKitEventBridge.unsubscribeHttpHeadersReceive(client, headersHandler);
      }
      client.destroy();
    }
  }
}
