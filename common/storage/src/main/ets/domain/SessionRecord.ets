/**
 * Session persistence record mapped to debug_session table.
 */
export class SessionRecord {
  readonly id: string;
  readonly type: string;
  readonly module: string;
  readonly protocol: string;
  readonly targetId: string;
  readonly displayName: string;
  readonly state: string;
  readonly startAtMs: number;
  readonly endAtMs: number;
  readonly resultJson: string;
  readonly errorJson: string;
  readonly attributesJson: string;

  constructor(
    id: string,
    type: string,
    module: string,
    protocol: string,
    targetId: string,
    displayName: string,
    state: string,
    startAtMs: number,
    endAtMs: number = 0,
    resultJson: string = '',
    errorJson: string = '',
    attributesJson: string = '{}'
  ) {
    this.id = id;
    this.type = type;
    this.module = module;
    this.protocol = protocol;
    this.targetId = targetId;
    this.displayName = displayName;
    this.state = state;
    this.startAtMs = startAtMs;
    this.endAtMs = endAtMs;
    this.resultJson = resultJson;
    this.errorJson = errorJson;
    this.attributesJson = attributesJson;
  }
}
