import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { BlePeripheralViewModel } from '../../viewmodel/BlePeripheralViewModel';

@ComponentV2
export struct BlePeripheralPage {
  @Event onBack: () => void = () => {
  };
  @Local private vm: BlePeripheralViewModel = new BlePeripheralViewModel();

  aboutToDisappear(): void {
    this.vm.onDisappear();
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
      TextInput({ text: this.vm.serviceUuid, placeholder: $r('app.string.bt_ble_service_uuid') })
        .onChange((value: string) => {
          this.vm.serviceUuid = value;
        })
      TextInput({ text: this.vm.serviceDataUuid, placeholder: $r('app.string.bt_peripheral_service_data_uuid') })
        .onChange((value: string) => {
          this.vm.serviceDataUuid = value;
        })
      TextInput({ text: this.vm.serviceDataHex, placeholder: $r('app.string.bt_peripheral_service_data') })
        .onChange((value: string) => {
          this.vm.serviceDataHex = value;
        })
      TextInput({ text: this.vm.manufacturerIdText, placeholder: $r('app.string.bt_ble_manufacturer') })
        .onChange((value: string) => {
          this.vm.manufacturerIdText = value;
        })
      TextInput({ text: this.vm.manufacturerHex, placeholder: $r('app.string.bt_peripheral_manufacturer_data') })
        .onChange((value: string) => {
          this.vm.manufacturerHex = value;
        })
      TextInput({ text: this.vm.scanResponseHex, placeholder: $r('app.string.bt_peripheral_scan_response') })
        .onChange((value: string) => {
          this.vm.scanResponseHex = value;
        })
      Row({ space: YoSpace.S }) {
        Button($r('app.string.bt_peripheral_toggle_name'))
          .onClick(() => {
            this.vm.includeName = !this.vm.includeName;
          })
        Button($r('app.string.bt_peripheral_toggle_extended'))
          .onClick(() => {
            this.vm.extended = !this.vm.extended;
          })
        Button($r('app.string.bt_peripheral_toggle_connectable'))
          .onClick(() => {
            this.vm.connectable = !this.vm.connectable;
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
      if (this.vm.statusText.length > 0) {
        Text(this.vm.statusText)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      TextInput({ text: this.vm.serverServiceUuid, placeholder: $r('app.string.bt_ble_service_uuid') })
        .onChange((value: string) => {
          this.vm.serverServiceUuid = value;
        })
      TextInput({ text: this.vm.serverCharacteristicUuid, placeholder: $r('app.string.bt_gatt_characteristic') })
        .onChange((value: string) => {
          this.vm.serverCharacteristicUuid = value;
        })
      TextInput({ text: this.vm.serverValueHex, placeholder: $r('app.string.bt_peripheral_server_value') })
        .onChange((value: string) => {
          this.vm.serverValueHex = value;
        })
      TextInput({ text: this.vm.serverPeerId, placeholder: $r('app.string.bt_peripheral_server_device') })
        .onChange((value: string) => {
          this.vm.serverPeerId = value;
        })
      Row({ space: YoSpace.S }) {
        Button($r('app.string.bt_peripheral_server_open')).onClick(() => {
          void this.vm.openGattServer();
        })
        Button($r('app.string.bt_peripheral_server_notify'))
          .enabled(this.vm.serverOpen)
          .onClick(() => {
            void this.vm.notifyServer();
          })
        Button($r('app.string.bt_peripheral_server_close'))
          .enabled(this.vm.serverOpen)
          .onClick(() => {
            this.vm.closeGattServer();
          })
      }
      YoActionButton({
        label: this.vm.advertising ? $r('app.string.bt_peripheral_stop') : $r('app.string.bt_peripheral_start'),
        kind: YoActionButtonKind.PRIMARY,
        onTap: () => {
          if (this.vm.advertising) {
            void this.vm.stop();
          } else {
            void this.vm.start();
          }
        }
      })
    }
    .width('100%')
  }
}
