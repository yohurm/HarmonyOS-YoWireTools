import { BluetoothConstants } from '../../constants/BluetoothConstants';

export class GattConnectParams {
  readonly deviceId: string;
  readonly displayName: string;
  readonly serviceUuid: string;
  readonly rxCharacteristicUuid: string;
  readonly txCharacteristicUuid: string;
  readonly useNordicPreset: boolean;
  readonly autoDetect: boolean;

  constructor(
    deviceId: string,
    displayName: string,
    serviceUuid: string = BluetoothConstants.NORDIC_UART_SERVICE_UUID,
    rxCharacteristicUuid: string = BluetoothConstants.NORDIC_UART_RX_UUID,
    txCharacteristicUuid: string = BluetoothConstants.NORDIC_UART_TX_UUID,
    useNordicPreset: boolean = true,
    autoDetect: boolean = false
  ) {
    this.deviceId = deviceId;
    this.displayName = displayName;
    this.serviceUuid = serviceUuid;
    this.rxCharacteristicUuid = rxCharacteristicUuid;
    this.txCharacteristicUuid = txCharacteristicUuid;
    this.useNordicPreset = useNordicPreset;
    this.autoDetect = autoDetect;
  }

  toConnectRecord(): Record<string, string | number | boolean> {
    const record: Record<string, string | number | boolean> = {};
    record['deviceId'] = this.deviceId;
    record['displayName'] = this.displayName;
    record['serviceUuid'] = this.serviceUuid;
    record['rxCharacteristicUuid'] = this.rxCharacteristicUuid;
    record['txCharacteristicUuid'] = this.txCharacteristicUuid;
    record['useNordicPreset'] = this.useNordicPreset;
    record['autoDetect'] = this.autoDetect;
    return record;
  }
}

export class ConnectGattResult {
  readonly sessionId: string;
  readonly transportId: string;

  constructor(sessionId: string, transportId: string) {
    this.sessionId = sessionId;
    this.transportId = transportId;
  }
}
