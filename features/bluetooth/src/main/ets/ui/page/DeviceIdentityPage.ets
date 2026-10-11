import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { BluetoothObjectNavParams } from '../../navigation/BluetoothObjectNavParams';
import { DeviceIdentityViewModel } from '../../viewmodel/DeviceIdentityViewModel';

@ComponentV2
export struct DeviceIdentityPage {
  @Param params: BluetoothObjectNavParams = new BluetoothObjectNavParams();
  @Event onBack: () => void = () => {
  };
  @Local private vm: DeviceIdentityViewModel = new DeviceIdentityViewModel();

  build() {
    YoPageShell({
      title: $r('app.string.bt_identity_title'),
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
        .fontSize(YoTypeStyle.SUBTITLE_M.size)
        .fontColor(YoColor.TEXT_PRIMARY)
        .width('100%')
      Text(this.params.addressText)
        .fontSize(YoTypeStyle.BODY_M.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      Text($r('app.string.bt_address_virtual'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_TERTIARY)
        .width('100%')
      Text($r('app.string.bt_identity_favorite_bookmark'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      Text($r('app.string.bt_identity_no_spp_from_ble'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      Text($r('app.string.bt_identity_no_classic_to_gatt'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      Text($r('app.string.bt_pairing_cannot_unpair'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      Text($r('app.string.bt_identity_stale_address'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      if (this.vm.message.length > 0) {
        Text(this.vm.message)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      YoActionButton({
        label: $r('app.string.bt_identity_save_bookmark'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.saveBookmark(this.params.deviceId, this.params.displayName, this.params.addressText);
        }
      })
      if (this.params.deviceId.length > 0) {
        YoActionButton({
          label: $r('app.string.bt_identity_pair_from_ble'),
          kind: YoActionButtonKind.PRIMARY,
          onTap: () => {
            void this.vm.pairFromBle(this.params.deviceId, this.params.displayName);
          }
        })
      }
      YoActionButton({
        label: $r('app.string.bt_action_open_settings'),
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          void this.vm.openSettings();
        }
      })
    }
    .width('100%')
  }
}
