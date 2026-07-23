import { YoChipToken } from '../../token/component/YoChipToken';
import { YoColor } from '../../token/semantic/YoColor';
import { YoTypeStyle } from '../../token/semantic/YoTypeStyle';
import { YoSpace } from '../../token/foundation/YoSpace';

export type YoStatusPillTone = 'brand' | 'success' | 'warning' | 'error' | 'info' | 'neutral';

@ComponentV2
export struct YoStatusPill {
  @Param label: ResourceStr = '';
  @Param tone: YoStatusPillTone = 'neutral';

  build() {
    Text(this.label)
      .fontSize(YoTypeStyle.BODY_S.size)
      .fontWeight(YoTypeStyle.BODY_S.weight)
      .fontColor(this.resolveForeground())
      .padding({
        left: YoSpace.M,
        right: YoSpace.M,
        top: YoSpace.XS,
        bottom: YoSpace.XS
      })
      .backgroundColor(this.resolveBackground())
      .borderRadius(YoChipToken.STATUS_RADIUS)
      .accessibilityLevel('no')
  }

  private resolveForeground(): ResourceColor {
    switch (this.tone) {
      case 'brand':
        return YoColor.BRAND_PRIMARY;
      case 'success':
        return YoColor.SUCCESS;
      case 'warning':
        return YoColor.WARNING;
      case 'error':
        return YoColor.ERROR;
      case 'info':
        return YoColor.INFO;
      default:
        return YoColor.TEXT_SECONDARY;
    }
  }

  private resolveBackground(): ResourceColor {
    switch (this.tone) {
      case 'brand':
        return YoColor.SURFACE_SELECTED;
      case 'success':
        return YoColor.SUCCESS_CONTAINER;
      case 'warning':
        return YoColor.WARNING_CONTAINER;
      case 'error':
        return YoColor.ERROR_CONTAINER;
      case 'info':
        return YoColor.INFO_CONTAINER;
      default:
        return YoColor.BACKGROUND_SECONDARY;
    }
  }
}
