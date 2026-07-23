export enum GattNotifyState {
  DISABLED = 'disabled',
  ENABLING = 'enabling',
  ENABLED = 'enabled',
  DISABLING = 'disabling',
  FAILED = 'failed'
}

export enum GattClientState {
  IDLE = 'idle',
  CREATING = 'creating',
  CONNECTING = 'connecting',
  CONNECTED = 'connected',
  DISCOVERING = 'discovering',
  READY = 'ready',
  READING = 'reading',
  WRITING = 'writing',
  SUBSCRIBING = 'subscribing',
  DISCONNECTING = 'disconnecting',
  CLOSED = 'closed',
  FAILED = 'failed'
}

export class GattDescriptorNode {
  readonly serviceUuid: string;
  readonly characteristicUuid: string;
  readonly descriptorUuid: string;
  readonly permissions: string[];
  readonly lastValueHex: string;

  constructor(
    serviceUuid: string,
    characteristicUuid: string,
    descriptorUuid: string,
    permissions: string[] = [],
    lastValueHex: string = ''
  ) {
    this.serviceUuid = serviceUuid;
    this.characteristicUuid = characteristicUuid;
    this.descriptorUuid = descriptorUuid;
    this.permissions = permissions;
    this.lastValueHex = lastValueHex;
  }

  withValue(hex: string): GattDescriptorNode {
    return new GattDescriptorNode(
      this.serviceUuid,
      this.characteristicUuid,
      this.descriptorUuid,
      this.permissions,
      hex
    );
  }
}

export class GattCharacteristicNode {
  readonly serviceUuid: string;
  readonly characteristicUuid: string;
  readonly properties: string[];
  readonly permissions: string[];
  readonly descriptors: GattDescriptorNode[];
  readonly notifyState: GattNotifyState;
  readonly lastValueHex: string;

  constructor(
    serviceUuid: string,
    characteristicUuid: string,
    properties: string[] = [],
    permissions: string[] = [],
    descriptors: GattDescriptorNode[] = [],
    notifyState: GattNotifyState = GattNotifyState.DISABLED,
    lastValueHex: string = ''
  ) {
    this.serviceUuid = serviceUuid;
    this.characteristicUuid = characteristicUuid;
    this.properties = properties;
    this.permissions = permissions;
    this.descriptors = descriptors;
    this.notifyState = notifyState;
    this.lastValueHex = lastValueHex;
  }

  withValue(hex: string): GattCharacteristicNode {
    return new GattCharacteristicNode(
      this.serviceUuid,
      this.characteristicUuid,
      this.properties,
      this.permissions,
      this.descriptors,
      this.notifyState,
      hex
    );
  }

  withNotifyState(state: GattNotifyState): GattCharacteristicNode {
    return new GattCharacteristicNode(
      this.serviceUuid,
      this.characteristicUuid,
      this.properties,
      this.permissions,
      this.descriptors,
      state,
      this.lastValueHex
    );
  }
}

export class GattServiceNode {
  readonly serviceUuid: string;
  readonly isPrimary: boolean;
  readonly characteristics: GattCharacteristicNode[];
  readonly includeServices: string[];

  constructor(
    serviceUuid: string,
    isPrimary: boolean = true,
    characteristics: GattCharacteristicNode[] = [],
    includeServices: string[] = []
  ) {
    this.serviceUuid = serviceUuid;
    this.isPrimary = isPrimary;
    this.characteristics = characteristics;
    this.includeServices = includeServices;
  }
}

export class GattServiceTreeSnapshot {
  readonly sessionId: string;
  readonly bleDeviceId: string;
  readonly mtu: number;
  readonly services: GattServiceNode[];
  readonly state: GattClientState;

  constructor(
    sessionId: string,
    bleDeviceId: string,
    mtu: number,
    services: GattServiceNode[],
    state: GattClientState = GattClientState.READY
  ) {
    this.sessionId = sessionId;
    this.bleDeviceId = bleDeviceId;
    this.mtu = mtu;
    this.services = services;
    this.state = state;
  }
}
