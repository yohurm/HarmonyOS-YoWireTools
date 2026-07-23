import {
  AppMode,
  Direction,
  DisplayHint,
  LogRecordType,
  ModuleType,
  ProtocolType,
  SessionState,
  SessionType
} from '../enums/DomainEnums';
import { DebugError } from './DebugError';
import { DebugTarget } from './DebugTarget';
import { SessionResult } from './SessionResult';

/**
 * Root session entity per 05-§3.2.
 */
export class DebugSession {
  readonly id: string;
  readonly type: SessionType;
  readonly module: ModuleType;
  readonly protocol: ProtocolType;
  readonly target: DebugTarget | undefined;
  readonly displayName: string;
  readonly mode: AppMode;
  readonly state: SessionState;
  readonly startAtMs: number;
  readonly endAtMs: number;
  readonly result: SessionResult | undefined;
  readonly error: DebugError | undefined;
  readonly tags: string[];
  readonly attributes: Record<string, string | number | boolean>;

  constructor(
    id: string,
    type: SessionType,
    module: ModuleType,
    protocol: ProtocolType,
    displayName: string,
    mode: AppMode,
    state: SessionState,
    startAtMs: number,
    endAtMs: number = 0,
    target?: DebugTarget,
    result?: SessionResult,
    error?: DebugError,
    tags: string[] = [],
    attributes: Record<string, string | number | boolean> = {}
  ) {
    this.id = id;
    this.type = type;
    this.module = module;
    this.protocol = protocol;
    this.target = target;
    this.displayName = displayName;
    this.mode = mode;
    this.state = state;
    this.startAtMs = startAtMs;
    this.endAtMs = endAtMs;
    this.result = result;
    this.error = error;
    this.tags = tags;
    this.attributes = attributes;
  }

  withState(state: SessionState, endAtMs: number = 0): DebugSession {
    return new DebugSession(
      this.id,
      this.type,
      this.module,
      this.protocol,
      this.displayName,
      this.mode,
      state,
      this.startAtMs,
      endAtMs > 0 ? endAtMs : this.endAtMs,
      this.target,
      this.result,
      this.error,
      this.tags,
      this.attributes
    );
  }

  withError(error: DebugError, state: SessionState = SessionState.FAILED): DebugSession {
    return new DebugSession(
      this.id,
      this.type,
      this.module,
      this.protocol,
      this.displayName,
      this.mode,
      state,
      this.startAtMs,
      Date.now(),
      this.target,
      this.result,
      error,
      this.tags,
      this.attributes
    );
  }
}

export class CreateSessionInput {
  readonly type: SessionType;
  readonly module: ModuleType;
  readonly protocol: ProtocolType;
  readonly displayName: string;
  readonly mode: AppMode;
  readonly target: DebugTarget | undefined;
  readonly tags: string[];
  readonly attributes: Record<string, string | number | boolean>;

  constructor(
    type: SessionType,
    module: ModuleType,
    protocol: ProtocolType,
    displayName: string,
    mode: AppMode = AppMode.EXPERT,
    target?: DebugTarget,
    tags: string[] = [],
    attributes: Record<string, string | number | boolean> = {}
  ) {
    this.type = type;
    this.module = module;
    this.protocol = protocol;
    this.displayName = displayName;
    this.mode = mode;
    this.target = target;
    this.tags = tags;
    this.attributes = attributes;
  }
}
