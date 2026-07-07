export enum MqttClientPhase {
  IDLE = 'idle',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  DISCONNECTING = 'disconnecting',
  FAILED = 'failed'
}

export class MqttConnectConfig {
  readonly brokerHost: string;
  readonly brokerPort: number;
  readonly clientId: string;
  readonly username: string;
  readonly password: string;
  readonly topic: string;
  readonly qos: number;

  constructor(
    brokerHost: string,
    brokerPort: number = 1883,
    clientId: string = 'yowire-mqtt',
    username: string = '',
    password: string = '',
    topic: string = 'test/topic',
    qos: number = 0
  ) {
    this.brokerHost = brokerHost;
    this.brokerPort = brokerPort;
    this.clientId = clientId;
    this.username = username;
    this.password = password;
    this.topic = topic;
    this.qos = qos;
  }
}

export class MqttMessageRecord {
  readonly direction: string;
  readonly topic: string;
  readonly payload: string;
  readonly timestampMs: number;

  constructor(direction: string, topic: string, payload: string, timestampMs: number = Date.now()) {
    this.direction = direction;
    this.topic = topic;
    this.payload = payload;
    this.timestampMs = timestampMs;
  }
}

export class DiscoveredNetworkService {
  readonly id: string;
  readonly type: string;
  readonly name: string;
  readonly host: string;
  readonly port: number;
  readonly protocol: string;
  readonly txt: string;
  readonly firstSeenAtMs: number;
  readonly lastSeenAtMs: number;

  constructor(
    id: string,
    type: string,
    name: string,
    host: string,
    port: number,
    protocol: string = 'tcp',
    txt: string = '',
    firstSeenAtMs: number = Date.now(),
    lastSeenAtMs: number = Date.now()
  ) {
    this.id = id;
    this.type = type;
    this.name = name;
    this.host = host;
    this.port = port;
    this.protocol = protocol;
    this.txt = txt;
    this.firstSeenAtMs = firstSeenAtMs;
    this.lastSeenAtMs = lastSeenAtMs;
  }
}
