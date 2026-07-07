import { UiColorToken } from '../theme/UiColorToken';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
/**
 * @deprecated Use {@link SectionTitleView} instead. Kept for backward-compatible re-exports only.
 * Section title with optional trailing action label.
 */
@ComponentV2
export struct SectionHeaderView {
  @Param title: string = '';
  @Param subtitle: string = '';
  @Param actionLabel: string = '';
  @Event onAction: () => void = () => {
  };
  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(UiTypography.SUBTITLE_SIZE)
          .fontWeight(UiTypography.TITLE_WEIGHT)
          .fontColor(UiColorToken.TEXT_PRIMARY)
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.TEXT_TERTIARY)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      if (this.actionLabel.length > 0) {
        Text(this.actionLabel)
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(UiColorToken.PRIMARY)
          .onClick(() => this.onAction())
      }
    }
    .width('100%')
    .padding({
      left: UiSpacing.PAGE_PADDING,
      right: UiSpacing.PAGE_PADDING,
      top: UiSpacing.SECTION_GAP,
      bottom: UiSpacing.ITEM_GAP
    })
  }
}
