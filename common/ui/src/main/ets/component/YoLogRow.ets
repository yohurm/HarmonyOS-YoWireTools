import { TerminalToken } from '../token/component/TerminalToken';
import { CardToken } from '../token/component/CardToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSize } from '../token/foundation/UiSize';
import { UiResponsive } from '../token/semantic/UiResponsive';

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
    Row({ space: UiResponsive.CONTROL_GAP }) {
      Column({ space: UiResponsive.LABEL_STACK_GAP }) {
        Text(this.directionLabel)
          .fontSize(UiTypeStyle.MONO_S.size)
          .fontWeight(UiTypeStyle.SUBTITLE_S.weight)
          .fontColor(this.directionInbound ? TerminalToken.INBOUND : TerminalToken.OUTBOUND)
          .fontFamily(UiTypeStyle.MONO_S.family)
        Text(this.timeLabel)
          .fontSize(UiTypeStyle.MONO_S.size)
          .fontColor(UiColor.TEXT_TERTIARY)
          .fontFamily(UiTypeStyle.MONO_S.family)
      }
      .width(TerminalToken.LOG_ROW_DIRECTION_WIDTH)
      .alignItems(HorizontalAlign.Start)
      Column({ space: UiResponsive.LABEL_STACK_GAP }) {
        Text(`${this.moduleLabel} · ${this.protocolLabel}`)
          .fontSize(UiTypeStyle.MONO_S.size)
          .fontColor(UiColor.TEXT_TERTIARY)
          .fontFamily(UiTypeStyle.MONO_S.family)
          .width('100%')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
        Text(this.summary)
          .fontSize(UiTypeStyle.BODY_M.size)
          .fontColor(this.alert ? UiColor.ERROR : UiColor.TEXT_PRIMARY)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      Text(this.payloadSizeLabel)
        .fontSize(UiTypeStyle.MONO_S.size)
        .fontColor(UiColor.TEXT_TERTIARY)
        .fontFamily(UiTypeStyle.MONO_S.family)
    }
    .width('100%')
    .constraintSize({ minHeight: UiSize.LIST_ROW_HEIGHT })
    .padding({
      left: CardToken.PADDING,
      right: CardToken.PADDING,
      top: UiResponsive.CONTROL_GAP,
      bottom: UiResponsive.CONTROL_GAP
    })
    .backgroundColor(this.selected ? UiColor.INTERACTIVE_PRESSED : Color.Transparent)
    .onClick(() => this.onTap())
  }
}
