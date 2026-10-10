import { LengthMetrics } from '@kit.ArkUI';
import { RadioSwitchReading } from 'debug_core';
import {
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoStatusPill
} from 'youi_kit';
import { WorkbenchStatusText } from '../../viewmodel/WorkbenchStatusText';
import { WorkbenchViewModel } from '../../viewmodel/WorkbenchViewModel';

/** Workbench root tab. Capability readings only. Deep debug stays in each feature tab. */
@ComponentV2
export struct HomeFeaturePage {
  @Event onOpenModule: (moduleId: string) => void = (_moduleId: string) => {
  };
  @Event onOpenAppSettings: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };
  @Param bluetoothReading: string = RadioSwitchReading.UNREAD;
  @Param wlanReading: string = RadioSwitchReading.UNREAD;
  @Param nearlinkReading: string = RadioSwitchReading.UNREAD;
  @Local vm: WorkbenchViewModel = new WorkbenchViewModel();

  aboutToAppear(): void {
    this.vm.bindCapability(this.bluetoothReading, this.wlanReading, this.nearlinkReading);
    void this.vm.refreshCounts();
  }

  @Monitor('bluetoothReading', 'wlanReading', 'nearlinkReading')
  onCapabilityChange(): void {
    this.vm.bindCapability(this.bluetoothReading, this.wlanReading, this.nearlinkReading);
  }

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.L }) {
      Flex({ wrap: FlexWrap.Wrap, space: { main: LengthMetrics.vp(YoSpace.S), cross: LengthMetrics.vp(YoSpace.S) } }) {
        YoStatusPill({
          label: WorkbenchStatusText.label($r('app.string.home_capsule_bluetooth'), this.vm.bluetoothReading),
          tone: WorkbenchStatusText.tone(this.vm.bluetoothReading)
        })
        YoStatusPill({
          label: WorkbenchStatusText.label($r('app.string.home_capsule_wlan'), this.vm.wlanReading),
          tone: WorkbenchStatusText.tone(this.vm.wlanReading)
        })
        YoStatusPill({
          label: WorkbenchStatusText.label($r('app.string.home_capsule_nearlink'), this.vm.nearlinkReading),
          tone: WorkbenchStatusText.tone(this.vm.nearlinkReading)
        })
      }
      .width('100%')
      Button($r('app.string.home_open_settings'), {
        type: ButtonType.Normal,
        buttonStyle: ButtonStyleMode.TEXTUAL,
        role: ButtonRole.NORMAL
      })
        .onClick(() => {
          this.onOpenAppSettings();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.home_title'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: true,
      content: this.pageContent
    })
  }
}
