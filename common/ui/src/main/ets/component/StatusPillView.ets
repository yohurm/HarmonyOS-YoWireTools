import { UiColorToken } from '../theme/UiColorToken';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiTypography } from '../theme/UiTypography';

export type StatusPillTone = 'brand' | 'success' | 'warning' | 'error' | 'neutral';

@ComponentV2
export struct StatusPillView {
  @Param label: ResourceStr = '';
  @Param tone: StatusPillTone = 'neutral';

  build() {
    Text(this.label)
      .fontSize(UiTypography.CAPTION_SIZE)
      .fontWeight(FontWeight.Medium)
      .fontColor(this.resolveColor())
      .padding({ left: 8, right: 8, top: 4, bottom: 4 })
      .backgroundColor(this.resolveBackground())
      .borderRadius(UiLayoutConstants.CARD_RADIUS / 2)
  }

  private resolveColor(): ResourceColor {
    switch (this.tone) {
      case 'brand':
        return UiColorToken.PRIMARY;
      case 'success':
        return UiColorToken.SUCCESS;
      case 'warning':
        return UiColorToken.WARNING;
      case 'error':
        return UiColorToken.ERROR;
      default:
        return UiColorToken.TEXT_SECONDARY;
    }
  }

  private resolveBackground(): ResourceColor {
    return $r('app.color.ui_emphasize_tertiary');
  }
}
