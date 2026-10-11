import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { BluetoothDiagnosticsViewModel } from '../../viewmodel/BluetoothDiagnosticsViewModel';

@ComponentV2
export struct BluetoothDiagnosticsPage {
  @Event onBack: () => void = () => {
  };
  @Local private vm: BluetoothDiagnosticsViewModel = new BluetoothDiagnosticsViewModel();

  aboutToAppear(): void {
    this.vm.refreshCounts();
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_diagnostics_title'),
      showBack: true,
      destinationKind: YoNavDestinationKind.MODULE,
      onBack: this.onBack,
      content: this.body
    })
  }

  @LocalBuilder
  body() {
    Column({ space: YoSpace.M }) {
      Text($r('app.string.bt_diagnostics_no_hci'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      Text($r('app.string.bt_diagnostics_release_hci'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      Text($r('app.string.bt_error_too_frequent'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_TERTIARY)
        .width('100%')
      Text($r('app.string.bt_diagnostics_background_suspend'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      if (this.vm.serviceStopped) {
        Text($r('app.string.bt_error_service_stopped'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      Text(`${this.vm.bleFailures}`)
        .fontSize(YoTypeStyle.BODY_M.size)
      Text(`${this.vm.sppFailures}`)
        .fontSize(YoTypeStyle.BODY_M.size)
      if (this.vm.statusText.length > 0) {
        Text(this.vm.statusText)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      YoActionButton({
        label: $r('app.string.bt_diagnostics_stop_reconnect'),
        kind: YoActionButtonKind.DANGER,
        onTap: () => {
          this.vm.stopReconnect();
        }
      })
      YoActionButton({
        label: this.vm.keepBackground ?
          $r('app.string.bt_diagnostics_background_off') :
          $r('app.string.bt_diagnostics_background_on'),
        kind: YoActionButtonKind.PRIMARY,
        onTap: () => {
          void this.vm.toggleBackground();
        }
      })
    }
    .width('100%')
  }
}
