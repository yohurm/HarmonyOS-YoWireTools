export class KeyValueParam {
  readonly key: string;
  readonly value: string;
  readonly enabled: boolean;

  constructor(key: string, value: string, enabled: boolean = true) {
    this.key = key;
    this.value = value;
    this.enabled = enabled;
  }
}

export class HttpRequestDraft {
  readonly id: string;
  readonly method: string;
  readonly url: string;
  readonly queryParams: KeyValueParam[];
  readonly headers: KeyValueParam[];
  readonly bodyText: string;
  readonly connectTimeoutMs: number;
  readonly readTimeoutMs: number;
  readonly maxLimitBytes: number;

  constructor(
    id: string,
    method: string,
    url: string,
    queryParams: KeyValueParam[] = [],
    headers: KeyValueParam[] = [],
    bodyText: string = '',
    connectTimeoutMs: number = 30000,
    readTimeoutMs: number = 30000,
    maxLimitBytes: number = 5 * 1024 * 1024
  ) {
    this.id = id;
    this.method = method;
    this.url = url;
    this.queryParams = queryParams;
    this.headers = headers;
    this.bodyText = bodyText;
    this.connectTimeoutMs = connectTimeoutMs;
    this.readTimeoutMs = readTimeoutMs;
    this.maxLimitBytes = maxLimitBytes;
  }
}

export class HttpResponseRecord {
  readonly requestId: string;
  readonly responseCode: number;
  readonly headers: Record<string, string>;
  readonly bodyText: string;
  readonly bodySize: number;
  readonly latencyMs: number;
  readonly nativeCode: number;
  readonly appCode: string;
  readonly dnsMs: string;
  readonly tcpMs: string;
  readonly tlsMs: string;
  readonly firstByteMs: string;
  readonly totalFinishMs: string;

  constructor(
    requestId: string,
    responseCode: number,
    headers: Record<string, string>,
    bodyText: string,
    bodySize: number,
    latencyMs: number,
    nativeCode: number = 0,
    appCode: string = '',
    dnsMs: string = '未返回',
    tcpMs: string = '未返回',
    tlsMs: string = '未返回',
    firstByteMs: string = '未返回',
    totalFinishMs: string = '未返回'
  ) {
    this.requestId = requestId;
    this.responseCode = responseCode;
    this.headers = headers;
    this.bodyText = bodyText;
    this.bodySize = bodySize;
    this.latencyMs = latencyMs;
    this.nativeCode = nativeCode;
    this.appCode = appCode;
    this.dnsMs = dnsMs;
    this.tcpMs = tcpMs;
    this.tlsMs = tlsMs;
    this.firstByteMs = firstByteMs;
    this.totalFinishMs = totalFinishMs;
  }
}
