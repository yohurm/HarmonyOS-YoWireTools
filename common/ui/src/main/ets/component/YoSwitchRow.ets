import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSize } from '../token/foundation/UiSize';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiOpacity } from '../token/foundation/UiOpacity';
import { InputToken } from '../token/component/InputToken';
import { UiResourceUtil } from '../util/UiResourceUtil';

@ComponentV2
export struct YoSwitchRow {
  @Param title: ResourceStr = '';
  @Param subtitle: ResourceStr = '';
  @Param checked: boolean = false;
  @Param isEnabled: boolean = true;
  @Event onCheckedChange: (checked: boolean) => void = () => {
  };
  @Local private isHovered: boolean = false;
  @Local private isFocused: boolean = false;

  build() {
    Row() {
      Column({ space: UiSpace.XS }) {
        Text(this.title)
          .fontSize(UiTypeStyle.BODY_M.size)
          .fontWeight(UiTypeStyle.BODY_M.weight)
          .fontColor(this.isEnabled ? UiColor.TEXT_PRIMARY : UiColor.TEXT_DISABLED)
        if (UiResourceUtil.hasText(this.subtitle)) {
          Text(this.subtitle)
            .fontSize(UiTypeStyle.BODY_S.size)
            .fontColor(this.isEnabled ? UiColor.TEXT_TERTIARY : UiColor.TEXT_DISABLED)
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Toggle({ type: ToggleType.Switch, isOn: this.checked })
        .enabled(this.isEnabled)
        .onChange((isOn: boolean) => this.onCheckedChange(isOn))
        .onFocus(() => {
          this.isFocused = true;
        })
        .onBlur(() => {
          this.isFocused = false;
        })
    }
    .width('100%')
    .constraintSize({ minHeight: UiSize.LIST_ROW_HEIGHT })
    .padding({ top: UiSpace.M, bottom: UiSpace.M })
    .backgroundColor(this.resolveBackground())
    .borderRadius(InputToken.RADIUS)
    .borderWidth(this.isFocused && this.isEnabled ? 2 : 0)
    .borderColor(UiColor.BORDER_FOCUSED)
    .opacity(this.isEnabled ? UiOpacity.ENABLED : UiOpacity.DISABLED_CONTAINER)
    .onHover((isHover: boolean) => {
      if (this.isEnabled) {
        this.isHovered = isHover;
      }
    })
    .accessibilityGroup(true)
    .accessibilityText(this.buildAccessibilityLabel())
  }

  private buildAccessibilityLabel(): string {
    let label = UiResourceUtil.resolveText(this.title);
    if (UiResourceUtil.hasText(this.subtitle)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.subtitle)
      );
    }
    if (this.checked) {
      label = UiResourceUtil.format($r('app.string.ui_a11y_selected'), label);
    }
    if (!this.isEnabled) {
      label = UiResourceUtil.format($r('app.string.ui_a11y_disabled'), label);
    }
    return label;
  }

  private resolveBackground(): ResourceColor {
    if (!this.isEnabled) {
      return UiColor.SURFACE_CARD;
    }
    if (this.isFocused) {
      return UiColor.INTERACTIVE_FOCUSED;
    }
    if (this.isHovered) {
      return UiColor.INTERACTIVE_HOVER;
    }
    return UiColor.SURFACE_CARD;
  }
}
