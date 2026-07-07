import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
@ComponentV2
export struct YoSwitchRow {
  @Param title: string = '';
  @Param subtitle: string = '';
  @Param checked: boolean = false;
  @Param isEnabled: boolean = true;
  @Event onCheckedChange: (checked: boolean) => void = () => {
  };
  build() {
    Row() {
      Column({ space: 4 }) {
        Text(this.title)
          .fontSize(UiTypography.BODY_SIZE)
          .fontColor(UiColorToken.TEXT_PRIMARY)
        if (this.subtitle.length > 0) {
          Text(this.subtitle)
            .fontSize(UiTypography.CAPTION_SIZE)
            .fontColor(UiColorToken.TEXT_TERTIARY)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: this.checked })
        .enabled(this.isEnabled)
        .onChange((isOn: boolean) => this.onCheckedChange(isOn))
    }
    .width('100%')
    .constraintSize({ minHeight: UiLayoutConstants.LIST_ROW_HEIGHT })
    .padding({
      left: UiSpacing.PAGE_PADDING,
      right: UiSpacing.PAGE_PADDING,
      top: UiSpacing.ITEM_GAP,
      bottom: UiSpacing.ITEM_GAP
    })
    .backgroundColor(UiColorToken.SURFACE)
    .borderRadius(UiSpacing.CORNER_RADIUS)
  }
}
