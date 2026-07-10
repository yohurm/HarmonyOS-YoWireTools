import { PermissionUiState } from 'common_platform';
import { ButtonToken } from '../token/component/ButtonToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiResourceUtil } from '../util/UiResourceUtil';

@ComponentV2
export struct PermissionDeniedView {
  @Param state: PermissionUiState | undefined = undefined;
  @Event onRequestPermission: () => void = () => {
  };
  @Event onOpenSettings: () => void = () => {
  };

  build() {
    Column({ space: UiSpace.M }) {
      Text(this.state?.title ?? $r('app.string.ui_error_default_title'))
        .fontSize(UiTypeStyle.SUBTITLE_M.size)
        .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
        .fontColor(UiColor.WARNING)
        .textAlign(TextAlign.Center)
      Text(this.state?.message ?? $r('app.string.ui_empty_default_message'))
        .fontSize(UiTypeStyle.BODY_M.size)
        .fontColor(UiColor.TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
      if (this.state !== undefined && UiResourceUtil.hasText(this.state.userAction)) {
        Text(this.state.userAction)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.TEXT_TERTIARY)
          .textAlign(TextAlign.Center)
          .margin({ top: UiSpace.M })
      }
      if (this.state?.canRequest === true) {
        Button($r('app.string.ui_grant_permission'))
          .height(ButtonToken.HEIGHT)
          .borderRadius(ButtonToken.RADIUS)
          .margin({ top: UiSpace.XL })
          .onClick(() => this.onRequestPermission())
      }
      if (this.state?.shouldShowSettingGuide === true) {
        Button($r('app.string.ui_open_settings'))
          .height(ButtonToken.HEIGHT)
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor(UiColor.BRAND_PRIMARY)
          .onClick(() => this.onOpenSettings())
      }
    }
    .width('100%')
    .padding(UiSpace.XL)
    .justifyContent(FlexAlign.Center)
  }
}
