import { EmptyStateModel } from '../model/EmptyStateModel';
import { ButtonToken } from '../token/component/ButtonToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiResourceUtil } from '../util/UiResourceUtil';

@ComponentV2
export struct EmptyStateView {
  @Param model: EmptyStateModel = new EmptyStateModel();
  @Event onPrimaryAction: () => void = () => {
  };
  @Event onSecondaryAction: () => void = () => {
  };

  build() {
    Column({ space: UiSpace.M }) {
      Text(this.model.title)
        .fontSize(UiTypeStyle.SUBTITLE_M.size)
        .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
        .fontColor(UiColor.TEXT_PRIMARY)
        .textAlign(TextAlign.Center)
      Text(this.model.message)
        .fontSize(UiTypeStyle.BODY_M.size)
        .fontColor(UiColor.TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
      if (UiResourceUtil.hasText(this.model.reasonHint)) {
        Text(this.model.reasonHint)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.TEXT_TERTIARY)
          .textAlign(TextAlign.Center)
          .margin({ top: UiSpace.M })
      }
      if (UiResourceUtil.hasText(this.model.actionLabel)) {
        Button(this.model.actionLabel)
          .height(ButtonToken.HEIGHT)
          .borderRadius(ButtonToken.RADIUS)
          .margin({ top: UiSpace.XL })
          .onClick(() => this.onPrimaryAction())
      }
      if (UiResourceUtil.hasText(this.model.secondaryActionLabel)) {
        Button(this.model.secondaryActionLabel)
          .height(ButtonToken.HEIGHT)
          .type(ButtonType.Normal)
          .borderRadius(ButtonToken.RADIUS)
          .backgroundColor(Color.Transparent)
          .fontColor(UiColor.BRAND_PRIMARY)
          .onClick(() => this.onSecondaryAction())
      }
    }
    .width('100%')
    .padding(UiSpace.XL)
    .justifyContent(FlexAlign.Center)
  }
}
