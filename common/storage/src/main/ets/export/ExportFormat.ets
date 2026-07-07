/**
 * Export output formats per architecture §5.6.
 */
export enum ExportFormat {
  TXT = 'TXT',
  CSV = 'CSV',
  JSON = 'JSON'
}

export class ExportOptions {
  readonly format: ExportFormat;
  readonly includePayloadBytes: boolean;
  readonly maskAddress: boolean;
  readonly maskHeaders: boolean;
  readonly sessionId: string;
  readonly startMs: number;
  readonly endMs: number;
  /** Empty string means all directions. */
  readonly direction: string;
  /** Empty string means all modules. */
  readonly module: string;
  /** Empty string means all protocols. */
  readonly protocol: string;
  /** Summary contains filter; applied client-side after fetch. */
  readonly keyword: string;

  constructor(
    format: ExportFormat,
    includePayloadBytes: boolean = true,
    maskAddress: boolean = false,
    maskHeaders: boolean = true,
    sessionId: string = '',
    startMs: number = 0,
    endMs: number = 0,
    direction: string = '',
    module: string = '',
    protocol: string = '',
    keyword: string = ''
  ) {
    this.format = format;
    this.includePayloadBytes = includePayloadBytes;
    this.maskAddress = maskAddress;
    this.maskHeaders = maskHeaders;
    this.sessionId = sessionId;
    this.startMs = startMs;
    this.endMs = endMs;
    this.direction = direction;
    this.module = module;
    this.protocol = protocol;
    this.keyword = keyword;
  }
}
