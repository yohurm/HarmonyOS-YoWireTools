import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSize } from '../token/foundation/UiSize';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiOpacity } from '../token/foundation/UiOpacity';
import { InputToken } from '../token/component/InputToken';
import { UiResourceUtil } from '../util/UiResourceUtil';

const KEY_CODE_SPACE: number = 2050;
const KEY_CODE_ENTER: number = 2054;

@ComponentV2
export struct YoSelectRow {
  @Param title: ResourceStr = '';
  @Param subtitle: ResourceStr = '';
  @Param value: ResourceStr = '';
  @Param isEnabled: boolean = true;
  @Event onTap: () => void = () => {
  };
  @Local private isPressed: boolean = false;
  @Local private isHovered: boolean = false;
  @Local private isFocused: boolean = false;

  build() {
    Row() {
      Column({ space: UiSpace.XXS }) {
        Text(this.title)
          .fontSize(UiTypeStyle.BODY_M.size)
          .fontWeight(UiTypeStyle.BODY_M.weight)
          .fontColor(this.isEnabled ? UiColor.TEXT_PRIMARY : UiColor.TEXT_DISABLED)
          .width('100%')
        if (UiResourceUtil.hasText(this.subtitle)) {
          Text(this.subtitle)
            .fontSize(UiTypeStyle.BODY_S.size)
            .fontColor(this.isEnabled ? UiColor.TEXT_SECONDARY : UiColor.TEXT_DISABLED)
            .width('100%')
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
      Text(this.value)
        .fontSize(UiTypeStyle.BODY_M.size)
        .fontWeight(UiTypeStyle.BODY_M.weight)
        .fontColor(this.isEnabled ? UiColor.TEXT_SECONDARY : UiColor.TEXT_DISABLED)
        .margin({ right: UiSpace.M })
      SymbolGlyph($r('sys.symbol.chevron_right'))
        .fontSize(UiSize.ICON_S)
        .fontColor([this.isEnabled ? UiColor.ICON_TERTIARY : UiColor.ICON_DISABLED])
        .accessibilityLevel('no')
    }
    .width('100%')
    .constraintSize({ minHeight: UiSize.LIST_ROW_HEIGHT })
    .padding({ top: UiSpace.M, bottom: UiSpace.M })
    .backgroundColor(this.resolveBackground())
    .borderRadius(InputToken.RADIUS)
    .borderWidth(this.isFocused && this.isEnabled ? 2 : 0)
    .borderColor(UiColor.BORDER_FOCUSED)
    .focusable(this.isEnabled)
    .enabled(this.isEnabled)
    .opacity(this.isEnabled ? UiOpacity.ENABLED : UiOpacity.DISABLED_CONTAINER)
    .onClick(() => {
      if (this.isEnabled) {
        this.onTap();
      }
    })
    .onHover((isHover: boolean) => {
      if (this.isEnabled) {
        this.isHovered = isHover;
      }
    })
    .onTouch((event: TouchEvent) => {
      if (!this.isEnabled) {
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
      if (!this.isEnabled || event.type !== KeyType.Down) {
        return;
      }
      if (event.keyCode === KEY_CODE_ENTER || event.keyCode === KEY_CODE_SPACE) {
        this.onTap();
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
    if (UiResourceUtil.hasText(this.value)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.value)
      );
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
    if (this.isPressed) {
      return UiColor.INTERACTIVE_PRESSED;
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
