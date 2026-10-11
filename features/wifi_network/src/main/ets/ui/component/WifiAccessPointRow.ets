import { YoCardToken, YoColor, YoListToken, YoSpace, YoTypeStyle } from 'youi_kit';

@ComponentV2
export struct WifiAccessPointRow {
  @Param ssid: string = '';
  @Param channel: number = 0;
  @Param securityType: string = '';
  @Param rssi: number = 0;
  @Param showDivider: boolean = false;

  build() {
    Column() {
      Row({ space: YoSpace.M }) {
        Column({ space: YoSpace.XS }) {
          if (this.ssid.length > 0) {
            Text(this.ssid)
              .fontSize(YoTypeStyle.SUBTITLE_S.size)
              .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
              .fontColor(YoColor.TEXT_PRIMARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          } else {
            Text($r('app.string.wifi_ap_hidden'))
              .fontSize(YoTypeStyle.SUBTITLE_S.size)
              .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
              .fontColor(YoColor.TEXT_PRIMARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .width('100%')
          }
          Row({ space: YoSpace.M }) {
            if (this.channel > 0) {
              Text($r('app.string.wifi_label_channel'))
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(YoColor.TEXT_TERTIARY)
              Text(`${this.channel}`)
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(YoColor.TEXT_SECONDARY)
            }
            if (this.securityType.length > 0) {
              Text(this.securityType)
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(YoColor.TEXT_SECONDARY)
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
                .layoutWeight(1)
            }
          }
          .width('100%')
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start)
        Column({ space: YoSpace.XXS }) {
          Text($r('app.string.wifi_label_rssi'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
          Text(`${this.rssi}`)
            .fontSize(YoTypeStyle.SUBTITLE_S.size)
            .fontColor(YoColor.TEXT_PRIMARY)
        }
        .alignItems(HorizontalAlign.End)
      }
      .width('100%')
      .constraintSize({ minHeight: YoCardToken.HEIGHT_DEVICE_ROW })
      .padding({
        left: YoCardToken.PADDING_COMPACT,
        right: YoCardToken.PADDING_COMPACT,
        top: YoCardToken.PADDING_ROW_V,
        bottom: YoCardToken.PADDING_ROW_V
      })
      .alignItems(VerticalAlign.Center)
      if (this.showDivider) {
        Divider()
          .strokeWidth(YoListToken.DIVIDER_STROKE)
          .color(YoColor.BORDER_PRIMARY)
          .margin({ left: YoCardToken.PADDING_COMPACT })
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
