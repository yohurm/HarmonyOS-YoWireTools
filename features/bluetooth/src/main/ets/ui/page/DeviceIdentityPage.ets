import { AbilityContextRegistry, BluetoothSettingsNavigator } from 'common_platform';
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
  BluetoothDevice,
  BluetoothDeviceDraft,
  BridgeBleToClassicPairUseCase,
  SaveBluetoothFavoriteUseCase
} from 'yobluetooth';
import { BluetoothObjectNavParams } from '../../navigation/BluetoothObjectNavParams';

@ComponentV2
export struct DeviceIdentityPage {
  @Param params: BluetoothObjectNavParams = new BluetoothObjectNavParams();
  @Event onBack: () => void = () => {
  };
  @Local message: string = '';
  private readonly favorite: SaveBluetoothFavoriteUseCase = new SaveBluetoothFavoriteUseCase();
  private readonly bridgePair: BridgeBleToClassicPairUseCase = new BridgeBleToClassicPairUseCase();

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
      if (this.message.length > 0) {
        Text(this.message)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      YoActionButton({
        label: $r('app.string.bt_identity_save_bookmark'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.saveBookmark();
        }
      })
      if (this.params.deviceId.length > 0) {
        YoActionButton({
          label: $r('app.string.bt_identity_pair_from_ble'),
          kind: YoActionButtonKind.PRIMARY,
          onTap: () => {
            void this.pairFromBle();
          }
        })
      }
      YoActionButton({
        label: $r('app.string.bt_action_open_settings'),
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          void this.openSettings();
        }
      })
    }
    .width('100%')
  }

  private async saveBookmark(): Promise<void> {
    const draft = new BluetoothDeviceDraft();
    draft.bleDeviceId = this.params.deviceId;
    draft.displayName = this.params.displayName;
    draft.primaryDeviceId = this.params.deviceId.length > 0 ? this.params.deviceId : this.params.addressText;
    const saved = await this.favorite.execute(new BluetoothDevice(draft), this.params.displayName, 'ble');
    this.message = saved.success ? '' : (saved.error?.message ?? '');
  }

  private async pairFromBle(): Promise<void> {
    const paired = await this.bridgePair.execute(this.params.deviceId, this.params.displayName);
    this.message = paired.success ? '' : (paired.error?.message ?? '');
  }

  private async openSettings(): Promise<void> {
    const context = AbilityContextRegistry.getInstance().get();
    if (context !== undefined) {
      await BluetoothSettingsNavigator.openBluetoothSettings(context);
    }
  }
}
