import { SppDeviceListView } from './SppDeviceListView';
import { SppActiveSessionItem, SppMainViewModel } from '../../viewmodel/SppMainViewModel';

/**
 * Active-connection rail only.
 * No scan filter panel — fully decoupled from SppScanPanelView.
 */
@ComponentV2
export struct SppActivePanelView {
  @Param @Require vm: SppMainViewModel;
  @Param horizontalPadding: number = 16;
  @Param bottomInsetVp: number = 0;

  build() {
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
      .width('100%')
      .height('100%')
  }
}
