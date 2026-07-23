import { YoColor, YoResponsive, YoSegmentButton } from 'youi_kit';
import { SppDeviceListView } from './SppDeviceListView';
import {
  SppActiveSessionItem,
  SppDeviceListItem,
  SppMainViewModel,
  SppSegmentTab
} from '../../viewmodel/SppMainViewModel';

/**
 * SPP main content.
 *
 * Segment: official SegmentButton tab defaults.
 * Panels: if/else switch only (no Swiper page slide).
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
            $r('app.string.bt_spp_segment_scan'),
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
        SppDeviceListView({
          mode: 'active',
          sessions: this.vm.activeSessions,
          emptyTitle: this.vm.ready ?
            $r('app.string.bt_spp_empty_active_title') :
            this.vm.emptyTitle,
          emptyMessage: this.vm.ready ?
            $r('app.string.bt_spp_empty_active_message') :
            this.vm.emptyMessage,
          horizontalPadding: this.horizontalPadding,
          bottomInsetVp: this.bottomInsetVp,
          onSessionTap: (_item: SppActiveSessionItem) => {
          }
        })
          .layoutWeight(1)
      } else {
        SppDeviceListView({
          mode: 'scan',
          devices: this.vm.scanDevices,
          emptyTitle: this.vm.emptyTitle,
          emptyMessage: this.vm.emptyMessage,
          horizontalPadding: this.horizontalPadding,
          bottomInsetVp: this.bottomInsetVp,
          onDeviceConnect: (_item: SppDeviceListItem) => {
          },
          onDeviceTap: (_item: SppDeviceListItem) => {
          }
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
