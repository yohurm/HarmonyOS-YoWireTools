import {
  LifecycleCoordinator
} from 'common_platform';
import {
  EnsurePermissionUseCase,
  PermissionScenario
} from 'debug_core';
import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import {
  BleGattReconnectCoordinator,
  BluetoothRepository,
  SppReconnectCoordinator
} from 'yobluetooth';

@ComponentV2
export struct BluetoothDiagnosticsPage {
  @Event onBack: () => void = () => {
  };
  @Local keepBackground: boolean = false;
  @Local statusText: string = '';
  @Local bleFailures: number = 0;
  @Local sppFailures: number = 0;
  @Local serviceStopped: boolean = false;
  private readonly ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase();

  aboutToAppear(): void {
    this.refreshCounts();
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
      if (this.serviceStopped) {
        Text($r('app.string.bt_error_service_stopped'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      Text(`${this.bleFailures}`)
        .fontSize(YoTypeStyle.BODY_M.size)
      Text(`${this.sppFailures}`)
        .fontSize(YoTypeStyle.BODY_M.size)
      if (this.statusText.length > 0) {
        Text(this.statusText)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
          .width('100%')
      }
      YoActionButton({
        label: $r('app.string.bt_diagnostics_stop_reconnect'),
        kind: YoActionButtonKind.DANGER,
        onTap: () => {
          BleGattReconnectCoordinator.getInstance().stopAutoReconnect();
          SppReconnectCoordinator.getInstance().stopAutoReconnect();
          this.refreshCounts();
        }
      })
      YoActionButton({
        label: this.keepBackground ?
          $r('app.string.bt_diagnostics_background_off') :
          $r('app.string.bt_diagnostics_background_on'),
        kind: YoActionButtonKind.PRIMARY,
        onTap: () => {
          void this.toggleBackground();
        }
      })
    }
    .width('100%')
  }

  private refreshCounts(): void {
    this.bleFailures = BleGattReconnectCoordinator.getInstance().failCount();
    this.sppFailures = SppReconnectCoordinator.getInstance().failureCount();
    this.serviceStopped = BluetoothRepository.getInstance().isServiceStopped();
    const last = BleGattReconnectCoordinator.getInstance().lastFailureReason();
    if (last.length > 0) {
      this.statusText = last;
    }
  }

  private async toggleBackground(): Promise<void> {
    if (this.keepBackground) {
      this.keepBackground = false;
      LifecycleCoordinator.getInstance().configureBackgroundSettings(false, false);
      return;
    }
    const granted = await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_BACKGROUND);
    if (!granted.granted) {
      this.statusText = 'KEEP_BACKGROUND_RUNNING';
      this.keepBackground = false;
      return;
    }
    this.keepBackground = true;
    LifecycleCoordinator.getInstance().configureBackgroundSettings(true, false);
  }
}
