import { ButtonToken } from '../token/component/ButtonToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSize } from '../token/foundation/UiSize';
import { UiSpace } from '../token/foundation/UiSpace';
import { UiResourceUtil } from '../util/UiResourceUtil';

export enum YoActionButtonKind {
  PRIMARY = 0,
  SECONDARY = 1,
  TEXT = 2,
  DANGER = 3
}

@ComponentV2
export struct YoActionButton {
  @Param label: ResourceStr = '';
  @Param kind: YoActionButtonKind = YoActionButtonKind.PRIMARY;
  @Param isEnabled: boolean = true;
  @Param loading: boolean = false;
  @Param disabledReason: ResourceStr = '';
  @Param compact: boolean = false;
  @Param fullWidth: boolean = true;
  @Event onTap: () => void = () => {
  };
  @Local private isPressed: boolean = false;
  @Local private isHovered: boolean = false;
  @Local private isFocused: boolean = false;

  build() {
    Column({ space: UiSpace.XS }) {
      Button(this.loading ? $r('app.string.ui_action_processing') : this.label, { type: ButtonType.Normal })
        .width(this.fullWidth ? '100%' : undefined)
        .height(this.compact ? ButtonToken.HEIGHT_COMPACT : ButtonToken.HEIGHT)
        .constraintSize({ minWidth: UiSize.TOUCH_TARGET_MIN, minHeight: UiSize.TOUCH_TARGET_MIN })
        .borderRadius(ButtonToken.RADIUS)
        .fontSize(UiTypeStyle.SUBTITLE_S.size)
        .fontWeight(UiTypeStyle.SUBTITLE_S.weight)
        .fontColor(this.resolveButtonFontColor())
        .backgroundColor(this.resolveButtonBackground())
        .borderWidth(this.resolveFocusBorderWidth())
        .borderColor(UiColor.BORDER_FOCUSED)
        .stateEffect(false)
        .focusable(this.isEnabled && !this.loading)
        .enabled(this.isEnabled && !this.loading)
        .opacity(this.isEnabled ? 1 : ButtonToken.DISABLED_OPACITY)
        .onClick(() => {
          if (this.isEnabled && !this.loading) {
            this.onTap();
          }
        })
        .onHover((isHover: boolean) => {
          if (this.isEnabled && !this.loading) {
            this.isHovered = isHover;
          }
        })
        .onTouch((event: TouchEvent) => {
          if (!this.isEnabled || this.loading) {
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
        .accessibilityGroup(true)
        .accessibilityText(this.buildAccessibilityLabel())
      if (!this.isEnabled && UiResourceUtil.hasText(this.disabledReason)) {
        Text(this.disabledReason)
          .fontSize(UiTypeStyle.BODY_S.size)
          .fontColor(UiColor.TEXT_TERTIARY)
          .width('100%')
          .maxLines(2)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .accessibilityLevel('no')
      }
    }
    .width(this.fullWidth ? '100%' : undefined)
    .alignItems(HorizontalAlign.Start)
  }

  private buildAccessibilityLabel(): string {
    if (this.loading) {
      return UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        UiResourceUtil.resolveText(this.label),
        UiResourceUtil.resolveText($r('app.string.ui_action_processing'))
      );
    }
    let label = UiResourceUtil.resolveText(this.label);
    if (!this.isEnabled && UiResourceUtil.hasText(this.disabledReason)) {
      label = UiResourceUtil.format(
        $r('app.string.ui_a11y_join_two'),
        label,
        UiResourceUtil.resolveText(this.disabledReason)
      );
    } else if (!this.isEnabled) {
      label = UiResourceUtil.format($r('app.string.ui_a11y_disabled'), label);
    }
    return label;
  }

  private resolveFocusBorderWidth(): number {
    if (!this.isFocused || !this.isEnabled || this.loading) {
      return 0;
    }
    return 2;
  }

  private resolveButtonFontColor(): ResourceColor {
    if (!this.isEnabled || this.loading) {
      if (this.kind === YoActionButtonKind.SECONDARY || this.kind === YoActionButtonKind.TEXT) {
        return UiColor.TEXT_DISABLED;
      }
      return UiColor.TEXT_ON_PRIMARY;
    }
    if (this.kind === YoActionButtonKind.TEXT) {
      return UiColor.BRAND_PRIMARY;
    }
    if (this.kind === YoActionButtonKind.SECONDARY) {
      return UiColor.TEXT_PRIMARY;
    }
    return UiColor.TEXT_ON_PRIMARY;
  }

  private resolveButtonBackground(): ResourceColor {
    if (!this.isEnabled || this.loading) {
      return this.resolveDefaultBackground();
    }
    if (this.isPressed) {
      return this.resolvePressedBackground();
    }
    if (this.isFocused) {
      return this.resolveFocusedBackground();
    }
    if (this.isHovered) {
      return this.resolveHoverBackground();
    }
    return this.resolveDefaultBackground();
  }

  private resolveDefaultBackground(): ResourceColor {
    if (!this.isEnabled || this.loading) {
      switch (this.kind) {
        case YoActionButtonKind.PRIMARY:
          return UiColor.BRAND_PRIMARY_DISABLED;
        case YoActionButtonKind.DANGER:
          return ButtonToken.DANGER_BACKGROUND;
        case YoActionButtonKind.SECONDARY:
          return ButtonToken.SECONDARY_BACKGROUND;
        default:
          return Color.Transparent;
      }
    }
    switch (this.kind) {
      case YoActionButtonKind.DANGER:
        return ButtonToken.DANGER_BACKGROUND;
      case YoActionButtonKind.SECONDARY:
        return ButtonToken.SECONDARY_BACKGROUND;
      case YoActionButtonKind.TEXT:
        return Color.Transparent;
      default:
        return ButtonToken.PRIMARY_BACKGROUND;
    }
  }

  private resolvePressedBackground(): ResourceColor {
    switch (this.kind) {
      case YoActionButtonKind.PRIMARY:
        return UiColor.BRAND_PRIMARY_PRESSED;
      case YoActionButtonKind.DANGER:
        return ButtonToken.DANGER_BACKGROUND;
      case YoActionButtonKind.SECONDARY:
      case YoActionButtonKind.TEXT:
        return UiColor.INTERACTIVE_PRESSED;
      default:
        return UiColor.BRAND_PRIMARY_PRESSED;
    }
  }

  private resolveHoverBackground(): ResourceColor {
    switch (this.kind) {
      case YoActionButtonKind.PRIMARY:
      case YoActionButtonKind.DANGER:
        return UiColor.BRAND_PRIMARY_PRESSED;
      case YoActionButtonKind.SECONDARY:
      case YoActionButtonKind.TEXT:
        return UiColor.INTERACTIVE_HOVER;
      default:
        return UiColor.BRAND_PRIMARY_PRESSED;
    }
  }

  private resolveFocusedBackground(): ResourceColor {
    switch (this.kind) {
      case YoActionButtonKind.SECONDARY:
      case YoActionButtonKind.TEXT:
        return UiColor.INTERACTIVE_FOCUSED;
      default:
        return this.resolveDefaultBackground();
    }
  }
}
