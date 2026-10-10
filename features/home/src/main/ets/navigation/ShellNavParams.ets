export class LogDetailNavParams {
  readonly recordId: string;
  readonly module: string;
  readonly protocol: string;
  readonly summary: string;
  readonly direction: string;
  readonly timestampMs: number;

  constructor(
    recordId: string,
    module: string,
    protocol: string,
    summary: string,
    direction: string,
    timestampMs: number
  ) {
    this.recordId = recordId;
    this.module = module;
    this.protocol = protocol;
    this.summary = summary;
    this.direction = direction;
    this.timestampMs = timestampMs;
  }
}
