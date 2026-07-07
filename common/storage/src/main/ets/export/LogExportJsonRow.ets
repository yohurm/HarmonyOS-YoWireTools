/**
 * JSON export row DTO — explicit class for ArkTS strict object literal rules.
 */
export class LogExportJsonRow {
  readonly id: string;
  readonly sessionId: string;
  readonly module: string;
  readonly protocol: string;
  readonly direction: string;
  readonly recordType: string;
  readonly timestampMs: number;
  readonly summary: string;
  readonly displayHint: string;
  readonly appCode: string;
  readonly nativeCode: string;
  readonly attributes: string;
  readonly payloadHex: string;

  constructor(
    id: string,
    sessionId: string,
    module: string,
    protocol: string,
    direction: string,
    recordType: string,
    timestampMs: number,
    summary: string,
    displayHint: string,
    appCode: string,
    nativeCode: string,
    attributes: string,
    payloadHex: string
  ) {
    this.id = id;
    this.sessionId = sessionId;
    this.module = module;
    this.protocol = protocol;
    this.direction = direction;
    this.recordType = recordType;
    this.timestampMs = timestampMs;
    this.summary = summary;
    this.displayHint = displayHint;
    this.appCode = appCode;
    this.nativeCode = nativeCode;
    this.attributes = attributes;
    this.payloadHex = payloadHex;
  }
}
