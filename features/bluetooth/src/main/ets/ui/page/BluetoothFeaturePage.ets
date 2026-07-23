import {
  ContentStateHost,
  LoadingStateModel,
  ModeEntryCard,
  UiColor,
  UiPageState,
  UiResponsive,
  UiSpace,
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
    Column({ space: UiSpace.M }) {
      Text($r('app.string.bt_entry_section_title'))
        .fontSize(UiTypeStyle.SUBTITLE_S.size)
        .fontWeight(UiTypeStyle.SUBTITLE_S.weight)
        .fontColor(UiColor.TEXT_SECONDARY)
        .width('100%')
      Row({ space: UiSpace.M }) {
        ModeEntryCard({
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
          .constraintSize({ minHeight: 108 })
        ModeEntryCard({
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
          .constraintSize({ minHeight: 108 })
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)
    }
    .width('100%')
  }
}
