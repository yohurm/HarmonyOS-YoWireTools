import { SppDeviceListView } from './SppDeviceListView';
import { SppActiveSessionItem, SppMainViewModel } from '../../viewmodel/SppMainViewModel';

/**
 * SPP 活动连接轨。
 * 与 ClassicScanPanelView（经典 Inquiry）完全解耦。
 * 行点击 → Terminal；尾部断开按钮可选。
 */
@ComponentV2
export struct SppActivePanelView {
  @Param @Require vm: SppMainViewModel;
  @Param horizontalPadding: number = 16;
  @Param bottomInsetVp: number = 0;
  @Event onOpenTerminal: (sessionId: string) => void = (_sessionId: string) => {
  };

  build() {
    Column() {
      Row({ space: 8 }) {
        Button($r('app.string.bt_spp_action_listen'))
          .onClick(() => {
            void this.vm.startListen();
          })
        Button($r('app.string.bt_spp_action_listen_stop'))
          .onClick(() => {
            void this.vm.stopListen();
          })
      }
      .width('100%')
      .padding({ left: this.horizontalPadding, right: this.horizontalPadding })
      if (this.vm.listenPhase === 1) {
        Text($r('app.string.bt_spp_listen_waiting'))
          .fontSize(14)
          .width('100%')
          .padding({ left: this.horizontalPadding, right: this.horizontalPadding })
      }
      if (this.vm.listenPhase === 2) {
        Text($r('app.string.bt_spp_listen_accepted'))
          .fontSize(14)
          .width('100%')
          .padding({ left: this.horizontalPadding, right: this.horizontalPadding })
      }
      if (this.vm.listenError.length > 0) {
        Text(this.vm.listenError)
          .fontSize(14)
          .fontColor(Color.Red)
          .width('100%')
          .padding({ left: this.horizontalPadding, right: this.horizontalPadding })
      }
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
      onSessionTap: (item: SppActiveSessionItem) => {
        this.onOpenTerminal(item.sessionId);
      },
      onSessionDisconnect: (item: SppActiveSessionItem) => {
        void this.vm.disconnectSession(item.sessionId);
      }
    })
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
