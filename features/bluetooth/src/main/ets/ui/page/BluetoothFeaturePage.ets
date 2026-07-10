import {
  ContentStateHost,
  LoadingStateModel,
  ModeEntryCard,
  UiColor,
  UiPageState,
  UiResponsive,
  UiTypeStyle,
  YoNavDestinationKind,
  YoPageShell
} from 'common_ui';
import { PermissionScenario, PermissionScenarioCoordinator } from 'feature_debug_core';
import { BtStatusCard } from '../component/BtStatusCard';
import { BtOverviewViewModel } from '../../viewmodel/BtOverviewViewModel';

@ComponentV2
export struct BluetoothFeaturePage {
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

  private resolvePageState(): UiPageState {
    if (this.vm.isLoading) {
      return UiPageState.LOADING;
    }
    if (!this.vm.permissionGranted) {
      return UiPageState.PERMISSION;
    }
    return UiPageState.CONTENT;
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
    ContentStateHost({
      state: this.resolvePageState(),
      loadingModel: new LoadingStateModel($r('app.string.ui_loading_default_message')),
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
    Column({ space: UiResponsive.SECTION_GAP }) {
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
    Column({ space: UiResponsive.CONTROL_GAP }) {
      Text($r('app.string.bt_entry_section_title'))
        .fontSize(UiTypeStyle.SUBTITLE_M.size)
        .fontWeight(UiTypeStyle.SUBTITLE_M.weight)
        .fontColor(UiColor.TEXT_PRIMARY)
        .width('100%')
      ModeEntryCard({
        title: $r('app.string.bt_entry_spp_title'),
        description: $r('app.string.bt_entry_spp_subtitle'),
        statusLabel: this.vm.isClassicReady() ?
          $r('app.string.bt_entry_status_ready') : $r('app.string.bt_entry_status_blocked'),
        statusTone: this.vm.isClassicReady() ? 'success' : 'warning',
        primaryLabel: $r('app.string.ui_session_enter'),
        disabled: !this.vm.isClassicReady(),
        onPrimary: () => {
          this.onOpenSpp();
        }
      })
      ModeEntryCard({
        title: $r('app.string.bt_entry_ble_title'),
        description: $r('app.string.bt_entry_ble_subtitle'),
        statusLabel: this.vm.isBleReady() ?
          $r('app.string.bt_entry_status_ready') : $r('app.string.bt_entry_status_blocked'),
        statusTone: this.vm.isBleReady() ? 'success' : 'warning',
        primaryLabel: $r('app.string.ui_session_enter'),
        disabled: !this.vm.isBleReady(),
        onPrimary: () => {
          this.onOpenBle();
        }
      })
    }
    .width('100%')
  }
}
