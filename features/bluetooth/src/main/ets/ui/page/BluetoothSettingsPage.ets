import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { BluetoothSettingsViewModel } from '../../viewmodel/BluetoothSettingsViewModel';

@ComponentV2
export struct BluetoothSettingsPage {
  @Event onBack: () => void = () => {
  };
  @Local vm: BluetoothSettingsViewModel = new BluetoothSettingsViewModel();

  aboutToAppear(): void {
    void this.vm.refresh();
  }

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.S }) {
      if (this.vm.unread) {
        Text($r('app.string.bt_settings_unread'))
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
      } else {
        Row() {
          Text($r('app.string.bt_settings_autostop'))
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontColor(YoColor.TEXT_PRIMARY)
            .layoutWeight(1)
          YoActionButton({
            label: this.vm.enabled ? $r('app.string.bt_settings_on') : $r('app.string.bt_settings_off'),
            kind: YoActionButtonKind.SECONDARY,
            fullWidth: false,
            compact: true,
            onTap: () => {
              void this.vm.toggle();
            }
          })
        }
        .width('100%')
        .alignItems(VerticalAlign.Center)
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_settings_title'),
      destinationKind: YoNavDestinationKind.MODULE,
      showBack: true,
      scrollable: true,
      onBack: () => {
        this.onBack();
      },
      content: this.pageContent
    })
  }
}
