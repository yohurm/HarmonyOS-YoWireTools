export enum SppReadStrategy {
  ASYNC_LOOP = 'asyncLoop',
  EVENT_CALLBACK = 'eventCallback'
}

export enum SppConnectionPhase {
  IDLE = 'idle',
  PREPARING = 'preparing',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  READING = 'reading',
  RECONNECTING = 'reconnecting',
  DISCONNECTING = 'disconnecting',
  CLOSED = 'closed',
  FAILED = 'failed'
}

export class SppHeartbeatConfig {
  readonly enabled: boolean;
  readonly intervalMs: number;
  readonly payloadHex: string;

  constructor(enabled: boolean = false, intervalMs: number = 3000, payloadHex: string = '00') {
    this.enabled = enabled;
    this.intervalMs = intervalMs;
    this.payloadHex = payloadHex;
  }
}

export class SppRuntimeState {
  readonly sessionId: string;
  readonly clientSocket: number;
  readonly phase: SppConnectionPhase;
  readonly bytesIn: number;
  readonly bytesOut: number;
  readonly lastReadAtMs: number;
  readonly lastWriteAtMs: number;
  readonly idleMs: number;
  readonly readStrategy: SppReadStrategy;
  readonly virtualDeviceId: string;
  readonly errorMessage: string;

  constructor(
    sessionId: string,
    clientSocket: number = -1,
    phase: SppConnectionPhase = SppConnectionPhase.IDLE,
    bytesIn: number = 0,
    bytesOut: number = 0,
    lastReadAtMs: number = 0,
    lastWriteAtMs: number = 0,
    idleMs: number = 0,
    readStrategy: SppReadStrategy = SppReadStrategy.ASYNC_LOOP,
    virtualDeviceId: string = '',
    errorMessage: string = ''
  ) {
    this.sessionId = sessionId;
    this.clientSocket = clientSocket;
    this.phase = phase;
    this.bytesIn = bytesIn;
    this.bytesOut = bytesOut;
    this.lastReadAtMs = lastReadAtMs;
    this.lastWriteAtMs = lastWriteAtMs;
    this.idleMs = idleMs;
    this.readStrategy = readStrategy;
    this.virtualDeviceId = virtualDeviceId;
    this.errorMessage = errorMessage;
  }
}
