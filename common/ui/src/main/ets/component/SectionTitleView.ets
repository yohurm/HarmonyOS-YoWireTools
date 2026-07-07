import { UiColorToken } from '../theme/UiColorToken';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
/**
 * Section title row per HarmonyOS subtitle pattern.
 */
@ComponentV2
export struct SectionTitleView {
  @Param title: string = '';
  @Param subtitle: string = '';
  @Param actionLabel: string = '';
  @Event onAction: () => void = () => {
  };
  build() {
    Row() {
      Column({ space: 2 }) {
        Text(this.title)
          .fontSize(UiTypography.SUBTITLE_SIZE)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiColorToken.TEXT_PRIMARY)
          .width('100%')
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.TEXT_TERTIARY)
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      if (this.actionLabel.length > 0) {
        Button(this.actionLabel)
          .type(ButtonType.Normal)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.PRIMARY)
          .backgroundColor(Color.Transparent)
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
