/**
 * Command history record mapped to command_history table.
 */
export class CommandHistoryRecord {
  readonly id: string;
  readonly templateId: string;
  readonly sessionId: string;
  readonly module: string;
  readonly protocol: string;
  readonly payload: string;
  readonly payloadEncoding: string;
  readonly sentAtMs: number;
  readonly resultJson: string;
  readonly attributesJson: string;

  constructor(
    id: string,
    templateId: string,
    sessionId: string,
    module: string,
    protocol: string,
    payload: string,
    payloadEncoding: string,
    sentAtMs: number,
    resultJson: string = '',
    attributesJson: string = '{}'
  ) {
    this.id = id;
    this.templateId = templateId;
    this.sessionId = sessionId;
    this.module = module;
    this.protocol = protocol;
    this.payload = payload;
    this.payloadEncoding = payloadEncoding;
    this.sentAtMs = sentAtMs;
    this.resultJson = resultJson;
    this.attributesJson = attributesJson;
  }
}
