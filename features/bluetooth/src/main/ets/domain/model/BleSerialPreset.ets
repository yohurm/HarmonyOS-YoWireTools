/**
 * BLE serial profile endpoint UUIDs per architecture bluetooth/03-§8.
 */
export class BleSerialEndpoints {
  readonly serviceUuid: string;
  readonly rxCharacteristicUuid: string;
  readonly txCharacteristicUuid: string;

  constructor(serviceUuid: string, rxCharacteristicUuid: string, txCharacteristicUuid: string) {
    this.serviceUuid = serviceUuid;
    this.rxCharacteristicUuid = rxCharacteristicUuid;
    this.txCharacteristicUuid = txCharacteristicUuid;
  }
}
