import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpoint } from 'common_platform';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';

/**
 * Centers content and caps width at XL breakpoint (>1440vp → max 2220vp).
 * Used once at app shell level (YoAppShell).
 */
@ComponentV2
export struct YoResponsiveFrame {
  @BuilderParam content: () => void = this.defaultContent;
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();

  @Builder
  defaultContent() {
  }

  build() {
    if (this.metrics.breakpoint === WindowWidthBreakpoint.XL) {
      Row() {
        Column() {
          this.content()
        }
        .width('100%')
        .constraintSize({ maxWidth: UiLayoutConstants.CONTENT_MAX_WIDTH_XL })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
    } else {
      Column() {
        this.content()
      }
      .width('100%')
      .height('100%')
    }
  }
}
