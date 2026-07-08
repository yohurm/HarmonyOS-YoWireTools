import { LoadingStateModel } from '../model/LoadingStateModel';
import { UiColorToken } from '../theme/UiColorToken';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';

@ComponentV2
export struct LoadingStateView {
  @Param model: LoadingStateModel = new LoadingStateModel();

  build() {
    Column({ space: UiSpacing.SECTION_GAP }) {
      if (this.model.showProgress) {
        LoadingProgress()
          .width(UiSpacing.LOADING_SIZE)
          .height(UiSpacing.LOADING_SIZE)
          .color(UiColorToken.PRIMARY)
      }
      Text(this.model.message)
        .fontSize(UiTypography.BODY_SIZE)
        .fontColor(UiColorToken.TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
    }
    .width('100%')
    .height('100%')
    .padding(UiSpacing.PAGE_PADDING)
    .justifyContent(FlexAlign.Center)
  }
}
