export class BluetoothObjectNavParams {
  deviceId: string = '';
  displayName: string = '';
  addressText: string = '';
  connectable: boolean = true;
  sessionId: string = '';

  constructor(
    deviceId: string = '',
    displayName: string = '',
    addressText: string = '',
    connectable: boolean = true,
    sessionId: string = ''
  ) {
    this.deviceId = deviceId;
    this.displayName = displayName;
    this.addressText = addressText;
    this.connectable = connectable;
    this.sessionId = sessionId;
  }
}
