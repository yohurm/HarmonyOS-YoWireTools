import { LoadingStateModel } from '../model/LoadingStateModel';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSize } from '../token/foundation/UiSize';
import { UiSpace } from '../token/foundation/UiSpace';

@ComponentV2
export struct LoadingStateView {
  @Param model: LoadingStateModel = new LoadingStateModel();

  build() {
    Column({ space: UiSpace.XL }) {
      if (this.model.showProgress) {
        LoadingProgress()
          .width(UiSize.LOADING_M)
          .height(UiSize.LOADING_M)
          .color(UiColor.BRAND_PRIMARY)
      }
      Text(this.model.message)
        .fontSize(UiTypeStyle.BODY_M.size)
        .fontColor(UiColor.TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding(UiSpace.XL)
    .justifyContent(FlexAlign.Center)
  }
}
