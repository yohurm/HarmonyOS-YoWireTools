import { SegmentChipView } from './SegmentChipView';
import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
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
    Column({ space: UiSpacing.ITEM_GAP }) {
      Row({ space: UiSpacing.ITEM_GAP }) {
        SegmentChipView({
          label: '文本',
          selected: !this.showHex,
          onSelect: () => this.onToggleHex(false)
        })
        SegmentChipView({
          label: 'Hex',
          selected: this.showHex,
          onSelect: () => this.onToggleHex(true)
        })
      }
      .width('100%')
      Scroll() {
        Text(this.showHex ? this.hexPayload : this.textPayload)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_SECONDARY)
          .fontFamily(UiTypography.MONO_FONT_FAMILY)
          .width('100%')
      }
      .width('100%')
      .constraintSize({ minHeight: UiLayoutConstants.TERMINAL_MIN_HEIGHT })
      .scrollBar(BarState.Auto)
      .backgroundColor(UiColorToken.TERMINAL_BACKGROUND)
      .borderRadius(UiLayoutConstants.CARD_RADIUS)
      .padding(UiSpacing.ITEM_GAP)
    }
    .width('100%')
  }
}
