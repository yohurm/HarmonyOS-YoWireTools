import {
  UiColorToken,
  UiSpacing,
  UiTypography,
  YoNavDestinationKind,
  YoPageShell,
  YoSplitScaffold
} from 'common_ui';
import { BtStatusCard } from '../component/BtStatusCard';
import { BtOverviewViewModel } from '../../viewmodel/BtOverviewViewModel';

@Builder
function bluetoothListPane() {
  Column() {
    Text('Bluetooth device list placeholder')
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(UiColorToken.TEXT_SECONDARY)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

@Builder
function bluetoothDetailPane() {
  Column() {
    Text('Bluetooth device detail placeholder')
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(UiColorToken.TEXT_SECONDARY)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

@ComponentV2
export struct BluetoothFeaturePage {
  @Local private vm: BtOverviewViewModel = new BtOverviewViewModel();

  aboutToAppear(): void {
    void this.vm.onPageAppear();
  }

  aboutToDisappear(): void {
    this.vm.onPageDisappear();
  }

  @LocalBuilder
  pageContent() {
    Column({ space: UiSpacing.SECTION_GAP }) {
      BtStatusCard({
        isLoading: this.vm.isLoading,
        adapterEnabled: this.vm.adapterEnabled,
        permissionGranted: this.vm.permissionGranted,
        classicReady: this.vm.isClassicReady(),
        bleReady: this.vm.isBleReady(),
        classicSupported: this.vm.classicSupported,
        bleSupported: this.vm.bleSupported,
        onPermissionAction: () => {
          void this.vm.requestPermission();
        },
        onAdapterAction: () => {
          void this.vm.openBluetoothSettings();
        }
      })
      Column() {
        YoSplitScaffold({
          listPane: bluetoothListPane,
          detailPane: bluetoothDetailPane
        })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_title_overview'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      immersiveTitleBar: true,
      content: this.pageContent
    })
  }
}
