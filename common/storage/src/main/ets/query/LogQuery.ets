/**
 * Log list query parameters.
 */
export class LogQuery {
  readonly sessionId: string;
  readonly offset: number;
  readonly limit: number;
  readonly direction: string;
  readonly recordType: string;
  readonly startMs: number;
  readonly endMs: number;
  readonly module: string;
  readonly keyword: string;
  readonly protocol: string;

  constructor(
    sessionId: string = '',
    offset: number = 0,
    limit: number = 50,
    direction: string = '',
    recordType: string = '',
    startMs: number = 0,
    endMs: number = 0,
    module: string = '',
    keyword: string = '',
    protocol: string = ''
  ) {
    this.sessionId = sessionId;
    this.offset = offset;
    this.limit = limit;
    this.direction = direction;
    this.recordType = recordType;
    this.startMs = startMs;
    this.endMs = endMs;
    this.module = module;
    this.keyword = keyword;
    this.protocol = protocol;
  }
}
