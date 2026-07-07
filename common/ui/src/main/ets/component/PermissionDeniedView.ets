import { PermissionUiState } from 'common_platform';
import { UiColorToken } from '../theme/UiColorToken';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
/**
 * Permission explanation and action view driven by PermissionUiState from platform layer.
 */
@ComponentV2
export struct PermissionDeniedView {
  @Param state: PermissionUiState | undefined = undefined;
  @Event onRequestPermission: () => void = () => {
  };
  @Event onOpenSettings: () => void = () => {
  };
  build() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      Text(this.state?.title ?? 'Permission required')
        .fontSize(UiTypography.SUBTITLE_SIZE)
        .fontWeight(UiTypography.TITLE_WEIGHT)
        .fontColor(UiColorToken.WARNING)
        .textAlign(TextAlign.Center)
      Text(this.state?.message ?? 'Grant the required permission to continue.')
        .fontSize(UiTypography.BODY_SIZE)
        .fontColor(UiColorToken.TEXT_SECONDARY)
        .textAlign(TextAlign.Center)
      if (this.state !== undefined && this.state.userAction.length > 0) {
        Text(this.state.userAction)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_TERTIARY)
          .textAlign(TextAlign.Center)
          .margin({ top: UiSpacing.ITEM_GAP })
      }
      if (this.state?.canRequest === true) {
        Button($r('app.string.ui_grant_permission'))
          .height(UiSpacing.BUTTON_HEIGHT)
          .margin({ top: UiSpacing.SECTION_GAP })
          .onClick(() => this.onRequestPermission())
      }
      if (this.state?.shouldShowSettingGuide === true) {
        Button($r('app.string.ui_open_settings'))
          .height(UiSpacing.BUTTON_HEIGHT)
          .type(ButtonType.Normal)
          .backgroundColor(Color.Transparent)
          .fontColor(UiColorToken.PRIMARY)
          .onClick(() => this.onOpenSettings())
      }
    }
    .width('100%')
    .padding(UiSpacing.PAGE_PADDING)
    .justifyContent(FlexAlign.Center)
  }
}
