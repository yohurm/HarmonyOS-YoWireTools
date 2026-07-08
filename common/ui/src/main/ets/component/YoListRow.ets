import { UiResourceUtil } from '../util/UiResourceUtil';
import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
/**
 * Standard list row: title, subtitle, meta, trailing status/chevron.
 */
@ComponentV2
export struct YoListRow {
  @Param title: ResourceStr = '';
  @Param subtitle: ResourceStr = '';
  @Param meta: ResourceStr = '';
  @Param trailing: ResourceStr = '';
  @Param showChevron: boolean = false;
  @Param selected: boolean = false;
  @Param disabled: boolean = false;
  @Param alert: boolean = false;
  @Event onTap: () => void = () => {
  };
  build() {
    Row({ space: UiSpacing.ITEM_GAP }) {
      Column({ space: UiSpacing.LABEL_STACK_GAP }) {
        Text(this.title)
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(this.disabled ? UiColorToken.TEXT_TERTIARY : UiColorToken.TEXT_PRIMARY)
          .fontWeight(FontWeight.Medium)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (UiResourceUtil.hasText(this.subtitle)) {
          Text(this.subtitle)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.TEXT_SECONDARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        if (UiResourceUtil.hasText(this.meta)) {
          Text(this.meta)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.TEXT_TERTIARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      if (UiResourceUtil.hasText(this.trailing)) {
        Text(this.trailing)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(this.alert ? UiColorToken.ERROR : UiColorToken.TEXT_TERTIARY)
          .maxLines(1)
      }
      if (this.showChevron) {
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(UiLayoutConstants.CHEVRON_GLYPH_SIZE)
          .fontColor([UiColorToken.TEXT_TERTIARY])
      }
    }
    .width('100%')
    .constraintSize({ minHeight: UiLayoutConstants.LIST_ROW_HEIGHT })
    .padding({
      left: UiSpacing.CARD_INNER_PADDING,
      right: UiSpacing.CARD_INNER_PADDING,
      top: UiSpacing.ITEM_GAP,
      bottom: UiSpacing.ITEM_GAP
    })
    .backgroundColor(this.selected ? UiColorToken.INTERACTIVE_PRESSED : UiColorToken.SURFACE)
    .borderRadius(UiLayoutConstants.CARD_RADIUS_SMALL)
    .opacity(this.disabled ? 0.5 : 1)
    .onClick(() => {
      if (!this.disabled) {
        this.onTap();
      }
    })
  }
}
