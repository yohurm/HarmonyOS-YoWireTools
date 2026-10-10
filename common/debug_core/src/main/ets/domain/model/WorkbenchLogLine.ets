export class WorkbenchLogLine {
  readonly id: string;
  readonly timestampMs: number;
  readonly direction: string;
  readonly summary: string;
  readonly payloadSize: number;
  readonly appCode: string;
  readonly nativeCode: string;
  readonly module: string;
  readonly protocol: string;
  readonly sessionId: string;

  constructor(
    id: string,
    timestampMs: number,
    direction: string,
    summary: string,
    payloadSize: number,
    appCode: string = '',
    nativeCode: string = '',
    module: string = '',
    protocol: string = '',
    sessionId: string = ''
  ) {
    this.id = id;
    this.timestampMs = timestampMs;
    this.direction = direction;
    this.summary = summary;
    this.payloadSize = payloadSize;
    this.appCode = appCode;
    this.nativeCode = nativeCode;
    this.module = module;
    this.protocol = protocol;
    this.sessionId = sessionId;
  }
}
