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
  private readonly startAdvertise: StartBleAdvertiseUseCase = new StartBleAdvertiseUseCase();

  aboutToDisappear(): void {
    if (this.advertising) {
      void this.stop();
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

  private async stop(): Promise<void> {
    const stopper = new StopBleAdvertiseUseCase(this.startAdvertise.source());
    await stopper.execute();
    this.advertising = false;
  }
}
