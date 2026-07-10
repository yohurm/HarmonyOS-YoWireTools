import { InputToken } from '../token/component/InputToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiOpacity } from '../token/foundation/UiOpacity';
import { UiResourceUtil } from '../util/UiResourceUtil';

@ComponentV2
export struct YoTextField {
  @Param label: ResourceStr = '';
  @Param value: string = '';
  @Param placeholder: ResourceStr = '';
  @Param isEnabled: boolean = true;
  @Param maxLength: number = 4096;
  @Param errorMessage: ResourceStr = '';
  @Event onValueChange: (value: string) => void = () => {
  };
  @Local private isFocused: boolean = false;

  build() {
    Column({ space: UiSpace.M }) {
      if (UiResourceUtil.hasText(this.label)) {
        Text(this.label)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.TEXT_SECONDARY)
          .width('100%')
      }
      Column() {
        TextInput({ text: this.value, placeholder: this.placeholder })
          .width('100%')
          .height(InputToken.HEIGHT)
          .constraintSize({ minHeight: InputToken.HEIGHT })
          .maxLength(this.maxLength)
          .enabled(this.isEnabled)
          .fontSize(UiTypeStyle.BODY_M.size)
          .fontWeight(UiTypeStyle.BODY_M.weight)
          .fontColor(this.isEnabled ? InputToken.FOREGROUND : UiColor.TEXT_DISABLED)
          .backgroundColor(Color.Transparent)
          .padding({ left: InputToken.HORIZONTAL_PADDING, right: InputToken.HORIZONTAL_PADDING })
          .onChange((next: string) => this.onValueChange(next))
          .onFocus(() => {
            this.isFocused = true;
          })
          .onBlur(() => {
            this.isFocused = false;
          })
      }
      .width('100%')
      .backgroundColor(InputToken.BACKGROUND)
      .borderRadius(InputToken.RADIUS)
      .border({
        width: this.resolveBorderWidth(),
        color: this.resolveBorderColor(),
        radius: InputToken.RADIUS
      })
      .clip(true)
      .opacity(this.isEnabled ? UiOpacity.ENABLED : UiOpacity.DISABLED_CONTENT)
      .accessibilityGroup(true)
      if (UiResourceUtil.hasText(this.errorMessage)) {
        Text(this.errorMessage)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.ERROR)
          .width('100%')
      }
    }
    .width('100%')
  }

  private resolveBorderWidth(): number {
    if (UiResourceUtil.hasText(this.errorMessage) || this.isFocused) {
      return InputToken.BORDER_WIDTH_FOCUSED;
    }
    return InputToken.BORDER_WIDTH;
  }

  private resolveBorderColor(): ResourceColor {
    if (UiResourceUtil.hasText(this.errorMessage)) {
      return UiColor.ERROR;
    }
    if (this.isFocused) {
      return InputToken.BORDER_FOCUSED;
    }
    return InputToken.BORDER;
  }
}
