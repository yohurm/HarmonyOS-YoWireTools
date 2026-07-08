import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { UiColorToken } from '../theme/UiColorToken';
import { UiSpacing } from '../theme/UiSpacing';
import { UiTypography } from '../theme/UiTypography';
/**
 * Inline info / warning / success banner.
 */
@ComponentV2
export struct InfoBannerView {
  @Param message: string = '';
  @Param tone: 'info' | 'warning' | 'error' | 'success' = 'info';
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();
  build() {
    Row() {
      Text(this.message)
        .fontSize(UiTypography.BODY_SIZE)
        .fontColor(this.resolveTextColor())
        .layoutWeight(1)
    }
    .width('100%')
    .padding({
      left: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      right: WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint),
      top: UiSpacing.ITEM_GAP,
      bottom: UiSpacing.ITEM_GAP
    })
    .backgroundColor(this.resolveBackgroundColor())
    .borderRadius(UiSpacing.CORNER_RADIUS)
  }
  private resolveTextColor(): ResourceColor {
    if (this.tone === 'error') {
      return UiColorToken.ERROR;
    }
    if (this.tone === 'warning') {
      return UiColorToken.WARNING;
    }
    if (this.tone === 'success') {
      return UiColorToken.SUCCESS;
    }
    return UiColorToken.INFO;
  }
  private resolveBackgroundColor(): ResourceColor {
    return UiColorToken.SURFACE;
  }
}
