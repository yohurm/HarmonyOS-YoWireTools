import { CardToken } from '../token/component/CardToken';
import { ChipToken } from '../token/component/ChipToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiSize } from '../token/foundation/UiSize';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiResourceUtil } from '../util/UiResourceUtil';
import { StatusPillTone, StatusPillView } from './StatusPillView';

const KEY_CODE_SPACE: number = 2050;
const KEY_CODE_ENTER: number = 2054;

/**
 * Compact active session chip for ContextStrip / headers.
 */
@ComponentV2
export struct SessionChipView {
  @Param label: ResourceStr = '';
  @Param tone: StatusPillTone = 'brand';
  @Event onTap: () => void = () => {
  };
  @Local private isPressed: boolean = false;
  @Local private isHovered: boolean = false;
  @Local private isFocused: boolean = false;

  build() {
    Row() {
      StatusPillView({ label: this.label, tone: this.tone })
    }
    .padding(UiSpace.XS)
    .constraintSize({ minHeight: UiSize.TOUCH_TARGET_MIN })
    .backgroundColor(this.resolveBackground())
    .borderRadius(ChipToken.RADIUS)
    .borderWidth(this.isFocused ? 2 : 0)
    .borderColor(UiColor.BORDER_FOCUSED)
    .focusable(true)
    .onClick(() => this.onTap())
    .onHover((isHover: boolean) => {
      this.isHovered = isHover;
    })
    .onTouch((event: TouchEvent) => {
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
      if (event.type !== KeyType.Down) {
        return;
      }
      if (event.keyCode === KEY_CODE_ENTER || event.keyCode === KEY_CODE_SPACE) {
        this.onTap();
      }
    })
    .accessibilityGroup(true)
    .accessibilityText(UiResourceUtil.resolveText(this.label))
  }

  private resolveBackground(): ResourceColor {
    if (this.isPressed) {
      return UiColor.INTERACTIVE_PRESSED;
    }
    if (this.isFocused) {
      return UiColor.INTERACTIVE_FOCUSED;
    }
    if (this.isHovered) {
      return UiColor.INTERACTIVE_HOVER;
    }
    return CardToken.BACKGROUND;
  }
}
