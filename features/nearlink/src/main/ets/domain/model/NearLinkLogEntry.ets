export class NearLinkLogEntry {
  readonly id: string;
  readonly timeMs: number;
  readonly direction: string;
  readonly apiName: string;
  readonly nativeCode: string;
  readonly summary: string;
  readonly reasonMsg: string;
  readonly hex: string;
  readonly gap: boolean;

  constructor(
    id: string,
    timeMs: number,
    direction: string,
    apiName: string,
    nativeCode: string = '',
    summary: string = '',
    reasonMsg: string = '',
    hex: string = '',
    gap: boolean = false
  ) {
    this.id = id;
    this.timeMs = timeMs;
    this.direction = direction;
    this.apiName = apiName;
    this.nativeCode = nativeCode;
    this.summary = summary;
    this.reasonMsg = reasonMsg;
    this.hex = hex;
    this.gap = gap;
  }
}
