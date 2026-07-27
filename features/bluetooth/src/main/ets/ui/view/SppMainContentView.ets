import { YoColor, YoResponsive, YoSegmentButton } from 'youi_kit';
import { SppActivePanelView } from './SppActivePanelView';
import { ClassicScanPanelView } from './ClassicScanPanelView';
import { SppMainViewModel, SppSegmentTab } from '../../viewmodel/SppMainViewModel';

/**
 * SPP 主内容编排。
 *
 * Segment 切换两轨（职责解耦）：
 * - ClassicScanPanelView：经典 Inquiry 扫描 + ClassicScanFilter
 * - SppActivePanelView：SPP 活动连接
 */
@ComponentV2
export struct SppMainContentView {
  @Param @Require vm: SppMainViewModel;
  @Param horizontalPadding: number = 16;
  /** Gesture-bar inset; list content pads bottom so last rows remain tappable. */
  @Param bottomInsetVp: number = 0;
  @Local private segmentIndex: number = 0;

  aboutToAppear(): void {
    this.segmentIndex = this.vm.selectedIndex;
  }

  private onSegmentIndexChange(index: number): void {
    this.segmentIndex = index;
    this.vm.selectSegmentByIndex(index);
  }

  build() {
    Column({ space: YoResponsive.CONTROL_GAP }) {
      Column() {
        YoSegmentButton({
          labels: [
            $r('app.string.bt_classic_segment_scan'),
            $r('app.string.bt_spp_segment_active')
          ],
          initialIndex: this.vm.selectedIndex,
          onSelectedIndexChange: (index: number) => {
            this.onSegmentIndexChange(index);
          }
        })
      }
      .width('100%')
      .padding({
        left: this.horizontalPadding,
        right: this.horizontalPadding
      })

      if (this.segmentIndex === SppSegmentTab.ACTIVE) {
        SppActivePanelView({
          vm: this.vm,
          horizontalPadding: this.horizontalPadding,
          bottomInsetVp: this.bottomInsetVp
        })
          .layoutWeight(1)
      } else {
        ClassicScanPanelView({
          vm: this.vm,
          horizontalPadding: this.horizontalPadding,
          bottomInsetVp: this.bottomInsetVp
        })
          .layoutWeight(1)
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(YoColor.BACKGROUND_PRIMARY)
    .clip(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }
}
