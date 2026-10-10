/**
 * Domain query for session rows. Storage LogQuery is a separate model.
 */
export class SessionLogQuery {
  readonly sessionId: string;
  readonly offset: number;
  readonly limit: number;
  readonly direction: string;
  readonly recordType: string;
  readonly startMs: number;
  readonly endMs: number;
  readonly module: string;
  readonly keyword: string;

  constructor(
    sessionId: string = '',
    offset: number = 0,
    limit: number = 50,
    direction: string = '',
    recordType: string = '',
    startMs: number = 0,
    endMs: number = 0,
    module: string = '',
    keyword: string = ''
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
  }
}
