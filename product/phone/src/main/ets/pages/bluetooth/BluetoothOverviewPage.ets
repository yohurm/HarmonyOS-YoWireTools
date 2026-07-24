import {
  YoContentState,
  YoLoadingStateModel,
  YoModeEntryCard,
  YoColor,
  YoPageState,
  YoResponsive,
  YoSpace,
  YoTypeStyle,
  YoNavDestinationKind,
  YoPageShell
} from 'youi_kit';
import { PermissionScenario, PermissionScenarioCoordinator } from 'debug_core';
import { BtStatusCard, BtOverviewViewModel } from 'feature_bluetooth';

/**
 * Product page shell: Bluetooth overview tab.
 */
@ComponentV2
export struct BluetoothOverviewPage {
  @Event onOpenSpp: () => void = () => {
  };
  @Event onOpenBle: () => void = () => {
  };
  @Local private vm: BtOverviewViewModel = new BtOverviewViewModel();

  aboutToAppear(): void {
    void this.vm.onPageAppear();
  }

  aboutToDisappear(): void {
    this.vm.onPageDisappear();
  }

  private resolvePageState(): YoPageState {
    if (this.vm.isLoading) {
      return YoPageState.LOADING;
    }
    if (!this.vm.permissionGranted) {
      return YoPageState.PERMISSION;
    }
    return YoPageState.CONTENT;
  }

  private async handleRequestPermission(): Promise<void> {
    await this.vm.requestPermission();
  }

  private async handleOpenSettings(): Promise<void> {
    await PermissionScenarioCoordinator.getInstance()
      .ensurePermission(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    await this.vm.refresh();
  }

  @LocalBuilder
  pageContent() {
    YoContentState({
      state: this.resolvePageState(),
      loadingModel: new YoLoadingStateModel($r('app.string.youi_loading_default_message')),
      permissionState: this.vm.permissionUiState,
      content: this.pageBody,
      onRequestPermission: () => {
        void this.handleRequestPermission();
      },
      onOpenSettings: () => {
        void this.handleOpenSettings();
      }
    })
  }

  @LocalBuilder
  pageBody() {
    Column({ space: YoResponsive.SECTION_GAP }) {
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
      this.bluetoothEntryOverview()
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

  @LocalBuilder
  bluetoothEntryOverview() {
    Column({ space: YoSpace.M }) {
      Text($r('app.string.bt_entry_section_title'))
        .fontSize(YoTypeStyle.SUBTITLE_S.size)
        .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      Row({ space: YoSpace.M }) {
        YoModeEntryCard({
          title: $r('app.string.bt_entry_spp_title'),
          description: $r('app.string.bt_entry_spp_subtitle'),
          statusLabel: this.vm.isClassicReady() ?
            $r('app.string.bt_entry_status_ready') : $r('app.string.bt_entry_status_blocked'),
          statusTone: this.vm.isClassicReady() ? 'success' : 'warning',
          disabled: !this.vm.isClassicReady(),
          onTap: () => {
            this.onOpenSpp();
          }
        })
          .layoutWeight(1)
          .constraintSize({ minHeight: 88 })
        YoModeEntryCard({
          title: $r('app.string.bt_entry_ble_title'),
          description: $r('app.string.bt_entry_ble_subtitle'),
          statusLabel: this.vm.isBleReady() ?
            $r('app.string.bt_entry_status_ready') : $r('app.string.bt_entry_status_blocked'),
          statusTone: this.vm.isBleReady() ? 'success' : 'warning',
          disabled: !this.vm.isBleReady(),
          onTap: () => {
            this.onOpenBle();
          }
        })
          .layoutWeight(1)
          .constraintSize({ minHeight: 88 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
  }
}
