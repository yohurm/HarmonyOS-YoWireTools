import { YoColor } from '../token/semantic/YoColor';
import { YoTypeStyle, YoTypeStyleSpec } from '../token/semantic/YoTypeStyle';

/**
 * 由 Token 驱动的系统 {@link Text} {@link AttributeModifier} — 默认正文 + 主文本色。
 */
export class YoTextModifier implements AttributeModifier<TextAttribute> {
  private typeSpec: YoTypeStyleSpec = YoTypeStyle.BODY_M;
  private textColor: ResourceColor = YoColor.TEXT_PRIMARY;

  /** 应用排版 Token（默认 {@link YoTypeStyle.BODY_M}）。 */
  typography(spec: YoTypeStyleSpec): YoTextModifier {
    this.typeSpec = spec;
    return this;
  }

  /** 覆盖语义文本颜色。 */
  color(color: ResourceColor): YoTextModifier {
    this.textColor = color;
    return this;
  }

  /** 快捷：BODY_M 正文 + 次要文本色。 */
  secondary(): YoTextModifier {
    this.typeSpec = YoTypeStyle.BODY_M;
    this.textColor = YoColor.TEXT_SECONDARY;
    return this;
  }

  /** 快捷：BODY_M 正文 + 第三级文本色。 */
  tertiary(): YoTextModifier {
    this.typeSpec = YoTypeStyle.BODY_M;
    this.textColor = YoColor.TEXT_TERTIARY;
    return this;
  }

  applyNormalAttribute(instance: TextAttribute): void {
    instance
      .fontSize(this.typeSpec.size)
      .fontWeight(this.typeSpec.weight)
      .fontColor(this.textColor);
    if (this.typeSpec.family !== undefined && this.typeSpec.family.length > 0) {
      instance.fontFamily(this.typeSpec.family);
    }
  }

  applyPressedAttribute(instance: TextAttribute): void {
    this.applyNormalAttribute(instance);
  }
}
