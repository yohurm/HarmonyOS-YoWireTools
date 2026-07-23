import { YoLoadingStateModel } from '../../model/YoLoadingStateModel';
import { YoColor } from '../../token/semantic/YoColor';
import { YoTypeStyle } from '../../token/semantic/YoTypeStyle';
import { YoSize } from '../../token/foundation/YoSize';
import { YoSpace } from '../../token/foundation/YoSpace';

@ComponentV2
export struct YoLoading {
  @Param model: YoLoadingStateModel = new YoLoadingStateModel();

  build() {
    Column({ space: YoSpace.XL }) {
      if (this.model.showProgress) {
        LoadingProgress()
          .width(YoSize.LOADING_M)
          .height(YoSize.LOADING_M)
          .color(YoColor.BRAND_PRIMARY)
      }
      Text(this.model.message)
        .fontSize(YoTypeStyle.BODY_M.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding(YoSpace.XL)
    .justifyContent(FlexAlign.Center)
  }
}
