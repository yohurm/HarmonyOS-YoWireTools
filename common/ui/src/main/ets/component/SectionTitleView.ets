import { UiColorToken } from '../theme/UiColorToken';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
import { UiResourceUtil } from '../util/UiResourceUtil';

@ComponentV2
export struct SectionTitleView {
  @Param title: ResourceStr = '';
  @Param subtitle: ResourceStr = '';
  @Param actionLabel: ResourceStr = '';
  @Event onAction: () => void = () => {
  };

  build() {
    Row() {
      Column({ space: UiSpacing.LABEL_STACK_GAP }) {
        Text(this.title)
          .fontSize(UiTypography.SUBTITLE_SIZE)
          .fontWeight(FontWeight.Medium)
          .fontColor(UiColorToken.TEXT_PRIMARY)
          .width('100%')
        if (UiResourceUtil.hasText(this.subtitle)) {
          Text(this.subtitle)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.TEXT_TERTIARY)
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      if (UiResourceUtil.hasText(this.actionLabel)) {
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
