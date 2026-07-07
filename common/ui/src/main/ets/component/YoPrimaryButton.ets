import { UiColorToken } from '../theme/UiColorToken';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
/** @Param names avoid ArkUI built-in `enabled` / `onClick` reserved by CustomComponent. */
@ComponentV2
export struct YoPrimaryButton {
  @Param label: string = '';
  @Param isEnabled: boolean = true;
  @Param loading: boolean = false;
  @Event onTap: () => void = () => {
  };
  build() {
    Button(this.label, { type: ButtonType.Normal })
      .width('100%')
      .height(UiSpacing.BUTTON_HEIGHT)
      .borderRadius(UiSpacing.CORNER_RADIUS)
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(Color.White)
      .backgroundColor(UiColorToken.PRIMARY)
      .enabled(this.isEnabled && !this.loading)
      .opacity(this.isEnabled ? 1 : 0.4)
      .onClick(() => this.onTap())
  }
}
