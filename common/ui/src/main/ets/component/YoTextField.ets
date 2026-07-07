import { UiColorToken } from '../theme/UiColorToken';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
@ComponentV2
export struct YoTextField {
  @Param label: string = '';
  @Param value: string = '';
  @Param placeholder: string = '';
  @Param isEnabled: boolean = true;
  @Param maxLength: number = 4096;
  @Event onValueChange: (value: string) => void = () => {
  };
  build() {
    Column({ space: UiSpacing.ITEM_GAP }) {
      if (this.label.length > 0) {
        Text(this.label)
          .fontSize(UiTypography.CAPTION_SIZE)
          .fontColor(UiColorToken.TEXT_SECONDARY)
          .width('100%')
      }
      TextInput({ text: this.value, placeholder: this.placeholder })
        .width('100%')
        .height(UiSpacing.BUTTON_HEIGHT)
        .maxLength(this.maxLength)
        .enabled(this.isEnabled)
        .fontSize(UiTypography.BODY_SIZE)
        .fontColor(UiColorToken.TEXT_PRIMARY)
        .backgroundColor(UiColorToken.SURFACE)
        .borderRadius(UiSpacing.CORNER_RADIUS)
        .padding({ left: UiSpacing.ITEM_GAP, right: UiSpacing.ITEM_GAP })
        .onChange((next: string) => this.onValueChange(next))
    }
    .width('100%')
  }
}
