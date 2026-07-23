import { BluetoothConstants } from '../../constants/BluetoothConstants';

export class SppUuidPreset {
  readonly label: string;
  readonly uuid: string;

  constructor(label: string, uuid: string) {
    this.label = label;
    this.uuid = uuid;
  }

  static listDefaults(): SppUuidPreset[] {
    return [
      new SppUuidPreset('Serial Port Profile (SPP)', BluetoothConstants.DEFAULT_SPP_UUID),
      new SppUuidPreset('Nordic UART Service', BluetoothConstants.NORDIC_UART_SERVICE_UUID)
    ];
  }
}
