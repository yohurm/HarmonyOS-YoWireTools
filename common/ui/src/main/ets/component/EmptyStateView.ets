import { EmptyStateModel } from '../model/EmptyStateModel';
import { UiColorToken } from '../theme/UiColorToken';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
/**
 * Full-page or inline empty state with reason explanation.
 */
@ComponentV2
export struct EmptyStateView {
  @Param model: EmptyStateModel = new EmptyStateModel();
  @Event onPrimaryAction: () => void = () => {
  };
  @Event onSecondaryAction: () => void = () => {
  };
  build() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      Text(this.model.title.length > 0 ? this.model.title : $r('app.string.ui_empty_default_title'))
        .fontSize(UiTypography.SUBTITLE_SIZE)
        .fontWeight(UiTypography.TITLE_WEIGHT)
        .fontColor(UiColorToken.TEXT_PRIMARY)
        .textAlign(TextAlign.Center)
      Text(this.model.message.length > 0 ? this.model.message : $r('app.string.ui_empty_default_message'))
        .fontSize(UiTypography.BODY_SIZE)
        .fontColor(UiColorToken.TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
      if (this.model.reasonHint.length > 0) {
        Text(this.model.reasonHint)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_TERTIARY)
          .textAlign(TextAlign.Center)
          .margin({ top: UiSpacing.ITEM_GAP })
      }
      if (this.model.actionLabel.length > 0) {
        Button(this.model.actionLabel)
          .height(UiSpacing.BUTTON_HEIGHT)
          .margin({ top: UiSpacing.SECTION_GAP })
          .onClick(() => this.onPrimaryAction())
      }
      if (this.model.secondaryActionLabel.length > 0) {
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
