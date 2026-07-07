/**
 * Command template record mapped to command_template table.
 */
export class CommandTemplateRecord {
  readonly id: string;
  readonly name: string;
  readonly module: string;
  readonly protocol: string;
  readonly payloadEncoding: string;
  readonly payload: string;
  readonly lineEnding: string;
  readonly writeMode: string;
  readonly repeatPolicyJson: string;
  readonly timeoutMs: number;
  readonly tagsJson: string;
  readonly createdAtMs: number;
  readonly updatedAtMs: number;

  constructor(
    id: string,
    name: string,
    module: string,
    protocol: string,
    payloadEncoding: string,
    payload: string,
    lineEnding: string,
    writeMode: string,
    repeatPolicyJson: string,
    timeoutMs: number,
    tagsJson: string,
    createdAtMs: number,
    updatedAtMs: number
  ) {
    this.id = id;
    this.name = name;
    this.module = module;
    this.protocol = protocol;
    this.payloadEncoding = payloadEncoding;
    this.payload = payload;
    this.lineEnding = lineEnding;
    this.writeMode = writeMode;
    this.repeatPolicyJson = repeatPolicyJson;
    this.timeoutMs = timeoutMs;
    this.tagsJson = tagsJson;
    this.createdAtMs = createdAtMs;
    this.updatedAtMs = updatedAtMs;
  }
}
