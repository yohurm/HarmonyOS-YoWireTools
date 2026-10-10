import {
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { NearLinkOverviewViewModel } from '../../viewmodel/NearLinkOverviewViewModel';

@ComponentV2
export struct NearLinkFeaturePage {
  @Local private vm: NearLinkOverviewViewModel = new NearLinkOverviewViewModel();

  aboutToAppear(): void {
    this.vm.load();
  }

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.L }) {
      if (this.vm.unpairRefusalVisible) {
        Text($r('app.string.nl_unpair_refusal_body'))
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontWeight(YoTypeStyle.BODY_M.weight)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
        Button($r('app.string.nl_unpair_open_settings'), {
          type: ButtonType.Normal,
          buttonStyle: ButtonStyleMode.TEXTUAL,
          role: ButtonRole.NORMAL
        })
          .fontSize(YoTypeStyle.BODY_M.size)
          .onClick(() => {
            void this.vm.openSystemSettings();
          })
      }
      if (this.vm.cdsmUnsupportedVisible) {
        Text($r('app.string.nl_cdsm_unsupported'))
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontWeight(YoTypeStyle.BODY_M.weight)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
    .padding({
      left: YoSpace.XL,
      right: YoSpace.XL,
      top: YoSpace.L
    })
  }

  build() {
    YoPageShell({
      title: $r('app.string.nl_title_overview'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: this.pageContent
    })
  }
}
