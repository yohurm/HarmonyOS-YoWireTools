import { SppDeviceListView } from './SppDeviceListView';
import { ClassicScanFilterPanelView } from './ClassicScanFilterPanelView';
import { ClassicDeviceListItem, SppMainViewModel } from '../../viewmodel/SppMainViewModel';

/**
 * 经典蓝牙扫描轨面板（CLASSIC_SCAN rail）。
 *
 * 能力：ClassicScanFilter + Inquiry 设备列表。
 * 不属于 SPP 协议扫描；SPP 页将其作为连接候选轨消费。
 * 连接按钮 → PairingGuideDialog（未配对）/ SppConnectDialog（已配对）；非直接 ConnectSppUseCase。
 */
@ComponentV2
export struct ClassicScanPanelView {
  @Param @Require vm: SppMainViewModel;
  @Param horizontalPadding: number = 16;
  @Param bottomInsetVp: number = 0;
  @Event onOpenConnect: (item: ClassicDeviceListItem) => void = (_item: ClassicDeviceListItem) => {
  };
  @Event onOpenIdentity: (item: ClassicDeviceListItem) => void = (_item: ClassicDeviceListItem) => {
  };

  build() {
    Column({ space: 0 }) {
      if (this.vm.filterPanelExpanded) {
        Column() {
          ClassicScanFilterPanelView({ vm: this.vm })
        }
        .width('100%')
        .padding({
          left: this.horizontalPadding,
          right: this.horizontalPadding,
          bottom: 8
        })
        .transition(TransitionEffect.OPACITY.animation({ duration: 150, curve: Curve.EaseOut }))
      }

      if (this.vm.scanNotice === 'too_frequent') {
        Text($r('app.string.bt_error_too_frequent'))
          .fontSize(14)
          .fontColor(Color.Red)
          .width('100%')
          .padding({ left: this.horizontalPadding, right: this.horizontalPadding })
      } else if (this.vm.scanNotice === 'adapter_off') {
        Text($r('app.string.bt_error_adapter_off'))
          .fontSize(14)
          .fontColor(Color.Red)
          .width('100%')
          .padding({ left: this.horizontalPadding, right: this.horizontalPadding })
      } else if (this.vm.scanNotice === 'service_stopped') {
        Text($r('app.string.bt_error_service_stopped'))
          .fontSize(14)
          .fontColor(Color.Red)
          .width('100%')
          .padding({ left: this.horizontalPadding, right: this.horizontalPadding })
      } else if (this.vm.scanNotice === 'scan_resource') {
        Text($r('app.string.bt_error_scan_resource'))
          .fontSize(14)
          .fontColor(Color.Red)
          .width('100%')
          .padding({ left: this.horizontalPadding, right: this.horizontalPadding })
      } else if (this.vm.scanNotice.length > 0) {
        Text(this.vm.scanNotice)
          .fontSize(14)
          .fontColor(Color.Red)
          .width('100%')
          .padding({ left: this.horizontalPadding, right: this.horizontalPadding })
      }

      SppDeviceListView({
        mode: 'scan',
        devices: this.vm.classicScanDevices,
        emptyTitle: this.vm.emptyTitle,
        emptyMessage: this.vm.emptyMessage,
        horizontalPadding: this.horizontalPadding,
        bottomInsetVp: this.bottomInsetVp,
        onDeviceConnect: (item: ClassicDeviceListItem) => {
          this.onOpenConnect(item);
        },
        onDeviceTap: (item: ClassicDeviceListItem) => {
          this.onOpenIdentity(item);
        }
      })
        .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }
}
