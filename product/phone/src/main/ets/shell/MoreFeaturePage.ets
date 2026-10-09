import {
  YoColor,
  YoModeEntryCard,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { MoreHubViewModel } from './MoreHubViewModel';

@ComponentV2
export struct MoreFeaturePage {
  @Local vm: MoreHubViewModel = new MoreHubViewModel();

  aboutToAppear(): void {
    this.vm.onPageAppear();
  }

  aboutToDisappear(): void {
    this.vm.onPageDisappear();
  }

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.XL }) {
      Text($r('app.string.more_section_system'))
        .fontSize(YoTypeStyle.SUBTITLE_S.size)
        .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      YoModeEntryCard({
        title: $r('app.string.more_entry_bluetooth_settings_title'),
        description: $r('app.string.more_entry_bluetooth_settings_desc'),
        disabled: !this.vm.contextReady,
        disabledReason: $r('app.string.more_settings_unavailable'),
        onTap: () => {
          void this.vm.openBluetoothSettings();
        }
      })
      YoModeEntryCard({
        title: $r('app.string.more_entry_wifi_settings_title'),
        description: $r('app.string.more_entry_wifi_settings_desc'),
        disabled: !this.vm.contextReady,
        disabledReason: $r('app.string.more_settings_unavailable'),
        onTap: () => {
          void this.vm.openWifiSettings();
        }
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.more_hub_title'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      immersiveTitleBar: true,
      content: this.pageContent
    })
  }
}
