import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { NavigationToken } from '../token/component/NavigationToken';

/**
 * B+C split scaffold: configurable weights (default 4:6) at >=600vp, single column on phone.
 * Pass NavigationToken split variant weights for 5:5 or 6:4 layouts.
 * minPaneWidthVp: minimum width (vp) per split column so neither pane collapses too narrow.
 */
@ComponentV2
export struct YoSplitScaffold {
  @BuilderParam listPane: () => void = this.defaultPane;
  @BuilderParam detailPane: () => void = this.defaultPane;
  @Param showDetailOnCompact: boolean = false;
  @Param listWeight: number = NavigationToken.SPLIT_LIST_WEIGHT;
  @Param detailWeight: number = NavigationToken.SPLIT_DETAIL_WEIGHT;
  /** Minimum width (vp) applied to both list and detail columns in split layout. */
  @Param minPaneWidthVp: number = 280;
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();

  @Builder
  defaultPane() {
  }

  build() {
    if (WindowWidthBreakpointUtil.isSplitCapable(this.metrics.breakpoint)) {
      Row() {
        Column() {
          this.listPane()
        }
        .layoutWeight(this.listWeight)
        .constraintSize({ minWidth: this.minPaneWidthVp })
        .height('100%')

        Column() {
          this.detailPane()
        }
        .layoutWeight(this.detailWeight)
        .constraintSize({ minWidth: this.minPaneWidthVp })
        .height('100%')
      }
      .width('100%')
      .height('100%')
    } else if (this.showDetailOnCompact) {
      Column() {
        this.detailPane()
      }
      .width('100%')
      .height('100%')
    } else {
      Column() {
        this.listPane()
      }
      .width('100%')
      .height('100%')
    }
  }
}
