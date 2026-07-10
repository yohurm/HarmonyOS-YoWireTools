import { SegmentChipView } from './SegmentChipView';
import { TerminalToken } from '../token/component/TerminalToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSpace } from '../token/foundation/UiSpace';

/**
 * Log / packet payload viewer with text vs hex toggle (design 06 PayloadViewer).
 */
@ComponentV2
export struct PayloadViewerView {
  @Param textPayload: string = '';
  @Param hexPayload: string = '';
  @Param showHex: boolean = false;
  @Event onToggleHex: (showHex: boolean) => void = (_showHex: boolean) => {
  };

  build() {
    Column({ space: UiSpace.M }) {
      Row({ space: UiSpace.M }) {
        SegmentChipView({
          label: $r('app.string.ui_payload_text'),
          selected: !this.showHex,
          onSelect: () => this.onToggleHex(false)
        })
        SegmentChipView({
          label: $r('app.string.ui_payload_hex'),
          selected: this.showHex,
          onSelect: () => this.onToggleHex(true)
        })
      }
      .width('100%')
      Scroll() {
        Text(this.showHex ? this.hexPayload : this.textPayload)
          .fontSize(UiTypeStyle.MONO_S.size)
          .fontColor(UiColor.TEXT_SECONDARY)
          .fontFamily(UiTypeStyle.MONO_S.family)
          .width('100%')
      }
      .width('100%')
      .constraintSize({ minHeight: TerminalToken.MIN_HEIGHT })
      .scrollBar(BarState.Auto)
      .backgroundColor(TerminalToken.BACKGROUND)
      .borderRadius(TerminalToken.RADIUS)
      .padding(UiSpace.M)
    }
    .width('100%')
  }
}
