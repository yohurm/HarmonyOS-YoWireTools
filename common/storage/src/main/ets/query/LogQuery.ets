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

  constructor(
    sessionId: string = '',
    offset: number = 0,
    limit: number = 50,
    direction: string = '',
    recordType: string = '',
    startMs: number = 0,
    endMs: number = 0
  ) {
    this.sessionId = sessionId;
    this.offset = offset;
    this.limit = limit;
    this.direction = direction;
    this.recordType = recordType;
    this.startMs = startMs;
    this.endMs = endMs;
  }
}
