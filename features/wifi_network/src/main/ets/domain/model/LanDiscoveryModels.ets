export class LanDiscoveryConfig {
  readonly cidr: string;
  readonly probePorts: number[];
  readonly timeoutMs: number;
  readonly concurrency: number;

  constructor(
    cidr: string,
    probePorts: number[] = [80, 443, 22, 8080],
    timeoutMs: number = 2000,
    concurrency: number = 32
  ) {
    this.cidr = cidr;
    this.probePorts = probePorts;
    this.timeoutMs = timeoutMs;
    this.concurrency = concurrency;
  }
}

export class PortScanConfig {
  readonly host: string;
  readonly startPort: number;
  readonly endPort: number;
  readonly protocol: string;
  readonly timeoutMs: number;
  readonly concurrency: number;

  constructor(
    host: string,
    startPort: number,
    endPort: number,
    protocol: string = 'tcp',
    timeoutMs: number = 2000,
    concurrency: number = 32
  ) {
    this.host = host;
    this.startPort = startPort;
    this.endPort = endPort;
    this.protocol = protocol;
    this.timeoutMs = timeoutMs;
    this.concurrency = concurrency;
  }
}

export enum PortProbeState {
  OPEN = 'open',
  CLOSED = 'closed',
  FILTERED = 'filtered',
  UNKNOWN = 'unknown'
}

export class PortProbeResult {
  readonly host: string;
  readonly port: number;
  readonly protocol: string;
  readonly state: PortProbeState;
  readonly latencyMs: number;
  readonly error: string;

  constructor(
    host: string,
    port: number,
    protocol: string,
    state: PortProbeState,
    latencyMs: number = 0,
    error: string = ''
  ) {
    this.host = host;
    this.port = port;
    this.protocol = protocol;
    this.state = state;
    this.latencyMs = latencyMs;
    this.error = error;
  }
}

export enum LanHostAliveState {
  ALIVE = 'alive',
  UNKNOWN = 'unknown',
  UNREACHABLE = 'unreachable'
}

export class LanHostResult {
  readonly ip: string;
  readonly hostName: string;
  readonly aliveState: LanHostAliveState;
  readonly latencyMs: number;
  readonly openPorts: PortProbeResult[];
  readonly firstSeenAtMs: number;
  readonly lastSeenAtMs: number;

  constructor(
    ip: string,
    hostName: string,
    aliveState: LanHostAliveState,
    latencyMs: number,
    openPorts: PortProbeResult[],
    firstSeenAtMs: number,
    lastSeenAtMs: number
  ) {
    this.ip = ip;
    this.hostName = hostName;
    this.aliveState = aliveState;
    this.latencyMs = latencyMs;
    this.openPorts = openPorts;
    this.firstSeenAtMs = firstSeenAtMs;
    this.lastSeenAtMs = lastSeenAtMs;
  }
}

export enum PortScanPhase {
  IDLE = 'idle',
  PREPARING = 'preparing',
  RUNNING = 'running',
  CANCELLING = 'cancelling',
  COMPLETED = 'completed',
  CANCELLED = 'cancelled',
  FAILED = 'failed'
}
