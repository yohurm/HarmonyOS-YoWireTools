import { YoButtonToken } from '../../token/component/YoButtonToken';
import { YoColor } from '../../token/semantic/YoColor';
import { YoTypeStyle } from '../../token/semantic/YoTypeStyle';
import { YoSize } from '../../token/foundation/YoSize';
import { YoSpace } from '../../token/foundation/YoSpace';
import { YoResourceUtil } from '../../util/YoResourceUtil';

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
    Column({ space: YoSpace.XS }) {
      Button(this.loading ? $r('app.string.youi_action_processing') : this.label, { type: ButtonType.Normal })
        .width(this.fullWidth ? '100%' : undefined)
        .height(this.compact ? YoButtonToken.HEIGHT_COMPACT : YoButtonToken.HEIGHT)
        .constraintSize({ minWidth: YoSize.TOUCH_TARGET_MIN, minHeight: YoSize.TOUCH_TARGET_MIN })
        .borderRadius(YoButtonToken.RADIUS)
        .fontSize(YoTypeStyle.SUBTITLE_S.size)
        .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
        .fontColor(this.resolveButtonFontColor())
        .backgroundColor(this.resolveButtonBackground())
        .borderWidth(this.resolveFocusBorderWidth())
        .borderColor(YoColor.BORDER_FOCUSED)
        .stateEffect(false)
        .focusable(this.isEnabled && !this.loading)
        .enabled(this.isEnabled && !this.loading)
        .opacity(this.isEnabled ? 1 : YoButtonToken.DISABLED_OPACITY)
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
      if (!this.isEnabled && YoResourceUtil.hasText(this.disabledReason)) {
        Text(this.disabledReason)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_TERTIARY)
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
      return YoResourceUtil.format(
        $r('app.string.youi_a11y_join_two'),
        YoResourceUtil.resolveText(this.label),
        YoResourceUtil.resolveText($r('app.string.youi_action_processing'))
      );
    }
    let label = YoResourceUtil.resolveText(this.label);
    if (!this.isEnabled && YoResourceUtil.hasText(this.disabledReason)) {
      label = YoResourceUtil.format(
        $r('app.string.youi_a11y_join_two'),
        label,
        YoResourceUtil.resolveText(this.disabledReason)
      );
    } else if (!this.isEnabled) {
      label = YoResourceUtil.format($r('app.string.youi_a11y_disabled'), label);
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
        return YoColor.TEXT_DISABLED;
      }
      return YoColor.TEXT_ON_PRIMARY;
    }
    if (this.kind === YoActionButtonKind.TEXT) {
      return YoColor.BRAND_PRIMARY;
    }
    if (this.kind === YoActionButtonKind.SECONDARY) {
      return YoColor.TEXT_PRIMARY;
    }
    return YoColor.TEXT_ON_PRIMARY;
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
          return YoColor.BRAND_PRIMARY_DISABLED;
        case YoActionButtonKind.DANGER:
          return YoButtonToken.DANGER_BACKGROUND;
        case YoActionButtonKind.SECONDARY:
          return YoButtonToken.SECONDARY_BACKGROUND;
        default:
          return Color.Transparent;
      }
    }
    switch (this.kind) {
      case YoActionButtonKind.DANGER:
        return YoButtonToken.DANGER_BACKGROUND;
      case YoActionButtonKind.SECONDARY:
        return YoButtonToken.SECONDARY_BACKGROUND;
      case YoActionButtonKind.TEXT:
        return Color.Transparent;
      default:
        return YoButtonToken.PRIMARY_BACKGROUND;
    }
  }

  private resolvePressedBackground(): ResourceColor {
    switch (this.kind) {
      case YoActionButtonKind.PRIMARY:
        return YoColor.BRAND_PRIMARY_PRESSED;
      case YoActionButtonKind.DANGER:
        return YoButtonToken.DANGER_BACKGROUND;
      case YoActionButtonKind.SECONDARY:
      case YoActionButtonKind.TEXT:
        return YoColor.INTERACTIVE_PRESSED;
      default:
        return YoColor.BRAND_PRIMARY_PRESSED;
    }
  }

  private resolveHoverBackground(): ResourceColor {
    switch (this.kind) {
      case YoActionButtonKind.PRIMARY:
      case YoActionButtonKind.DANGER:
        return YoColor.BRAND_PRIMARY_PRESSED;
      case YoActionButtonKind.SECONDARY:
      case YoActionButtonKind.TEXT:
        return YoColor.INTERACTIVE_HOVER;
      default:
        return YoColor.BRAND_PRIMARY_PRESSED;
    }
  }

  private resolveFocusedBackground(): ResourceColor {
    switch (this.kind) {
      case YoActionButtonKind.SECONDARY:
      case YoActionButtonKind.TEXT:
        return YoColor.INTERACTIVE_FOCUSED;
      default:
        return this.resolveDefaultBackground();
    }
  }
}
