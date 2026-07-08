import {
  StatusPillView,
  UiColorToken,
  UiLayoutConstants,
  UiSpacing,
  UiTypography,
  YoNavDestinationKind,
  YoPageShell
} from 'common_ui';
import { BleMainViewModel } from '../../viewmodel/BleMainViewModel';

@ComponentV2
export struct BleMainPage {
  @Event onBack: () => void = () => {
  };
  @Local private vm: BleMainViewModel = new BleMainViewModel();

  aboutToAppear(): void {
    void this.vm.onPageAppear();
  }

  @LocalBuilder
  pageContent() {
    Column({ space: UiSpacing.SECTION_GAP }) {
      this.summaryCard()
    }
    .width('100%')
    .height('100%')
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_ble_page_title'),
      showBack: true,
      destinationKind: YoNavDestinationKind.MODULE,
      scrollable: false,
      immersiveTitleBar: true,
      onBack: this.onBack,
      content: this.pageContent
    })
  }

  @Builder
  private summaryCard() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      Row() {
        Text($r('app.string.bt_ble_page_title'))
          .fontSize(UiTypography.SUBTITLE_SIZE)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiColorToken.TEXT_PRIMARY)
          .layoutWeight(1)
        StatusPillView({
          label: this.vm.ready ? $r('app.string.bt_entry_status_ready') : $r('app.string.bt_entry_status_blocked'),
          tone: this.vm.ready ? 'success' : 'warning'
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      Row({ space: UiSpacing.CARD_GAP }) {
        this.metric($r('app.string.bt_ble_metric_devices'), this.vm.discoveredDeviceCount)
        this.metric($r('app.string.bt_metric_sessions'), this.vm.activeSessionCount)
      }
      .width('100%')
    }
    .width('100%')
    .padding(UiSpacing.CARD_INNER_PADDING)
    .backgroundColor(UiColorToken.SURFACE)
    .borderRadius(UiLayoutConstants.CARD_RADIUS_SMALL)
  }

  @Builder
  private metric(label: ResourceStr, value: number) {
    Column({ space: UiSpacing.LABEL_STACK_GAP }) {
      Text(`${value}`)
        .fontSize(UiTypography.TITLE_SIZE)
        .fontWeight(FontWeight.Medium)
        .fontColor(UiColorToken.TEXT_PRIMARY)
      Text(label)
        .fontSize(UiTypography.CAPTION_SIZE)
        .fontColor(UiColorToken.TEXT_TERTIARY)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }
}
