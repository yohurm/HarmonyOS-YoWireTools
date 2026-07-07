/**
 * Domain reference to a GATT characteristic (UUIDs + properties, no platform types).
 */
export class GattCharacteristicRef {
  readonly serviceUuid: string;
  readonly characteristicUuid: string;
  readonly properties: string[];

  constructor(serviceUuid: string, characteristicUuid: string, properties: string[] = []) {
    this.serviceUuid = serviceUuid;
    this.characteristicUuid = characteristicUuid;
    this.properties = properties;
  }
}

export class GattDescriptorRef {
  readonly serviceUuid: string;
  readonly characteristicUuid: string;
  readonly descriptorUuid: string;

  constructor(serviceUuid: string, characteristicUuid: string, descriptorUuid: string) {
    this.serviceUuid = serviceUuid;
    this.characteristicUuid = characteristicUuid;
    this.descriptorUuid = descriptorUuid;
  }
}

export class GattCharacteristicChangeEvent {
  readonly serviceUuid: string;
  readonly characteristicUuid: string;
  readonly valueHex: string;

  constructor(serviceUuid: string, characteristicUuid: string, valueHex: string) {
    this.serviceUuid = serviceUuid;
    this.characteristicUuid = characteristicUuid;
    this.valueHex = valueHex;
  }
}
