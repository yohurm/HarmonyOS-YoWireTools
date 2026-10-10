import {
  AdvertisingRequest,
  BluetoothUseCaseFactory,
  CloseGattServerUseCase,
  HexPayload,
  NotifyGattServerUseCase,
  OpenGattServerUseCase,
  StartBleAdvertiseUseCase,
  StopBleAdvertiseUseCase
} from 'yobluetooth';

@ObservedV2
export class BlePeripheralViewModel {
  @Trace serviceUuid: string = '';
  @Trace serviceDataUuid: string = '';
  @Trace serviceDataHex: string = '';
  @Trace manufacturerIdText: string = '';
  @Trace manufacturerHex: string = '';
  @Trace includeName: boolean = false;
  @Trace extended: boolean = false;
  @Trace connectable: boolean = true;
  @Trace scanResponseHex: string = '';
  @Trace statusText: string = '';
  @Trace advertising: boolean = false;
  @Trace serverOpen: boolean = false;
  @Trace serverServiceUuid: string = '';
  @Trace serverCharacteristicUuid: string = '';
  @Trace serverValueHex: string = '';
  @Trace serverPeerId: string = '';

  private readonly startAdvertise: StartBleAdvertiseUseCase = BluetoothUseCaseFactory.startBleAdvertise();
  private readonly stopAdvertise: StopBleAdvertiseUseCase = BluetoothUseCaseFactory.stopBleAdvertise();
  private readonly openServer: OpenGattServerUseCase = BluetoothUseCaseFactory.openGattServer();
  private readonly closeServer: CloseGattServerUseCase = BluetoothUseCaseFactory.closeGattServer();
  private readonly notifyServerUseCase: NotifyGattServerUseCase = BluetoothUseCaseFactory.notifyGattServer();

  onDisappear(): void {
    if (this.advertising) {
      void this.stop();
    }
    if (this.serverOpen) {
      this.closeGattServer();
    }
  }

  async start(): Promise<void> {
    const manufacturerId = this.manufacturerIdText.length === 0 ? -1 : Number(this.manufacturerIdText);
    const uuids: string[] = [];
    if (this.serviceUuid.length > 0) {
      uuids.push(this.serviceUuid);
    }
    const request = new AdvertisingRequest(
      uuids,
      this.serviceDataUuid,
      this.serviceDataHex,
      Number.isNaN(manufacturerId) ? -1 : manufacturerId,
      this.manufacturerHex,
      this.includeName,
      '',
      this.extended,
      this.connectable,
      this.scanResponseHex,
      0
    );
    const started = await this.startAdvertise.execute(request);
    if (!started.success) {
      this.advertising = false;
      this.statusText = started.error?.message ?? '';
      return;
    }
    this.advertising = true;
    this.statusText = '';
  }

  async openGattServer(): Promise<void> {
    const parsed = HexPayload.parse(this.serverValueHex.length > 0 ? this.serverValueHex : '00');
    if (!parsed.success || parsed.value === undefined) {
      this.serverOpen = false;
      this.statusText = parsed.error?.message ?? '';
      return;
    }
    const opened = await this.openServer.execute(
      this.serverServiceUuid,
      this.serverCharacteristicUuid,
      parsed.value
    );
    this.serverOpen = opened.success;
    this.statusText = opened.success ? '' : (opened.error?.message ?? '');
  }

  closeGattServer(): void {
    const closed = this.closeServer.execute();
    this.serverOpen = false;
    if (!closed.success) {
      this.statusText = closed.error?.message ?? '';
    }
  }

  async notifyServer(): Promise<void> {
    if (!this.serverOpen) {
      this.statusText = 'server_closed';
      return;
    }
    const parsed = HexPayload.parse(this.serverValueHex.length > 0 ? this.serverValueHex : '00');
    if (!parsed.success || parsed.value === undefined) {
      this.statusText = parsed.error?.message ?? '';
      return;
    }
    const notified = this.notifyServerUseCase.execute(
      this.serverPeerId,
      this.serverServiceUuid,
      this.serverCharacteristicUuid,
      parsed.value,
      false
    );
    if (!notified.success) {
      this.statusText = notified.error?.message ?? '';
    }
  }

  async stop(): Promise<void> {
    await this.stopAdvertise.execute();
    this.advertising = false;
  }
}
