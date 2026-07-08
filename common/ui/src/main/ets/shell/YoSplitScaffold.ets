import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';

/**
 * B+C split scaffold: 4:6 at >=600vp, single column on phone.
 */
@ComponentV2
export struct YoSplitScaffold {
  @BuilderParam listPane: () => void = this.defaultPane;
  @BuilderParam detailPane: () => void = this.defaultPane;
  @Param showDetailOnCompact: boolean = false;
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
        .layoutWeight(UiLayoutConstants.SPLIT_LIST_WEIGHT)
        .height('100%')

        Column() {
          this.detailPane()
        }
        .layoutWeight(UiLayoutConstants.SPLIT_DETAIL_WEIGHT)
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
