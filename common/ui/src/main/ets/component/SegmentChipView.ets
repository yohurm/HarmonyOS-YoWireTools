import { ChipToken } from '../token/component/ChipToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSize } from '../token/foundation/UiSize';
import { UiOpacity } from '../token/foundation/UiOpacity';
import { UiResourceUtil } from '../util/UiResourceUtil';

const KEY_CODE_SPACE: number = 2050;
const KEY_CODE_ENTER: number = 2054;

/**
 * Segmented control chip (mode / category picker).
 */
@ComponentV2
export struct SegmentChipView {
  @Param label: ResourceStr = '';
  @Param selected: boolean = false;
  @Param disabled: boolean = false;
  @Event onSelect: () => void = () => {
  };
  @Local private isPressed: boolean = false;
  @Local private isHovered: boolean = false;
  @Local private isFocused: boolean = false;

  build() {
    Row() {
      Text(this.label)
        .fontSize(UiTypeStyle.BODY_S.size)
        .fontWeight(this.selected ? UiTypeStyle.SUBTITLE_S.weight : UiTypeStyle.BODY_S.weight)
        .fontColor(this.resolveTextColor())
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
    }
    .height(ChipToken.TOUCH_HEIGHT)
    .constraintSize({ minHeight: UiSize.TOUCH_TARGET_MIN })
    .padding({
      left: ChipToken.HORIZONTAL_PADDING,
      right: ChipToken.HORIZONTAL_PADDING
    })
    .justifyContent(FlexAlign.Center)
    .backgroundColor(this.resolveBackground())
    .borderRadius(ChipToken.RADIUS)
    .borderWidth(this.isFocused && !this.disabled ? 2 : 0)
    .borderColor(UiColor.BORDER_FOCUSED)
    .opacity(this.disabled ? UiOpacity.DISABLED_CONTAINER : UiOpacity.ENABLED)
    .focusable(!this.disabled)
    .onClick(() => {
      if (!this.disabled) {
        this.onSelect();
      }
    })
    .onHover((isHover: boolean) => {
      if (!this.disabled) {
        this.isHovered = isHover;
      }
    })
    .onTouch((event: TouchEvent) => {
      if (this.disabled) {
        return;
      }
      if (event.type === TouchType.Down) {
        this.isPressed = true;
      } else if (event.type === TouchType.Up || event.type === TouchType.Cancel) {
        this.isPressed = false;
      }
    })
    .onFocus(() => {
      this.isFocused = true;
    })
    .onBlur(() => {
      this.isFocused = false;
      this.isPressed = false;
    })
    .onKeyEvent((event: KeyEvent) => {
      if (this.disabled || event.type !== KeyType.Down) {
        return;
      }
      if (event.keyCode === KEY_CODE_ENTER || event.keyCode === KEY_CODE_SPACE) {
        this.onSelect();
      }
    })
    .accessibilityGroup(true)
    .accessibilityText(this.buildAccessibilityLabel())
  }

  private buildAccessibilityLabel(): string {
    let label = UiResourceUtil.resolveText(this.label);
    if (this.selected) {
      label = UiResourceUtil.format($r('app.string.ui_a11y_selected'), label);
    }
    if (this.disabled) {
      label = UiResourceUtil.format($r('app.string.ui_a11y_disabled'), label);
    }
    return label;
  }

  private resolveTextColor(): ResourceColor {
    if (this.disabled) {
      return UiColor.TEXT_DISABLED;
    }
    if (this.selected) {
      return ChipToken.SELECTED_FOREGROUND;
    }
    return ChipToken.DEFAULT_FOREGROUND;
  }

  private resolveBackground(): ResourceColor {
    if (this.disabled) {
      return ChipToken.DEFAULT_BACKGROUND;
    }
    if (this.isPressed) {
      return this.selected ? UiColor.BRAND_PRIMARY_PRESSED : UiColor.INTERACTIVE_PRESSED;
    }
    if (this.isFocused) {
      return this.selected ? UiColor.BRAND_PRIMARY_PRESSED : UiColor.INTERACTIVE_FOCUSED;
    }
    if (this.isHovered) {
      return this.selected ? UiColor.BRAND_PRIMARY_PRESSED : UiColor.INTERACTIVE_HOVER;
    }
    if (this.selected) {
      return ChipToken.SELECTED_BACKGROUND;
    }
    return ChipToken.DEFAULT_BACKGROUND;
  }
}
