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
interface HttpTimingFields {
  dnsTiming?: number;
  tcpTiming?: number;
  tlsTiming?: number;
  firstReceiveTiming?: number;
  totalFinishTiming?: number;
}

interface HttpTimingCarrier {
  performanceTiming?: HttpTimingFields;
}

export class HttpDataSource {
  private static instance: HttpDataSource | undefined;
  private active: http.HttpRequest | undefined;
  private aborted: boolean = false;
  private receivedBytes: number = 0;

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

  abort(): void {
    this.aborted = true;
    if (this.active !== undefined) {
      this.active.destroy();
      this.active = undefined;
    }
  }

  async execute(draft: HttpRequestDraft): Promise<Result<HttpResponseRecord>> {
    const client = http.createHttp();
    this.active = client;
    this.aborted = false;
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
      client.on('dataReceiveProgress', (info: http.DataReceiveProgressInfo) => {
        this.receivedBytes = info.receiveSize;
      });
      const response = await client.request(url, options);
      if (this.aborted) {
        return Result.fail(new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, '已取消'));
      }
      const latency = Date.now() - start;
      const responseHeaders: Record<string, string> = HttpHeaderSanitizer.sanitize(
        response.header as Record<string, string>
      );
      const bodyText = `${response.result ?? ''}`;
      const timing = (response as HttpTimingCarrier).performanceTiming;
      return Result.ok(new HttpResponseRecord(
        draft.id,
        response.responseCode,
        responseHeaders,
        bodyText,
        bodyText.length,
        latency,
        0,
        '',
        this.timingCell(timing !== undefined ? timing.dnsTiming : undefined),
        this.timingCell(timing !== undefined ? timing.tcpTiming : undefined),
        this.timingCell(timing !== undefined ? timing.tlsTiming : undefined),
        this.timingCell(timing !== undefined ? timing.firstReceiveTiming : undefined),
        this.timingCell(timing !== undefined ? timing.totalFinishTiming : undefined)
      ));
    } catch (error) {
      if (this.aborted) {
        return Result.fail(new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, '已取消'));
      }
      const err = error as BusinessError;
      let appCode: string = WifiNetworkErrorCodes.CONNECT_TIMEOUT;
      if (err.code === 2300006) {
        appCode = WifiNetworkErrorCodes.DNS_FAILED;
      } else if (err.code === 2300028) {
        appCode = WifiNetworkErrorCodes.CONNECT_TIMEOUT;
      } else if (err.code !== undefined && err.code >= 2300000) {
        appCode = WifiNetworkErrorCodes.HTTP_SIZE_LIMIT;
      }
      return Result.fail(ResultError.fromBusinessError(appCode, err));
    } finally {
      if (headersHandler !== undefined) {
        NetworkKitEventBridge.unsubscribeHttpHeadersReceive(client, headersHandler);
      }
      if (this.active === client) {
        this.active = undefined;
      }
      client.destroy();
    }
  }

  private timingCell(value: number | undefined): string {
    if (value === undefined) {
      return '未返回';
    }
    return `${value}`;
  }
}
