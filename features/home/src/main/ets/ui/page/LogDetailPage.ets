import {
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';

@ComponentV2
export struct LogDetailPage {
  @Param recordId: string = '';
  @Param module: string = '';
  @Param protocol: string = '';
  @Param summary: string = '';
  @Param direction: string = '';
  @Param timestampMs: number = 0;
  @Event onBack: () => void = () => {
  };

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.M }) {
      this.field($r('app.string.log_filter_all'), this.module)
      this.field($r('app.string.log_detail_protocol'), this.protocol)
      this.field($r('app.string.log_detail_direction'), this.direction)
      this.field($r('app.string.log_detail_summary'), this.summary)
      this.field($r('app.string.log_detail_time'), `${this.timestampMs}`)
      this.field($r('app.string.log_detail_hex'), $r('app.string.log_hex_missing'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  field(label: ResourceStr, value: ResourceStr) {
    Column({ space: YoSpace.XS }) {
      Text(label)
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      Text(value)
        .fontSize(YoTypeStyle.BODY_M.size)
        .fontColor(YoColor.TEXT_PRIMARY)
        .width('100%')
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.log_detail_title'),
      destinationKind: YoNavDestinationKind.OBJECT,
      showBack: true,
      scrollable: true,
      onBack: () => {
        this.onBack();
      },
      content: this.pageContent
    })
  }
}
