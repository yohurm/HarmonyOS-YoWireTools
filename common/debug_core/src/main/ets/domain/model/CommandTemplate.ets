import { ModuleType, PayloadEncoding, ProtocolType, WriteMode, LineEndingMode } from '../enums/DomainEnums';

/**
 * Command variable placeholder per 05-§3.6.
 */
export class CommandVariable {
  readonly name: string;
  readonly defaultValue: string;
  readonly description: string;

  constructor(name: string, defaultValue: string = '', description: string = '') {
    this.name = name;
    this.defaultValue = defaultValue;
    this.description = description;
  }
}

/**
 * Repeat send policy per 05-§3.7.
 */
export class RepeatPolicy {
  readonly intervalMs: number;
  readonly maxCount: number;
  readonly maxDurationMs: number;
  readonly stopOnError: boolean;
  readonly allowBackground: boolean;

  constructor(
    intervalMs: number,
    maxCount: number = 0,
    maxDurationMs: number = 0,
    stopOnError: boolean = true,
    allowBackground: boolean = false
  ) {
    this.intervalMs = intervalMs;
    this.maxCount = maxCount;
    this.maxDurationMs = maxDurationMs;
    this.stopOnError = stopOnError;
    this.allowBackground = allowBackground;
  }
}

/**
 * Command template domain model per architecture §6.1.
 */
export class CommandTemplate {
  readonly id: string;
  readonly name: string;
  readonly module: ModuleType;
  readonly protocol: ProtocolType;
  readonly payloadEncoding: PayloadEncoding;
  readonly payload: string;
  readonly lineEnding: LineEndingMode;
  readonly writeMode: WriteMode;
  readonly repeatPolicy: RepeatPolicy | undefined;
  readonly timeoutMs: number;
  readonly tags: string[];
  readonly variables: CommandVariable[];
  readonly createdAtMs: number;
  readonly updatedAtMs: number;

  constructor(
    id: string,
    name: string,
    payload: string,
    payloadEncoding: PayloadEncoding = PayloadEncoding.TEXT,
    lineEnding: LineEndingMode = LineEndingMode.LF,
    writeMode: WriteMode = WriteMode.ONCE,
    timeoutMs: number = 5000,
    module: ModuleType = ModuleType.SYSTEM,
    protocol: ProtocolType = ProtocolType.NONE,
    repeatPolicy?: RepeatPolicy,
    tags: string[] = [],
    variables: CommandVariable[] = [],
    createdAtMs: number = Date.now(),
    updatedAtMs: number = Date.now()
  ) {
    this.id = id;
    this.name = name;
    this.module = module;
    this.protocol = protocol;
    this.payloadEncoding = payloadEncoding;
    this.payload = payload;
    this.lineEnding = lineEnding;
    this.writeMode = writeMode;
    this.repeatPolicy = repeatPolicy;
    this.timeoutMs = timeoutMs;
    this.tags = tags;
    this.variables = variables;
    this.createdAtMs = createdAtMs;
    this.updatedAtMs = updatedAtMs;
  }
}
