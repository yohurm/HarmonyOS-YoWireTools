import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
/**
 * V2 log list row: direction, time, module/protocol, summary, payload size, alert flag.
 */
@ComponentV2
export struct YoLogRow {
  @Param directionLabel: string = '';
  @Param directionInbound: boolean = true;
  @Param timeLabel: string = '';
  @Param moduleLabel: string = '';
  @Param protocolLabel: string = '';
  @Param summary: string = '';
  @Param payloadSizeLabel: string = '';
  @Param alert: boolean = false;
  @Param selected: boolean = false;
  @Event onTap: () => void = () => {
  };
  build() {
    Row({ space: UiSpacing.ITEM_GAP }) {
      Column({ space: UiSpacing.LABEL_STACK_GAP }) {
        Text(this.directionLabel)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontWeight(FontWeight.Medium)
          .fontColor(this.directionInbound ? UiColorToken.TERMINAL_INBOUND : UiColorToken.TERMINAL_OUTBOUND)
        Text(this.timeLabel)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_TERTIARY)
      }
      .width(UiLayoutConstants.LOG_ROW_DIRECTION_WIDTH)
      .alignItems(HorizontalAlign.Start)
      Column({ space: UiSpacing.LABEL_STACK_GAP }) {
        Text(`${this.moduleLabel} · ${this.protocolLabel}`)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_TERTIARY)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.summary)
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(this.alert ? UiColorToken.ERROR : UiColorToken.TEXT_PRIMARY)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text(this.payloadSizeLabel)
        .fontSize(UiTypography.CAPTION_SIZE)
        .fontColor(UiColorToken.TEXT_TERTIARY)
    }
    .width('100%')
    .constraintSize({ minHeight: UiLayoutConstants.LIST_ROW_HEIGHT })
    .padding({
      left: UiSpacing.CARD_INNER_PADDING,
      right: UiSpacing.CARD_INNER_PADDING,
      top: UiSpacing.ITEM_GAP,
      bottom: UiSpacing.ITEM_GAP
    })
    .backgroundColor(this.selected ? UiColorToken.INTERACTIVE_PRESSED : Color.Transparent)
    .onClick(() => this.onTap())
  }
}
