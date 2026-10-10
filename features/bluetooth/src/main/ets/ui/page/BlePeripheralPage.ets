import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import {
  AdvertisingRequest,
  CloseGattServerUseCase,
  HexPayload,
  NotifyGattServerUseCase,
  OpenGattServerUseCase,
  StartBleAdvertiseUseCase,
  StopBleAdvertiseUseCase
} from 'yobluetooth';

@ComponentV2
export struct BlePeripheralPage {
  @Event onBack: () => void = () => {
  };
  @Local serviceUuid: string = '';
  @Local serviceDataUuid: string = '';
  @Local serviceDataHex: string = '';
  @Local manufacturerIdText: string = '';
  @Local manufacturerHex: string = '';
  @Local includeName: boolean = false;
  @Local extended: boolean = false;
  @Local connectable: boolean = true;
  @Local scanResponseHex: string = '';
  @Local statusText: string = '';
  @Local advertising: boolean = false;
  @Local serverOpen: boolean = false;
  @Local serverServiceUuid: string = '';
  @Local serverCharacteristicUuid: string = '';
  @Local serverValueHex: string = '';
  @Local serverPeerId: string = '';
  private readonly startAdvertise: StartBleAdvertiseUseCase = new StartBleAdvertiseUseCase();
  private readonly openServer: OpenGattServerUseCase = new OpenGattServerUseCase();

  aboutToDisappear(): void {
    if (this.advertising) {
      void this.stop();
    }
    if (this.serverOpen) {
      this.closeGattServer();
    }
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_peripheral_title'),
      showBack: true,
      destinationKind: YoNavDestinationKind.MODULE,
      onBack: this.onBack,
      content: this.body
    })
  }

  @LocalBuilder
  body() {
    Column({ space: YoSpace.M }) {
      Text($r('app.string.bt_peripheral_no_custom_ad_type'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      TextInput({ text: this.serviceUuid, placeholder: $r('app.string.bt_ble_service_uuid') })
        .onChange((value: string) => {
          this.serviceUuid = value;
        })
      TextInput({ text: this.serviceDataUuid, placeholder: $r('app.string.bt_peripheral_service_data_uuid') })
        .onChange((value: string) => {
          this.serviceDataUuid = value;
        })
      TextInput({ text: this.serviceDataHex, placeholder: $r('app.string.bt_peripheral_service_data') })
        .onChange((value: string) => {
          this.serviceDataHex = value;
        })
      TextInput({ text: this.manufacturerIdText, placeholder: $r('app.string.bt_ble_manufacturer') })
        .onChange((value: string) => {
          this.manufacturerIdText = value;
        })
      TextInput({ text: this.manufacturerHex, placeholder: $r('app.string.bt_peripheral_manufacturer_data') })
        .onChange((value: string) => {
          this.manufacturerHex = value;
        })
      TextInput({ text: this.scanResponseHex, placeholder: $r('app.string.bt_peripheral_scan_response') })
        .onChange((value: string) => {
          this.scanResponseHex = value;
        })
      Row({ space: YoSpace.S }) {
        Button($r('app.string.bt_peripheral_toggle_name'))
          .onClick(() => {
            this.includeName = !this.includeName;
          })
        Button($r('app.string.bt_peripheral_toggle_extended'))
          .onClick(() => {
            this.extended = !this.extended;
          })
        Button($r('app.string.bt_peripheral_toggle_connectable'))
          .onClick(() => {
            this.connectable = !this.connectable;
          })
      }
      Text($r('app.string.bt_peripheral_extended_mutex'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_TERTIARY)
        .width('100%')
      Text($r('app.string.bt_peripheral_server_responds'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      if (this.statusText.length > 0) {
        Text(this.statusText)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      TextInput({ text: this.serverServiceUuid, placeholder: $r('app.string.bt_ble_service_uuid') })
        .onChange((value: string) => {
          this.serverServiceUuid = value;
        })
      TextInput({ text: this.serverCharacteristicUuid, placeholder: $r('app.string.bt_gatt_characteristic') })
        .onChange((value: string) => {
          this.serverCharacteristicUuid = value;
        })
      TextInput({ text: this.serverValueHex, placeholder: $r('app.string.bt_peripheral_server_value') })
        .onChange((value: string) => {
          this.serverValueHex = value;
        })
      TextInput({ text: this.serverPeerId, placeholder: $r('app.string.bt_peripheral_server_device') })
        .onChange((value: string) => {
          this.serverPeerId = value;
        })
      Row({ space: YoSpace.S }) {
        Button($r('app.string.bt_peripheral_server_open')).onClick(() => {
          void this.openGattServer();
        })
        Button($r('app.string.bt_peripheral_server_notify'))
          .enabled(this.serverOpen)
          .onClick(() => {
            void this.notifyServer();
          })
        Button($r('app.string.bt_peripheral_server_close'))
          .enabled(this.serverOpen)
          .onClick(() => {
            this.closeGattServer();
          })
      }
      YoActionButton({
        label: this.advertising ? $r('app.string.bt_peripheral_stop') : $r('app.string.bt_peripheral_start'),
        kind: YoActionButtonKind.PRIMARY,
        onTap: () => {
          if (this.advertising) {
            void this.stop();
          } else {
            void this.start();
          }
        }
      })
    }
    .width('100%')
  }

  private async start(): Promise<void> {
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

  private async openGattServer(): Promise<void> {
    const parsed = HexPayload.parse(this.serverValueHex.length > 0 ? this.serverValueHex : '00');
    if (!parsed.success || parsed.value === undefined) {
      this.serverOpen = false;
      this.statusText = parsed.error?.message ?? '';
      return;
    }
    const opened = await this.openServer.executeFields(
      this.serverServiceUuid,
      this.serverCharacteristicUuid,
      parsed.value
    );
    this.serverOpen = opened.success;
    this.statusText = opened.success ? '' : (opened.error?.message ?? '');
  }

  private closeGattServer(): void {
    const closed = new CloseGattServerUseCase(this.openServer.source()).execute();
    this.serverOpen = false;
    if (!closed.success) {
      this.statusText = closed.error?.message ?? '';
    }
  }

  private async notifyServer(): Promise<void> {
    if (!this.serverOpen) {
      this.statusText = 'server_closed';
      return;
    }
    const parsed = HexPayload.parse(this.serverValueHex.length > 0 ? this.serverValueHex : '00');
    if (!parsed.success || parsed.value === undefined) {
      this.statusText = parsed.error?.message ?? '';
      return;
    }
    const notified = new NotifyGattServerUseCase(this.openServer.source()).executeValue(
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

  private async stop(): Promise<void> {
    const stopper = new StopBleAdvertiseUseCase(this.startAdvertise.source());
    await stopper.execute();
    this.advertising = false;
  }
}
