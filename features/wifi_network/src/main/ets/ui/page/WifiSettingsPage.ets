import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { WifiSettingsViewModel } from '../../viewmodel/WifiSettingsViewModel';

@ComponentV2
export struct WifiSettingsPage {
  @Event onBack: () => void = () => {
  };
  @Local vm: WifiSettingsViewModel = new WifiSettingsViewModel();

  aboutToAppear(): void {
    void this.vm.refresh();
  }

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.S }) {
      if (this.vm.unread) {
        Text($r('app.string.wifi_settings_unread'))
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
      } else {
        Row() {
          Text($r('app.string.wifi_settings_cooldown'))
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontColor(YoColor.TEXT_PRIMARY)
            .layoutWeight(1)
          YoActionButton({
            label: `${this.vm.cooldownMs}`,
            kind: YoActionButtonKind.SECONDARY,
            fullWidth: false,
            compact: true,
            onTap: () => {
              void this.vm.cycle();
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
      title: $r('app.string.wifi_settings_title'),
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