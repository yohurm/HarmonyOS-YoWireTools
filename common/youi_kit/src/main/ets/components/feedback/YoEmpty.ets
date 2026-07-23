import { YoEmptyStateModel } from '../../model/YoEmptyStateModel';
import { YoButtonToken } from '../../token/component/YoButtonToken';
import { YoColor } from '../../token/semantic/YoColor';
import { YoTypeStyle } from '../../token/semantic/YoTypeStyle';
import { YoSpace } from '../../token/foundation/YoSpace';
import { YoResourceUtil } from '../../util/YoResourceUtil';

@ComponentV2
export struct YoEmpty {
  @Param model: YoEmptyStateModel = new YoEmptyStateModel();
  @Event onPrimaryAction: () => void = () => {
  };
  @Event onSecondaryAction: () => void = () => {
  };

  build() {
    Column({ space: YoSpace.M }) {
      Text(this.model.title)
        .fontSize(YoTypeStyle.SUBTITLE_M.size)
        .fontWeight(YoTypeStyle.SUBTITLE_M.weight)
        .fontColor(YoColor.TEXT_PRIMARY)
        .textAlign(TextAlign.Center)
      Text(this.model.message)
        .fontSize(YoTypeStyle.BODY_M.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
      if (YoResourceUtil.hasText(this.model.reasonHint)) {
        Text(this.model.reasonHint)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_TERTIARY)
          .textAlign(TextAlign.Center)
          .margin({ top: YoSpace.M })
      }
      if (YoResourceUtil.hasText(this.model.actionLabel)) {
        Button(this.model.actionLabel)
          .height(YoButtonToken.HEIGHT)
          .borderRadius(YoButtonToken.RADIUS)
          .margin({ top: YoSpace.XL })
          .onClick(() => this.onPrimaryAction())
      }
      if (YoResourceUtil.hasText(this.model.secondaryActionLabel)) {
        Button(this.model.secondaryActionLabel)
          .height(YoButtonToken.HEIGHT)
          .type(ButtonType.Normal)
          .borderRadius(YoButtonToken.RADIUS)
          .backgroundColor(Color.Transparent)
          .fontColor(YoColor.BRAND_PRIMARY)
          .onClick(() => this.onSecondaryAction())
      }
    }
    .width('100%')
    .padding(YoSpace.XL)
    .justifyContent(FlexAlign.Center)
  }
}
