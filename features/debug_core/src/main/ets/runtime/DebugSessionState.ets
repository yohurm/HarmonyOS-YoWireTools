import { LogCaptureState, SessionState, TransportState } from '../domain/enums/DomainEnums';
import { DebugSession } from '../domain/model/DebugSession';

/**
 * Runtime session view for ViewModel subscription per 00-§8.
 */
export class DebugSessionState {
  readonly session: DebugSession;
  readonly bytesIn: number;
  readonly bytesOut: number;
  readonly logCount: number;
  readonly lastEventSummary: string;
  readonly captureState: LogCaptureState;
  readonly transportState: TransportState;

  constructor(
    session: DebugSession,
    bytesIn: number = 0,
    bytesOut: number = 0,
    logCount: number = 0,
    lastEventSummary: string = '',
    captureState: LogCaptureState = LogCaptureState.RECORDING,
    transportState: TransportState = TransportState.IDLE
  ) {
    this.session = session;
    this.bytesIn = bytesIn;
    this.bytesOut = bytesOut;
    this.logCount = logCount;
    this.lastEventSummary = lastEventSummary;
    this.captureState = captureState;
    this.transportState = transportState;
  }

  withSession(session: DebugSession): DebugSessionState {
    return new DebugSessionState(
      session,
      this.bytesIn,
      this.bytesOut,
      this.logCount,
      this.lastEventSummary,
      this.captureState,
      this.transportState
    );
  }

  withMetrics(bytesIn: number, bytesOut: number, logCount: number, summary: string): DebugSessionState {
    return new DebugSessionState(
      this.session,
      bytesIn,
      bytesOut,
      logCount,
      summary,
      this.captureState,
      this.transportState
    );
  }
}

export class DebugSessionSummary {
  readonly id: string;
  readonly displayName: string;
  readonly module: string;
  readonly protocol: string;
  readonly state: SessionState;
  readonly startAtMs: number;
  readonly logCount: number;

  constructor(
    id: string,
    displayName: string,
    module: string,
    protocol: string,
    state: SessionState,
    startAtMs: number,
    logCount: number = 0
  ) {
    this.id = id;
    this.displayName = displayName;
    this.module = module;
    this.protocol = protocol;
    this.state = state;
    this.startAtMs = startAtMs;
    this.logCount = logCount;
  }
}

export class SessionStatePatch {
  readonly state?: SessionState;
  readonly transportState?: TransportState;
  readonly captureState?: LogCaptureState;
  readonly lastEventSummary?: string;
  readonly bytesInDelta?: number;
  readonly bytesOutDelta?: number;
  readonly logCountDelta?: number;

  constructor(
    state?: SessionState,
    transportState?: TransportState,
    captureState?: LogCaptureState,
    lastEventSummary?: string,
    bytesInDelta?: number,
    bytesOutDelta?: number,
    logCountDelta?: number
  ) {
    this.state = state;
    this.transportState = transportState;
    this.captureState = captureState;
    this.lastEventSummary = lastEventSummary;
    this.bytesInDelta = bytesInDelta;
    this.bytesOutDelta = bytesOutDelta;
    this.logCountDelta = logCountDelta;
  }
}
