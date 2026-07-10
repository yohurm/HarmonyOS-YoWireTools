import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSize } from '../token/foundation/UiSize';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiOpacity } from '../token/foundation/UiOpacity';
import { CardToken } from '../token/component/CardToken';
import { UiResourceUtil } from '../util/UiResourceUtil';

const KEY_CODE_SPACE: number = 2050;
const KEY_CODE_ENTER: number = 2054;

/**
 * Standard list row: title, subtitle, meta, trailing status/chevron.
 */
@ComponentV2
export struct YoListRow {
  @Param title: ResourceStr = '';
  @Param subtitle: ResourceStr = '';
  @Param meta: ResourceStr = '';
  @Param trailing: ResourceStr = '';
  @Param showChevron: boolean = false;
  @Param selected: boolean = false;
  @Param disabled: boolean = false;
  @Param alert: boolean = false;
  @Event onTap: () => void = () => {
  };
  @Local private isPressed: boolean = false;
  @Local private isHovered: boolean = false;
  @Local private isFocused: boolean = false;

  build() {
    Row({ space: UiSpace.M }) {
      Column({ space: UiSpace.XXS }) {
        Text(this.title)
          .fontSize(UiTypeStyle.BODY_M.size)
          .fontColor(this.disabled ? UiColor.TEXT_TERTIARY : UiColor.TEXT_PRIMARY)
          .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
        if (UiResourceUtil.hasText(this.subtitle)) {
          Text(this.subtitle)
            .fontSize(UiTypeStyle.BODY_S.size)
            .fontColor(UiColor.TEXT_SECONDARY)
            .maxLines(2)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
        if (UiResourceUtil.hasText(this.meta)) {
          Text(this.meta)
            .fontSize(UiTypeStyle.BODY_S.size)
            .fontColor(UiColor.TEXT_TERTIARY)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })
            .width('100%')
        }
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      if (UiResourceUtil.hasText(this.trailing)) {
        Text(this.trailing)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(this.alert ? UiColor.ERROR : UiColor.TEXT_TERTIARY)
          .maxLines(1)
      }
      if (this.showChevron) {
        SymbolGlyph($r('sys.symbol.chevron_right'))
          .fontSize(UiSize.ICON_S)
          .fontColor([UiColor.ICON_TERTIARY])
          .accessibilityLevel('no')
      }
    }
    .width('100%')
    .constraintSize({ minHeight: UiSize.LIST_ROW_HEIGHT })
    .padding({
      left: CardToken.PADDING_COMPACT,
      right: CardToken.PADDING_COMPACT,
      top: UiSpace.M,
      bottom: UiSpace.M
    })
    .backgroundColor(this.resolveBackground())
    .borderRadius(CardToken.RADIUS_SMALL)
    .borderWidth(this.isFocused && !this.disabled ? 2 : 0)
    .borderColor(UiColor.BORDER_FOCUSED)
    .opacity(this.disabled ? UiOpacity.DISABLED_CONTAINER : UiOpacity.ENABLED)
    .focusable(!this.disabled)
    .onClick(() => {
      if (!this.disabled) {
        this.onTap();
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
    if (UiResourceUtil.hasText(this.meta)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.meta)
      );
    }
    if (UiResourceUtil.hasText(this.trailing)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.trailing)
      );
    }
    if (this.selected) {
      label = UiResourceUtil.format($r('app.string.ui_a11y_selected'), label);
    }
    if (this.disabled) {
      label = UiResourceUtil.format($r('app.string.ui_a11y_disabled'), label);
    }
    return label;
  }

  private resolveBackground(): ResourceColor {
    if (this.disabled) {
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
    if (this.selected) {
      return UiColor.INTERACTIVE_SELECTED;
    }
    return UiColor.SURFACE_CARD;
  }
}
