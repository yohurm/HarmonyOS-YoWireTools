import { ErrorStateModel } from '../model/ErrorStateModel';
import { UiColorToken } from '../theme/UiColorToken';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
import { UiResourceUtil } from '../util/UiResourceUtil';

@ComponentV2
export struct ErrorStateView {
  @Param model: ErrorStateModel = new ErrorStateModel();
  @Event onRetry: () => void = () => {
  };

  build() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      Text(this.model.userMessage)
        .fontSize(UiTypography.SUBTITLE_SIZE)
        .fontWeight(UiTypography.TITLE_WEIGHT)
        .fontColor(UiColorToken.ERROR)
        .textAlign(TextAlign.Center)
      if (UiResourceUtil.hasText(this.model.causeHint)) {
        Text(this.model.causeHint)
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(UiColorToken.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
      }
      if (UiResourceUtil.hasText(this.model.nextStep)) {
        Text(this.model.nextStep)
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(UiColorToken.TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .margin({ top: UiSpacing.ITEM_GAP })
      }
      if (this.model.appCode.length > 0 || this.model.nativeCode.length > 0) {
        Text(this.buildCodeLine())
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_TERTIARY)
          .textAlign(TextAlign.Center)
          .margin({ top: UiSpacing.ITEM_GAP })
      }
      if (this.model.retryable) {
        Button(this.model.actionLabel)
          .height(UiSpacing.BUTTON_HEIGHT)
          .margin({ top: UiSpacing.SECTION_GAP })
          .onClick(() => this.onRetry())
      }
    }
    .width('100%')
    .padding(UiSpacing.PAGE_PADDING)
    .justifyContent(FlexAlign.Center)
  }

  private buildCodeLine(): string {
    const parts: string[] = [];
    if (this.model.appCode.length > 0) {
      parts.push(this.model.appCode);
    }
    if (this.model.nativeCode.length > 0) {
      parts.push(`native=${this.model.nativeCode}`);
    }
    return parts.join(' · ');
  }
}
