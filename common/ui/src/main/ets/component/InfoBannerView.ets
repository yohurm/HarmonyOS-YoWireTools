import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { CardToken } from '../token/component/CardToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { UiSpace } from '../token/foundation/UiSpace';

/**
 * Inline info / warning / success banner.
 */
@ComponentV2
export struct InfoBannerView {
  @Param message: ResourceStr = '';
  @Param tone: 'info' | 'warning' | 'error' | 'success' = 'info';
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();

  build() {
    Row() {
      Text(this.message)
        .fontSize(UiTypeStyle.BODY_M.size)
        .fontColor(this.resolveTextColor())
        .layoutWeight(1)
    }
    .width('100%')
    .padding({
      left: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      right: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      top: UiSpace.M,
      bottom: UiSpace.M
    })
    .backgroundColor(this.resolveBackgroundColor())
    .borderRadius(CardToken.RADIUS)
  }

  private resolveTextColor(): ResourceColor {
    switch (this.tone) {
      case 'error':
        return UiColor.ERROR;
      case 'warning':
        return UiColor.WARNING;
      case 'success':
        return UiColor.SUCCESS;
      default:
        return UiColor.INFO;
    }
  }

  private resolveBackgroundColor(): ResourceColor {
    switch (this.tone) {
      case 'error':
        return UiColor.ERROR_CONTAINER;
      case 'warning':
        return UiColor.WARNING_CONTAINER;
      case 'success':
        return UiColor.SUCCESS_CONTAINER;
      default:
        return UiColor.INFO_CONTAINER;
    }
  }
}
