import { SppDeviceListView } from './SppDeviceListView';
import { SppScanFilterPanelView } from './SppScanFilterPanelView';
import { SppDeviceListItem, SppMainViewModel } from '../../viewmodel/SppMainViewModel';

/**
 * Scan rail only: optional filter panel + device list.
 * Decoupled from the active-connection rail.
 */
@ComponentV2
export struct SppScanPanelView {
  @Param @Require vm: SppMainViewModel;
  @Param horizontalPadding: number = 16;
  @Param bottomInsetVp: number = 0;

  build() {
    Column({ space: 0 }) {
      if (this.vm.filterPanelExpanded) {
        Column() {
          SppScanFilterPanelView({ vm: this.vm })
        }
        .width('100%')
        .padding({
          left: this.horizontalPadding,
          right: this.horizontalPadding,
          bottom: 8
        })
        .transition(TransitionEffect.OPACITY.animation({ duration: 150, curve: Curve.EaseOut }))
      }

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
    .width('100%')
    .height('100%')
  }
}
