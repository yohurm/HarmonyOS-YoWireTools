import { PermissionUiState } from 'common_platform';
import { YoButtonToken } from '../../token/component/YoButtonToken';
import { YoColor } from '../../token/semantic/YoColor';
import { YoTypeStyle } from '../../token/semantic/YoTypeStyle';
import { YoSpace } from '../../token/foundation/YoSpace';
import { YoResourceUtil } from '../../util/YoResourceUtil';

@ComponentV2
export struct YoPermissionDenied {
  @Param state: PermissionUiState | undefined = undefined;
  @Event onRequestPermission: () => void = () => {
  };
  @Event onOpenSettings: () => void = () => {
  };

  build() {
    Column({ space: YoSpace.M }) {
      Text(this.state?.title ?? $r('app.string.youi_error_default_title'))
        .fontSize(YoTypeStyle.SUBTITLE_M.size)
        .fontWeight(YoTypeStyle.SUBTITLE_M.weight)
        .fontColor(YoColor.WARNING)
        .textAlign(TextAlign.Center)
      Text(this.state?.message ?? $r('app.string.youi_empty_default_message'))
        .fontSize(YoTypeStyle.BODY_M.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
      if (this.state !== undefined && YoResourceUtil.hasText(this.state.userAction)) {
        Text(this.state.userAction)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_TERTIARY)
          .textAlign(TextAlign.Center)
          .margin({ top: YoSpace.M })
      }
      if (this.state?.canRequest === true) {
        Button($r('app.string.youi_grant_permission'))
          .height(YoButtonToken.HEIGHT)
          .borderRadius(YoButtonToken.RADIUS)
          .margin({ top: YoSpace.XL })
          .onClick(() => this.onRequestPermission())
      }
      if (this.state?.shouldShowSettingGuide === true) {
        Button($r('app.string.youi_open_settings'))
          .height(YoButtonToken.HEIGHT)
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor(YoColor.BRAND_PRIMARY)
          .onClick(() => this.onOpenSettings())
      }
    }
    .width('100%')
    .padding(YoSpace.XL)
    .justifyContent(FlexAlign.Center)
  }
}
