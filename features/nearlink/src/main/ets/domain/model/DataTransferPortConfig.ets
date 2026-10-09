export enum DataTransferRuntimeState {
  IDLE = 'idle',
  CREATING_PORT = 'creating_port',
  PORT_READY = 'port_ready',
  PAIRING = 'pairing',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  SENDING = 'sending',
  CONGESTED = 'congested',
  DISCONNECTING = 'disconnecting',
  DISCONNECTED = 'disconnected',
  CLOSED = 'closed',
  FAILED = 'failed'
}

export class CongestionPolicy {
  readonly initialBackoffMs: number;
  readonly maxBackoffMs: number;
  readonly maxRetryCount: number;

  constructor(initialBackoffMs: number = 10, maxBackoffMs: number = 500, maxRetryCount: number = 5) {
    this.initialBackoffMs = initialBackoffMs;
    this.maxBackoffMs = maxBackoffMs;
    this.maxRetryCount = maxRetryCount;
  }
}

export class DataTransferPortConfig {
  readonly uuid: string;
  readonly mtu: number;
  readonly secureRequired: boolean;
  readonly congestionPolicy: CongestionPolicy;

  constructor(
    uuid: string = '',
    mtu: number = 512,
    secureRequired: boolean = false,
    congestionPolicy: CongestionPolicy = new CongestionPolicy()
  ) {
    this.uuid = uuid;
    this.mtu = mtu;
    this.secureRequired = secureRequired;
    this.congestionPolicy = congestionPolicy;
  }
}

export class DataTransferPacket {
  readonly direction: string;
  readonly payloadHex: string;
  readonly timestampMs: number;

  constructor(direction: string, payloadHex: string, timestampMs: number) {
    this.direction = direction;
    this.payloadHex = payloadHex;
    this.timestampMs = timestampMs;
  }
}
