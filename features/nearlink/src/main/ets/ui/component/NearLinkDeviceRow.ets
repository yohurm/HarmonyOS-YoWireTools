import { YoCardToken, YoColor, YoListToken, YoSpace, YoStatusPill, YoTypeStyle } from 'youi_kit';

@ComponentV2
export struct NearLinkDeviceRow {
  @Param displayName: string = '';
  @Param address: string = '';
  @Param rssi: number = 0;
  @Param rssiValid: boolean = false;
  @Param connectable: boolean = false;
  @Param favorite: boolean = false;
  @Param showDivider: boolean = false;

  build() {
    Column() {
      Column({ space: YoSpace.XS }) {
        Row({ space: YoSpace.S }) {
          if (this.displayName.length > 0) {
            Text(this.displayName)
              .fontSize(YoTypeStyle.SUBTITLE_S.size)
              .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
              .fontColor(YoColor.TEXT_PRIMARY)
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .layoutWeight(1)
          } else {
            Text($r('app.string.nl_device_unnamed'))
              .fontSize(YoTypeStyle.SUBTITLE_S.size)
              .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
              .fontColor(YoColor.TEXT_PRIMARY)
              .maxLines(1)
              .layoutWeight(1)
          }
          if (this.favorite) {
            YoStatusPill({ label: $r('app.string.nl_device_favorite'), tone: 'brand' })
          }
        }
        .width('100%')
        Text(this.address)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        Row({ space: YoSpace.M }) {
          Text($r('app.string.nl_label_rssi'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_TERTIARY)
          if (this.rssiValid) {
            Text(`${this.rssi}`)
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_SECONDARY)
          } else {
            Text($r('app.string.nl_device_rssi_unknown'))
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_TERTIARY)
          }
          YoStatusPill({
            label: this.connectable ?
              $r('app.string.nl_device_connectable') : $r('app.string.nl_device_not_connectable'),
            tone: this.connectable ? 'success' : 'neutral'
          })
        }
        .width('100%')
      }
      .width('100%')
      .constraintSize({ minHeight: YoCardToken.HEIGHT_DEVICE_ROW })
      .padding({
        left: YoCardToken.PADDING_COMPACT,
        right: YoCardToken.PADDING_COMPACT,
        top: YoCardToken.PADDING_ROW_V,
        bottom: YoCardToken.PADDING_ROW_V
      })
      .alignItems(HorizontalAlign.Start)
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
