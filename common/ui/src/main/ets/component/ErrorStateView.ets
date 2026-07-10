import { ErrorStateModel } from '../model/ErrorStateModel';
import { ButtonToken } from '../token/component/ButtonToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiResourceUtil } from '../util/UiResourceUtil';

@ComponentV2
export struct ErrorStateView {
  @Param model: ErrorStateModel = new ErrorStateModel();
  @Event onRetry: () => void = () => {
  };

  build() {
    Column({ space: UiSpace.M }) {
      Text(this.model.userMessage)
        .fontSize(UiTypeStyle.SUBTITLE_M.size)
        .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
        .fontColor(UiColor.ERROR)
        .textAlign(TextAlign.Center)
      if (UiResourceUtil.hasText(this.model.causeHint)) {
        Text(this.model.causeHint)
          .fontSize(UiTypeStyle.BODY_M.size)
          .fontColor(UiColor.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
      }
      if (UiResourceUtil.hasText(this.model.nextStep)) {
        Text(this.model.nextStep)
          .fontSize(UiTypeStyle.BODY_M.size)
          .fontColor(UiColor.TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .margin({ top: UiSpace.M })
      }
      if (this.model.appCode.length > 0 || this.model.nativeCode.length > 0) {
        Text(this.buildCodeLine())
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.TEXT_TERTIARY)
          .textAlign(TextAlign.Center)
          .margin({ top: UiSpace.M })
      }
      if (this.model.retryable) {
        Button(this.model.actionLabel)
          .height(ButtonToken.HEIGHT)
          .borderRadius(ButtonToken.RADIUS)
          .margin({ top: UiSpace.XL })
          .onClick(() => this.onRetry())
      }
    }
    .width('100%')
    .padding(UiSpace.XL)
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
