import { YoErrorStateModel } from '../../model/YoErrorStateModel';
import { YoButtonToken } from '../../token/component/YoButtonToken';
import { YoColor } from '../../token/semantic/YoColor';
import { YoTypeStyle } from '../../token/semantic/YoTypeStyle';
import { YoSpace } from '../../token/foundation/YoSpace';
import { YoResourceUtil } from '../../util/YoResourceUtil';

@ComponentV2
export struct YoError {
  @Param model: YoErrorStateModel = new YoErrorStateModel();
  @Event onRetry: () => void = () => {
  };

  build() {
    Column({ space: YoSpace.M }) {
      Text(this.model.userMessage)
        .fontSize(YoTypeStyle.SUBTITLE_M.size)
        .fontWeight(YoTypeStyle.SUBTITLE_M.weight)
        .fontColor(YoColor.ERROR)
        .textAlign(TextAlign.Center)
      if (YoResourceUtil.hasText(this.model.causeHint)) {
        Text(this.model.causeHint)
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .textAlign(TextAlign.Center)
      }
      if (YoResourceUtil.hasText(this.model.nextStep)) {
        Text(this.model.nextStep)
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_PRIMARY)
          .textAlign(TextAlign.Center)
          .margin({ top: YoSpace.M })
      }
      if (this.model.appCode.length > 0 || this.model.nativeCode.length > 0) {
        Text(this.buildCodeLine())
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_TERTIARY)
          .textAlign(TextAlign.Center)
          .margin({ top: YoSpace.M })
      }
      if (this.model.retryable) {
        Button(this.model.actionLabel)
          .height(YoButtonToken.HEIGHT)
          .borderRadius(YoButtonToken.RADIUS)
          .margin({ top: YoSpace.XL })
          .onClick(() => this.onRetry())
      }
    }
    .width('100%')
    .padding(YoSpace.XL)
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
