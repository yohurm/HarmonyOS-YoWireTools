export class TcpClientConfig {
  readonly host: string;
  readonly port: number;
  readonly connectTimeoutMs: number;
  readonly autoReconnect: boolean;

  constructor(host: string, port: number, connectTimeoutMs: number = 10000, autoReconnect: boolean = false) {
    this.host = host;
    this.port = port;
    this.connectTimeoutMs = connectTimeoutMs;
    this.autoReconnect = autoReconnect;
  }
}

export class UdpSessionConfig {
  readonly localPort: number;
  readonly remoteHost: string;
  readonly remotePort: number;
  readonly allowBroadcast: boolean;

  constructor(
    localPort: number,
    remoteHost: string = '',
    remotePort: number = 0,
    allowBroadcast: boolean = false
  ) {
    this.localPort = localPort;
    this.remoteHost = remoteHost;
    this.remotePort = remotePort;
    this.allowBroadcast = allowBroadcast;
  }
}

export class MulticastSessionConfig {
  readonly localPort: number;
  readonly groupAddress: string;
  readonly ttl: number;

  constructor(localPort: number, groupAddress: string, ttl: number = 1) {
    this.localPort = localPort;
    this.groupAddress = groupAddress;
    this.ttl = ttl;
  }
}

export class TcpServerClientRecord {
  readonly id: string;
  readonly remoteAddress: string;
  readonly remotePort: number;
  readonly connectedAtMs: number;
  readonly lastMessage: string;

  constructor(
    id: string,
    remoteAddress: string,
    remotePort: number,
    connectedAtMs: number = Date.now(),
    lastMessage: string = ''
  ) {
    this.id = id;
    this.remoteAddress = remoteAddress;
    this.remotePort = remotePort;
    this.connectedAtMs = connectedAtMs;
    this.lastMessage = lastMessage;
  }
}

export class SocketConnectionParams {
  readonly mode: string;
  readonly host: string;
  readonly port: number;
  readonly localPort: number;
  readonly timeoutMs: number;

  constructor(
    mode: string,
    port: number,
    host: string = '',
    localPort: number = 0,
    timeoutMs: number = 10000
  ) {
    this.mode = mode;
    this.host = host;
    this.port = port;
    this.localPort = localPort;
    this.timeoutMs = timeoutMs;
  }
}
