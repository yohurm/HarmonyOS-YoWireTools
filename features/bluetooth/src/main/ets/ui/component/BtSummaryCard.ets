import {
  CardToken,
  StatusPillView,
  UiColor,
  UiResponsive,
  UiTypeStyle
} from 'common_ui';

@ComponentV2
export struct BtSummaryCard {
  @Param title: ResourceStr = '';
  @Param ready: boolean = false;
  @Param primaryMetricLabel: ResourceStr = '';
  @Param primaryMetricValue: number = 0;
  @Param sessionMetricLabel: ResourceStr = $r('app.string.bt_metric_sessions');
  @Param sessionMetricValue: number = 0;

  build() {
    Column({ space: UiResponsive.CONTROL_GAP }) {
      Row() {
        Text(this.title)
          .fontSize(UiTypeStyle.SUBTITLE_M.size)
          .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
          .fontColor(UiColor.TEXT_PRIMARY)
          .layoutWeight(1)
        StatusPillView({
          label: this.ready ? $r('app.string.bt_entry_status_ready') : $r('app.string.bt_entry_status_blocked'),
          tone: this.ready ? 'success' : 'warning'
        })
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
      Row({ space: UiResponsive.CARD_GAP }) {
        this.metric(this.primaryMetricLabel, this.primaryMetricValue)
        this.metric(this.sessionMetricLabel, this.sessionMetricValue)
      }
      .width('100%')
    }
    .width('100%')
    .padding(CardToken.PADDING)
    .backgroundColor(CardToken.BACKGROUND)
    .borderRadius(CardToken.RADIUS)
  }

  @Builder
  private metric(label: ResourceStr, value: number) {
    Column({ space: UiResponsive.LABEL_STACK_GAP }) {
      Text(`${value}`)
        .fontSize(UiTypeStyle.TITLE_S.size)
        .fontWeight(UiTypeStyle.TITLE_S.weight)
        .fontColor(UiColor.TEXT_PRIMARY)
      Text(label)
        .fontSize(UiTypeStyle.BODY_S.size)
        .fontColor(UiColor.TEXT_TERTIARY)
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }
}
