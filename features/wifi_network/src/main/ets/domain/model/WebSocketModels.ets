export class WebSocketConfig {
  readonly url: string;
  readonly headers: Record<string, string>;
  readonly autoReconnect: boolean;
  readonly maxMessageBytes: number;
  constructor(
    url: string,
    headers: Record<string, string> = {},
    autoReconnect: boolean = false,
    maxMessageBytes: number = 5 * 1024 * 1024 - 16
  ) {
    this.url = url;
    this.headers = headers;
    this.autoReconnect = autoReconnect;
    this.maxMessageBytes = maxMessageBytes;
  }
}

export enum WebSocketClientPhase {
  IDLE = 'idle',
  CREATING = 'creating',
  CONNECTING = 'connectingRequestCreated',
  OPEN = 'open',
  CLOSING = 'closing',
  CLOSED = 'closed',
  FAILED = 'failed'
}

export class WebSocketMessageRecord {
  readonly direction: string;
  readonly messageType: string;
  readonly payload: string;
  readonly timestampMs: number;
  constructor(direction: string, messageType: string, payload: string, timestampMs: number) {
    this.direction = direction;
    this.messageType = messageType;
    this.payload = payload;
    this.timestampMs = timestampMs;
  }
}

export enum WebSocketServerPhase {
  IDLE = 'idle',
  LISTENING = 'listening',
  FAILED = 'failed'
}

export class WebSocketServerConfigModel {
  readonly serverPort: number;
  readonly maxClients: number;
  readonly maxConnectionsPerClient: number;
  constructor(serverPort: number, maxClients: number = 10, maxConnectionsPerClient: number = 10) {
    this.serverPort = serverPort;
    this.maxClients = maxClients;
    this.maxConnectionsPerClient = maxConnectionsPerClient;
  }
}

export class WebSocketServerClientRecord {
  readonly id: string;
  readonly remoteHost: string;
  readonly remotePort: number;
  readonly lastMessage: string;
  readonly lastSeenAtMs: number;
  constructor(
    id: string,
    remoteHost: string,
    remotePort: number,
    lastMessage: string = '',
    lastSeenAtMs: number = Date.now()
  ) {
    this.id = id;
    this.remoteHost = remoteHost;
    this.remotePort = remotePort;
    this.lastMessage = lastMessage;
    this.lastSeenAtMs = lastSeenAtMs;
  }
}
