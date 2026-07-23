import { YoButtonToken } from '../token/component/YoButtonToken';
import { YoColor } from '../token/semantic/YoColor';
import { YoTypeStyle } from '../token/semantic/YoTypeStyle';
import { YoSize } from '../token/foundation/YoSize';

/** {@link YoButtonModifier} 的视觉变体 — 对齐 Kit 主按钮语义。 */
export enum YoButtonModifierKind {
  PRIMARY = 0,
  SECONDARY = 1,
  TEXT = 2,
  DANGER = 3
}

/**
 * 由 Token 驱动的系统 {@link Button} {@link AttributeModifier} — 默认主按钮样式。
 */
export class YoButtonModifier implements AttributeModifier<ButtonAttribute> {
  private kind: YoButtonModifierKind = YoButtonModifierKind.PRIMARY;
  private compact: boolean = false;

  /** 选择按钮视觉变体。 */
  type(kind: YoButtonModifierKind): YoButtonModifier {
    this.kind = kind;
    return this;
  }

  /** 使用 {@link YoButtonToken.HEIGHT_COMPACT} 的紧凑高度。 */
  compactMode(compact: boolean = true): YoButtonModifier {
    this.compact = compact;
    return this;
  }

  applyNormalAttribute(instance: ButtonAttribute): void {
    instance
      .height(this.compact ? YoButtonToken.HEIGHT_COMPACT : YoButtonToken.HEIGHT)
      .constraintSize({ minWidth: YoSize.TOUCH_TARGET_MIN, minHeight: YoSize.TOUCH_TARGET_MIN })
      .borderRadius(YoButtonToken.RADIUS)
      .fontSize(YoTypeStyle.SUBTITLE_S.size)
      .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
      .fontColor(this.resolveNormalFontColor())
      .backgroundColor(this.resolveNormalBackground())
      .stateEffect(false);
  }

  applyPressedAttribute(instance: ButtonAttribute): void {
    instance
      .fontColor(this.resolveNormalFontColor())
      .backgroundColor(this.resolvePressedBackground());
  }

  private resolveNormalFontColor(): ResourceColor {
    switch (this.kind) {
      case YoButtonModifierKind.TEXT:
        return YoColor.BRAND_PRIMARY;
      case YoButtonModifierKind.SECONDARY:
        return YoColor.TEXT_PRIMARY;
      case YoButtonModifierKind.DANGER:
      case YoButtonModifierKind.PRIMARY:
      default:
        return YoButtonToken.PRIMARY_FOREGROUND;
    }
  }

  private resolveNormalBackground(): ResourceColor {
    switch (this.kind) {
      case YoButtonModifierKind.DANGER:
        return YoButtonToken.DANGER_BACKGROUND;
      case YoButtonModifierKind.SECONDARY:
        return YoButtonToken.SECONDARY_BACKGROUND;
      case YoButtonModifierKind.TEXT:
        return Color.Transparent;
      case YoButtonModifierKind.PRIMARY:
      default:
        return YoButtonToken.PRIMARY_BACKGROUND;
    }
  }

  private resolvePressedBackground(): ResourceColor {
    switch (this.kind) {
      case YoButtonModifierKind.PRIMARY:
        return YoColor.BRAND_PRIMARY_PRESSED;
      case YoButtonModifierKind.DANGER:
        return YoButtonToken.DANGER_BACKGROUND;
      case YoButtonModifierKind.SECONDARY:
      case YoButtonModifierKind.TEXT:
        return YoColor.INTERACTIVE_PRESSED;
      default:
        return YoColor.BRAND_PRIMARY_PRESSED;
    }
  }
}
