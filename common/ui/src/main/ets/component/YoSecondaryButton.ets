import { UiColorToken } from '../theme/UiColorToken';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
@ComponentV2
export struct YoSecondaryButton {
  @Param label: string = '';
  @Param isEnabled: boolean = true;
  @Event onTap: () => void = () => {
  };
  build() {
    Button(this.label, { type: ButtonType.Normal })
      .width('100%')
      .height(UiSpacing.BUTTON_HEIGHT)
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(UiColorToken.PRIMARY)
      .backgroundColor(Color.Transparent)
      .border({ width: 1, color: UiColorToken.BORDER })
      .borderRadius(UiSpacing.CORNER_RADIUS)
      .enabled(this.isEnabled)
      .opacity(this.isEnabled ? 1 : 0.4)
      .onClick(() => this.onTap())
  }
}
