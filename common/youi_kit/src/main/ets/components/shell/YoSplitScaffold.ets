import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { YoNavigationToken } from '../../token/component/YoNavigationToken';

/**
 * B+C 分栏脚手架：>=600vp 可配置权重（默认 4:6），手机单列。
 * 可传入 YoNavigationToken 分栏变体权重以实现 5:5 或 6:4 布局。
 * minPaneWidthVp：分栏每列最小宽度（vp），避免任一侧过窄。
 */
@ComponentV2
export struct YoSplitScaffold {
  @BuilderParam listPane: () => void = this.defaultPane;
  @BuilderParam detailPane: () => void = this.defaultPane;
  @Param showDetailOnCompact: boolean = false;
  @Param listWeight: number = YoNavigationToken.SPLIT_LIST_WEIGHT;
  @Param detailWeight: number = YoNavigationToken.SPLIT_DETAIL_WEIGHT;
  /** 分栏布局下列表与详情列共用的最小宽度（vp）。 */
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
