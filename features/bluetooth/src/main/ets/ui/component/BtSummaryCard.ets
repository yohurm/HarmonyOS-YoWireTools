import {
  YoCardToken,
  YoStatusPill,
  YoColor,
  YoResponsive,
  YoTypeStyle
} from 'youi_kit';

@ComponentV2
export struct BtSummaryCard {
  @Param title: ResourceStr = '';
  @Param ready: boolean = false;
  @Param primaryMetricLabel: ResourceStr = '';
  @Param primaryMetricValue: number = 0;
  @Param sessionMetricLabel: ResourceStr = $r('app.string.bt_metric_sessions');
  @Param sessionMetricValue: number = 0;

  build() {
    Column({ space: YoResponsive.CONTROL_GAP }) {
      Row() {
        Text(this.title)
          .fontSize(YoTypeStyle.SUBTITLE_M.size)
          .fontWeight(YoTypeStyle.SUBTITLE_M.weight)
          .fontColor(YoColor.TEXT_PRIMARY)
          .layoutWeight(1)
        YoStatusPill({
          label: this.ready ? $r('app.string.bt_entry_status_ready') : $r('app.string.bt_entry_status_blocked'),
          tone: this.ready ? 'success' : 'warning'
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      Row({ space: YoResponsive.CARD_GAP }) {
        this.metric(this.primaryMetricLabel, this.primaryMetricValue)
        this.metric(this.sessionMetricLabel, this.sessionMetricValue)
      }
      .width('100%')
    }
    .width('100%')
    .padding(YoCardToken.PADDING_COMPACT)
    .backgroundColor(YoCardToken.BACKGROUND)
    .borderRadius(YoCardToken.RADIUS)
  }

  @Builder
  private metric(label: ResourceStr, value: number) {
    Column({ space: YoResponsive.LABEL_STACK_GAP }) {
      Text(`${value}`)
        .fontSize(YoTypeStyle.TITLE_S.size)
        .fontWeight(YoTypeStyle.TITLE_S.weight)
        .fontColor(YoColor.TEXT_PRIMARY)
      Text(label)
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_TERTIARY)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }
}
