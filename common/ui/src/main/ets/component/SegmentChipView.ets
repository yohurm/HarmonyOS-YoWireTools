import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiTypography } from '../theme/UiTypography';
/**
 * Segmented control chip (mode / category picker).
 */
@ComponentV2
export struct SegmentChipView {
  @Param label: string = '';
  @Param selected: boolean = false;
  @Param disabled: boolean = false;
  @Event onSelect: () => void = () => {
  };
  build() {
    Text(this.label)
      .fontSize(UiTypography.CAPTION_SIZE)
      .fontWeight(this.selected ? FontWeight.Medium : FontWeight.Regular)
      .fontColor(this.resolveTextColor())
      .padding({ left: 12, right: 12, top: 8, bottom: 8 })
      .backgroundColor(this.resolveBackground())
      .borderRadius(UiLayoutConstants.CARD_RADIUS)
      .opacity(this.disabled ? 0.5 : 1)
      .onClick(() => {
        if (!this.disabled) {
          this.onSelect();
        }
      })
  }
  private resolveTextColor(): ResourceColor {
    if (this.disabled) {
      return UiColorToken.TEXT_TERTIARY;
    }
    if (this.selected) {
      return Color.White;
    }
    return UiColorToken.TEXT_PRIMARY;
  }
  private resolveBackground(): ResourceColor {
    if (this.disabled) {
      return $r('app.color.ui_emphasize_tertiary');
    }
    if (this.selected) {
      return UiColorToken.PRIMARY;
    }
    return UiColorToken.SURFACE;
  }
}
