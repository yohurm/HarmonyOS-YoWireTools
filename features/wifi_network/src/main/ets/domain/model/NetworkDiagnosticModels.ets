export enum DiagnosticStepKind {
  NETWORK_STATE = 'networkState',
  DNS_LOOKUP = 'dnsLookup',
  TCP_CONNECT = 'tcpConnect',
  HTTP_PROBE = 'httpProbe',
  PING_LIKE = 'pingLike'
}

export enum DiagnosticStepState {
  PENDING = 'pending',
  RUNNING = 'running',
  SUCCESS = 'success',
  FAILED = 'failed',
  SKIPPED = 'skipped'
}

export class DiagnosticStepResult {
  readonly step: DiagnosticStepKind;
  readonly state: DiagnosticStepState;
  readonly startAtMs: number;
  readonly endAtMs: number;
  readonly latencyMs: number;
  readonly nativeCode: number;
  readonly appCode: string;
  readonly detail: string;

  constructor(
    step: DiagnosticStepKind,
    state: DiagnosticStepState,
    startAtMs: number,
    endAtMs: number,
    latencyMs: number = 0,
    nativeCode: number = 0,
    appCode: string = '',
    detail: string = ''
  ) {
    this.step = step;
    this.state = state;
    this.startAtMs = startAtMs;
    this.endAtMs = endAtMs;
    this.latencyMs = latencyMs;
    this.nativeCode = nativeCode;
    this.appCode = appCode;
    this.detail = detail;
  }
}

export class NetworkDiagnosticPlan {
  readonly targetHost: string;
  readonly targetPort: number;
  readonly timeoutMs: number;
  readonly steps: DiagnosticStepKind[];

  constructor(
    targetHost: string,
    targetPort: number = 80,
    timeoutMs: number = 10000,
    steps: DiagnosticStepKind[] = [
      DiagnosticStepKind.NETWORK_STATE,
      DiagnosticStepKind.DNS_LOOKUP,
      DiagnosticStepKind.TCP_CONNECT,
      DiagnosticStepKind.HTTP_PROBE
    ]
  ) {
    this.targetHost = targetHost;
    this.targetPort = targetPort;
    this.timeoutMs = timeoutMs;
    this.steps = steps;
  }
}
