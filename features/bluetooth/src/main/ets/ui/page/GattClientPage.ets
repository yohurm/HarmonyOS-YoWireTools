import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { ConnectionParamPreset } from 'yobluetooth';
import { BluetoothObjectNavParams } from '../../navigation/BluetoothObjectNavParams';
import { GattClientViewModel } from '../../viewmodel/GattClientViewModel';

@ComponentV2
export struct GattClientPage {
  @Param params: BluetoothObjectNavParams = new BluetoothObjectNavParams();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: (sessionId: string) => void = (_sessionId: string) => {
  };
  @Local private vm: GattClientViewModel = new GattClientViewModel();

  aboutToDisappear(): void {
    this.vm.onDisappear();
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_gatt_client_title'),
      showBack: true,
      destinationKind: YoNavDestinationKind.OBJECT,
      onBack: this.onBack,
      content: this.body
    })
  }

  @LocalBuilder
  body() {
    Column({ space: YoSpace.M }) {
      Text(this.params.displayName)
        .fontSize(YoTypeStyle.BODY_M.size)
        .width('100%')
      Text($r('app.string.bt_address_virtual'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_TERTIARY)
        .width('100%')
      Text(this.vm.mtuPending ? $r('app.string.bt_mtu_negotiating') : `${this.vm.mtuShown}`)
        .fontSize(YoTypeStyle.BODY_M.size)
        .width('100%')
      TextInput({ text: this.vm.mtuText, placeholder: $r('app.string.bt_mtu_request') })
        .onChange((value: string) => {
          this.vm.mtuText = value;
        })
      Text($r('app.string.bt_phy_unverified'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      Text($r('app.string.bt_connection_param_presets_only'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      if (this.vm.securityHint === '2901005') {
        Text($r('app.string.bt_gatt_security_encryption'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      if (this.vm.securityHint === '2901006') {
        Text($r('app.string.bt_gatt_security_authentication'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      if (this.vm.securityHint === '2901007') {
        Text($r('app.string.bt_gatt_security_authorization'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      if (this.vm.statusText.length > 0) {
        Text(this.vm.statusText)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      if (this.vm.rssiText.length > 0) {
        Text(this.vm.rssiText)
          .fontSize(YoTypeStyle.BODY_S.size)
          .width('100%')
      }
      TextInput({ text: this.vm.serviceUuid, placeholder: $r('app.string.bt_ble_service_uuid') })
        .onChange((value: string) => {
          this.vm.serviceUuid = value;
        })
      TextInput({ text: this.vm.characteristicUuid, placeholder: $r('app.string.bt_gatt_characteristic') })
        .onChange((value: string) => {
          this.vm.characteristicUuid = value;
        })
      TextInput({ text: this.vm.descriptorUuid, placeholder: $r('app.string.bt_gatt_descriptor') })
        .onChange((value: string) => {
          this.vm.descriptorUuid = value;
        })
      TextInput({ text: this.vm.payloadHex, placeholder: $r('app.string.bt_gatt_payload_hex') })
        .onChange((value: string) => {
          this.vm.payloadHex = value;
        })
      YoActionButton({
        label: $r('app.string.bt_gatt_connect'),
        kind: YoActionButtonKind.PRIMARY,
        isEnabled: this.params.connectable,
        onTap: () => {
          void this.vm.connect(this.params.deviceId, this.params.displayName, this.params.connectable);
        }
      })
      if (!this.params.connectable) {
        Text($r('app.string.bt_ble_not_connectable'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
      }
      Row({ space: YoSpace.S }) {
        Button($r('app.string.bt_conn_low_power')).onClick(() => {
          void this.vm.applyPreset(ConnectionParamPreset.LOW_POWER);
        })
        Button($r('app.string.bt_conn_balanced')).onClick(() => {
          void this.vm.applyPreset(ConnectionParamPreset.BALANCED);
        })
        Button($r('app.string.bt_conn_high')).onClick(() => {
          void this.vm.applyPreset(ConnectionParamPreset.HIGH);
        })
      }
      Row({ space: YoSpace.S }) {
        Button($r('app.string.bt_gatt_read')).onClick(() => {
          void this.vm.readValue();
        })
        Button($r('app.string.bt_gatt_write')).onClick(() => {
          void this.vm.writeValue(false);
        })
        Button($r('app.string.bt_gatt_write_no_response')).onClick(() => {
          void this.vm.writeValue(true);
        })
      }
      Row({ space: YoSpace.S }) {
        Button($r('app.string.bt_gatt_read_descriptor')).onClick(() => {
          void this.vm.readDescriptorValue();
        })
        Button($r('app.string.bt_gatt_write_descriptor')).onClick(() => {
          void this.vm.writeDescriptorValue();
        })
        Button($r('app.string.bt_gatt_disconnect')).onClick(() => {
          void this.vm.disconnect();
        })
      }
      Row({ space: YoSpace.S }) {
        Button($r('app.string.bt_gatt_notify')).onClick(() => {
          void this.vm.subscribe(false);
        })
        Button($r('app.string.bt_gatt_indicate')).onClick(() => {
          void this.vm.subscribe(true);
        })
        Button($r('app.string.bt_gatt_rssi')).onClick(() => {
          void this.vm.readLinkRssi();
        })
        Button($r('app.string.bt_mtu_apply')).onClick(() => {
          void this.vm.applyMtu();
        })
      }
      Text(`${this.vm.throughputBytes}`)
        .fontSize(YoTypeStyle.BODY_M.size)
      YoActionButton({
        label: this.vm.throughputRunning ? $r('app.string.bt_throughput_stop') : $r('app.string.bt_throughput_start'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          if (this.vm.throughputRunning) {
            this.vm.stopThroughput();
          } else {
            void this.vm.startThroughput();
          }
        }
      })
      YoActionButton({
        label: $r('app.string.bt_entry_session_log'),
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          this.onOpenLog(this.vm.sessionId);
        }
      })
    }
    .width('100%')
  }
}
