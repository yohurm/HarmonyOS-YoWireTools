import { ChipToken } from '../token/component/ChipToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSpace } from '../token/foundation/UiSpace';

export type StatusPillTone = 'brand' | 'success' | 'warning' | 'error' | 'info' | 'neutral';

@ComponentV2
export struct StatusPillView {
  @Param label: ResourceStr = '';
  @Param tone: StatusPillTone = 'neutral';

  build() {
    Text(this.label)
      .fontSize(UiTypeStyle.BODY_S.size)
      .fontWeight(UiTypeStyle.BODY_S.weight)
      .fontColor(this.resolveForeground())
      .padding({
        left: UiSpace.M,
        right: UiSpace.M,
        top: UiSpace.XS,
        bottom: UiSpace.XS
      })
      .backgroundColor(this.resolveBackground())
      .borderRadius(ChipToken.STATUS_RADIUS)
      .accessibilityLevel('no')
  }

  private resolveForeground(): ResourceColor {
    switch (this.tone) {
      case 'brand':
        return UiColor.BRAND_PRIMARY;
      case 'success':
        return UiColor.SUCCESS;
      case 'warning':
        return UiColor.WARNING;
      case 'error':
        return UiColor.ERROR;
      case 'info':
        return UiColor.INFO;
      default:
        return UiColor.TEXT_SECONDARY;
    }
  }

  private resolveBackground(): ResourceColor {
    switch (this.tone) {
      case 'brand':
        return UiColor.SURFACE_SELECTED;
      case 'success':
        return UiColor.SUCCESS_CONTAINER;
      case 'warning':
        return UiColor.WARNING_CONTAINER;
      case 'error':
        return UiColor.ERROR_CONTAINER;
      case 'info':
        return UiColor.INFO_CONTAINER;
      default:
        return UiColor.BACKGROUND_SECONDARY;
    }
  }
}
