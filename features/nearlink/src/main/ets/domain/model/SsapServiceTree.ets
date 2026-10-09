export enum SsapClientState {
  IDLE = 'idle',
  CREATING = 'creating',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  DISCOVERING = 'discovering',
  READY = 'ready',
  DISCONNECTING = 'disconnecting',
  CLOSED = 'closed',
  FAILED = 'failed'
}

export enum SsapNotifyState {
  DISABLED = 'disabled',
  ENABLING = 'enabling',
  ENABLED = 'enabled',
  DISABLING = 'disabling',
  FAILED = 'failed'
}

export class SsapPropertyNode {
  readonly serviceUuid: string;
  readonly propertyUuid: string;
  notifyState: SsapNotifyState;
  lastValueHex: string;
  readonly operation: number;
  readonly hasClientConfig: boolean;

  constructor(
    serviceUuid: string,
    propertyUuid: string,
    notifyState: SsapNotifyState = SsapNotifyState.DISABLED,
    lastValueHex: string = '',
    operation: number = 0,
    hasClientConfig: boolean = false
  ) {
    this.serviceUuid = serviceUuid;
    this.propertyUuid = propertyUuid;
    this.notifyState = notifyState;
    this.lastValueHex = lastValueHex;
    this.operation = operation;
    this.hasClientConfig = hasClientConfig;
  }
}

export class SsapServiceNode {
  readonly serviceUuid: string;
  readonly properties: SsapPropertyNode[];

  constructor(serviceUuid: string, properties: SsapPropertyNode[] = []) {
    this.serviceUuid = serviceUuid;
    this.properties = properties;
  }
}

export class SsapServiceTreeSnapshot {
  readonly sessionId: string;
  readonly randomAddress: string;
  readonly state: SsapClientState;
  readonly mtu: number;
  readonly services: SsapServiceNode[];

  constructor(
    sessionId: string = '',
    randomAddress: string = '',
    mtu: number = 256,
    services: SsapServiceNode[] = [],
    state: SsapClientState = SsapClientState.IDLE
  ) {
    this.sessionId = sessionId;
    this.randomAddress = randomAddress;
    this.mtu = mtu;
    this.services = services;
    this.state = state;
  }
}
