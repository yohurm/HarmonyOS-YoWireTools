import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoContentState,
  YoEmpty,
  YoError,
  YoNavDestinationKind,
  YoPageShell,
  YoPageState,
  YoSegmentButton,
  YoSize,
  YoSpace,
  YoSplitScaffold,
  YoStatusPill,
  YoTypeStyle
} from 'youi_kit';
import { NearLinkDevice } from '../../domain/model/NearLinkDevice';
import { NearLinkDestination, NearLinkScanUiPhase } from '../../domain/model/NearLinkScreenCategory';
import { NearLinkDebugModel } from '../state/NearLinkDebugModel';
import { NearLinkDetailBody } from './NearLinkDetailView';

@ComponentV2
export struct NearLinkScanView {
  @Param @Require vm: NearLinkDebugModel;
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();
  @Local sheetOpen: boolean = false;

  @LocalBuilder
  pageContent() {
    if (this.vm.permissionAsked && !this.vm.permissionGranted) {
      YoContentState({
        state: YoPageState.PERMISSION,
        permissionState: this.vm.permissionUi,
        content: this.scanBody,
        onRequestPermission: () => {
          void this.vm.startScan();
        },
        onOpenSettings: () => {
          void this.vm.openAppSettings();
        }
      })
    } else {
      this.scanBody()
    }
  }

  @LocalBuilder
  scanBody() {
    Column({ space: YoSpace.S }) {
      Row({ space: YoSpace.S }) {
        YoStatusPill({ label: this.phaseLabel(), tone: this.phaseTone() })
        if (this.vm.filterUuidEnabled) {
          YoStatusPill({ label: $r('app.string.nl_local_filter'), tone: 'warning' })
        }
        if (this.vm.rssiFilterMode === 'local') {
          YoStatusPill({ label: $r('app.string.nl_local_post'), tone: 'warning' })
        } else if (this.vm.rssiFilterMode === 'system') {
          YoStatusPill({ label: $r('app.string.nl_system_rssi'), tone: 'info' })
        }
      }
      .width('100%')
      if (this.vm.filterScanAll && this.vm.versionSince.length > 0 && this.vm.scanPhase === NearLinkScanUiPhase.FAILED) {
        Text($r('app.string.nl_version_unavailable'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
        Text(this.vm.versionSince)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
      } else if (this.vm.filterScanAll && this.vm.scanPhase === NearLinkScanUiPhase.SCANNING) {
        Text($r('app.string.nl_scan_all_power'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
      }
      if (this.vm.scanPhase === NearLinkScanUiPhase.FAILED) {
        YoError({
          model: this.vm.supportError(),
          onRetry: () => {
            void this.vm.startScan();
          }
        })
        Text(this.vm.filterLabel())
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
        if (this.vm.nativeCode.length > 0) {
          Text(this.vm.nativeCode)
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.ERROR)
        }
      }
      YoActionButton({
        label: this.vm.scanPhase === NearLinkScanUiPhase.SCANNING ? $r('app.string.nl_scan_stop') : $r('app.string.nl_scan_start'),
        kind: YoActionButtonKind.PRIMARY,
        loading: this.vm.scanBusy,
        isEnabled: this.vm.scanEntryEnabled() || this.vm.scanPhase === NearLinkScanUiPhase.SCANNING,
        disabledReason: this.vm.radioLabel(),
        onTap: () => {
          if (this.vm.scanPhase === NearLinkScanUiPhase.SCANNING) {
            void this.vm.stopScan();
          } else {
            void this.vm.startScan();
          }
        }
      })
      YoActionButton({
        label: $r('app.string.nl_filter'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          this.sheetOpen = true;
        }
      })
      YoSplitScaffold({
        listPane: this.listPane,
        detailPane: this.detailPane
      })
    }
    .width('100%')
    .height('100%')
    .bindSheet(this.sheetOpen, this.filterSheet(), {
      height: SheetSize.LARGE,
      onDisappear: () => {
        this.sheetOpen = false;
      }
    })
  }

  @LocalBuilder
  listPane() {
    if (this.vm.devices.length === 0 && this.vm.scanPhase !== NearLinkScanUiPhase.FAILED) {
      YoEmpty({ model: this.vm.scanEmpty() })
    } else {
      List({ space: YoSpace.S }) {
        ForEach(this.vm.devices, (item: NearLinkDevice) => {
          ListItem() {
            Column({ space: YoSpace.XS }) {
              Text(item.effectiveName.length > 0 ? item.effectiveName : item.randomAddress)
                .fontSize(YoTypeStyle.SUBTITLE_S.size)
                .fontColor(YoColor.TEXT_PRIMARY)
                .maxLines(1)
              Row({ space: YoSpace.S }) {
                Text(item.randomAddress)
                  .fontSize(YoTypeStyle.BODY_S.size)
                  .fontColor(YoColor.TEXT_SECONDARY)
                YoStatusPill({ label: $r('app.string.nl_random_address'), tone: 'neutral' })
                if (!item.rssiValid) {
                  YoStatusPill({ label: $r('app.string.nl_rssi_invalid'), tone: 'warning' })
                } else {
                  Text(`${item.rssi}`)
                    .fontSize(YoTypeStyle.BODY_S.size)
                    .fontColor(YoColor.TEXT_SECONDARY)
                }
                if (item.belowLocalRssiGate) {
                  YoStatusPill({ label: $r('app.string.nl_below_gate'), tone: 'warning' })
                }
                if (item.deviceClass.length > 0) {
                  Text(item.deviceClass)
                    .fontSize(YoTypeStyle.BODY_S.size)
                    .fontColor(YoColor.TEXT_SECONDARY)
                }
              }
              .width('100%')
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .constraintSize({ minHeight: YoSize.LIST_CARD_HEIGHT })
            .padding(YoSpace.S)
            .onClick(() => {
              this.vm.selectDevice(item.randomAddress);
              if (!WindowWidthBreakpointUtil.isSplitCapable(this.metrics.breakpoint)) {
                this.vm.open(NearLinkDestination.DETAIL);
              }
            })
          }
        }, (item: NearLinkDevice) => item.randomAddress)
      }
      .width('100%')
      .layoutWeight(1)
    }
  }

  @LocalBuilder
  detailPane() {
    if (this.vm.selectedAddress.length === 0) {
      YoEmpty({ model: this.vm.scanEmpty() })
      Text($r('app.string.nl_pick_device'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
    } else {
      NearLinkDetailBody({ vm: this.vm })
    }
  }

  @Builder
  filterSheet() {
    Column({ space: YoSpace.S }) {
      YoStatusPill({ label: $r('app.string.nl_uuid_gap'), tone: 'warning' })
      Text($r('app.string.nl_filter_or'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
      Text($r('app.string.nl_filter_and'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
      Text($r('app.string.nl_duration_hint'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
      YoSegmentButton({
        labels: [$r('app.string.nl_mode_low'), $r('app.string.nl_mode_balanced')],
        initialIndex: this.vm.scanModeIndex,
        onSelectedIndexChange: (index: number) => {
          if (this.vm.scanPhase !== NearLinkScanUiPhase.SCANNING) {
            this.vm.scanModeIndex = index;
          }
        }
      })
      if (this.vm.scanPhase === NearLinkScanUiPhase.SCANNING) {
        Text($r('app.string.nl_stop_before_mode'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
      }
      TextInput({ text: this.vm.filterAddress, placeholder: $r('app.string.nl_address') })
        .onChange((value: string) => {
          this.vm.filterAddress = value;
        })
      TextInput({ text: this.vm.filterName, placeholder: $r('app.string.nl_name') })
        .onChange((value: string) => {
          this.vm.filterName = value;
        })
      TextInput({ text: this.vm.filterManufacturerId, placeholder: $r('app.string.nl_manufacturer_id') })
        .onChange((value: string) => {
          this.vm.filterManufacturerId = value;
        })
      TextInput({ text: this.vm.filterManufacturerData, placeholder: $r('app.string.nl_manufacturer') })
        .onChange((value: string) => {
          this.vm.filterManufacturerData = value;
        })
      TextInput({ text: this.vm.filterManufacturerMask, placeholder: $r('app.string.nl_mask') })
        .onChange((value: string) => {
          this.vm.filterManufacturerMask = value;
        })
      TextInput({ text: this.vm.filterRssi, placeholder: $r('app.string.nl_rssi_gate') })
        .onChange((value: string) => {
          this.vm.filterRssi = value;
        })
      TextInput({ text: this.vm.filterDuration, placeholder: $r('app.string.nl_duration') })
        .onChange((value: string) => {
          this.vm.filterDuration = value;
        })
      TextInput({ text: this.vm.filterUuid, placeholder: $r('app.string.nl_local_uuid') })
        .onChange((value: string) => {
          this.vm.filterUuid = value;
        })
      Row({ space: YoSpace.S }) {
        Toggle({ type: ToggleType.Switch, isOn: this.vm.filterUuidEnabled })
          .onChange((on: boolean) => {
            this.vm.filterUuidEnabled = on;
          })
        Text($r('app.string.nl_local_filter'))
          .fontSize(YoTypeStyle.BODY_S.size)
      }
      Row({ space: YoSpace.S }) {
        Toggle({ type: ToggleType.Switch, isOn: this.vm.filterScanAll })
          .onChange((on: boolean) => {
            this.vm.filterScanAll = on;
          })
        Text($r('app.string.nl_scan_all'))
          .fontSize(YoTypeStyle.BODY_S.size)
      }
      YoActionButton({
        label: $r('app.string.nl_filter_confirm'),
        onTap: () => {
          void this.vm.confirmFilter();
          this.sheetOpen = false;
        }
      })
      YoActionButton({
        label: $r('app.string.nl_close'),
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          this.sheetOpen = false;
        }
      })
    }
    .padding(YoSpace.M)
    .width('100%')
  }

  build() {
    YoPageShell({
      title: $r('app.string.nl_title_scan'),
      destinationKind: YoNavDestinationKind.MODULE,
      showBack: true,
      scrollable: false,
      contentEdgeToEdge: true,
      content: this.pageContent,
      onBack: () => {
        this.vm.back();
      }
    })
  }

  private phaseLabel(): ResourceStr {
    if (this.vm.scanPhase === NearLinkScanUiPhase.SCANNING) {
      return $r('app.string.nl_scan_running');
    }
    if (this.vm.scanPhase === NearLinkScanUiPhase.STOPPED) {
      return $r('app.string.nl_scan_stopped');
    }
    if (this.vm.scanPhase === NearLinkScanUiPhase.FAILED) {
      return $r('app.string.nl_scan_fail');
    }
    return $r('app.string.nl_scan_idle');
  }

  private phaseTone(): 'success' | 'warning' | 'info' | 'neutral' {
    if (this.vm.scanPhase === NearLinkScanUiPhase.SCANNING) {
      return 'info';
    }
    if (this.vm.scanPhase === NearLinkScanUiPhase.FAILED) {
      return 'warning';
    }
    return 'neutral';
  }
}
