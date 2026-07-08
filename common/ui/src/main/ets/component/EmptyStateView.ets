import { EmptyStateModel } from '../model/EmptyStateModel';
import { UiColorToken } from '../theme/UiColorToken';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
import { UiResourceUtil } from '../util/UiResourceUtil';

@ComponentV2
export struct EmptyStateView {
  @Param model: EmptyStateModel = new EmptyStateModel();
  @Event onPrimaryAction: () => void = () => {
  };
  @Event onSecondaryAction: () => void = () => {
  };

  build() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      Text(this.model.title)
        .fontSize(UiTypography.SUBTITLE_SIZE)
        .fontWeight(UiTypography.TITLE_WEIGHT)
        .fontColor(UiColorToken.TEXT_PRIMARY)
        .textAlign(TextAlign.Center)
      Text(this.model.message)
        .fontSize(UiTypography.BODY_SIZE)
        .fontColor(UiColorToken.TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
      if (UiResourceUtil.hasText(this.model.reasonHint)) {
        Text(this.model.reasonHint)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_TERTIARY)
          .textAlign(TextAlign.Center)
          .margin({ top: UiSpacing.ITEM_GAP })
      }
      if (UiResourceUtil.hasText(this.model.actionLabel)) {
        Button(this.model.actionLabel)
          .height(UiSpacing.BUTTON_HEIGHT)
          .margin({ top: UiSpacing.SECTION_GAP })
          .onClick(() => this.onPrimaryAction())
      }
      if (UiResourceUtil.hasText(this.model.secondaryActionLabel)) {
        Button(this.model.secondaryActionLabel)
          .height(UiSpacing.BUTTON_HEIGHT)
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor(UiColorToken.PRIMARY)
          .onClick(() => this.onSecondaryAction())
      }
    }
    .width('100%')
    .padding(UiSpacing.PAGE_PADDING)
    .justifyContent(FlexAlign.Center)
  }
}
