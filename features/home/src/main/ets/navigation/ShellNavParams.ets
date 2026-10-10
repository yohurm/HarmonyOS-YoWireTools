export class LogDetailNavParams {
  readonly recordId: string;
  readonly module: string;
  readonly protocol: string;
  readonly summary: string;
  readonly logDirection: string;
  readonly timestampMs: number;

  constructor(
    recordId: string,
    module: string,
    protocol: string,
    summary: string,
    logDirection: string,
    timestampMs: number
  ) {
    this.recordId = recordId;
    this.module = module;
    this.protocol = protocol;
    this.summary = summary;
    this.logDirection = logDirection;
    this.timestampMs = timestampMs;
  }
}
