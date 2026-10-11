import {
  YoActionButton,
  YoActionButtonKind,
  YoCardToken,
  YoColor,
  YoEmpty,
  YoEmptyStateModel,
  YoError,
  YoListToken,
  YoRadius,
  YoSize,
  YoSpace,
  YoStatusPill,
  YoTypeStyle
} from 'youi_kit';
import { NearLinkDevice } from '../../domain/model/NearLinkDevice';
import { NearLinkOverviewViewModel } from '../../viewmodel/NearLinkOverviewViewModel';
import { NearLinkDeviceRow } from '../component/NearLinkDeviceRow';
import { NearLinkOverviewCopy } from '../copy/NearLinkOverviewCopy';

@ComponentV2
export struct NearLinkOverviewContentView {
  @Param @Require vm: NearLinkOverviewViewModel;

  build() {
    Column({ space: YoSpace.XL }) {
      this.statusCard()
      if (!this.vm.supported) {
        Text($r('app.string.nl_unsupported_message'))
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
      }
      TextInput({
        text: this.vm.deviceNameFilter,
        placeholder: $r('app.string.nl_filter_placeholder')
      })
        .width('100%')
        .height(YoSize.BUTTON_HEIGHT_COMPACT)
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_PRIMARY)
        .placeholderColor(YoColor.TEXT_TERTIARY)
        .backgroundColor(YoColor.SURFACE_INPUT)
        .borderRadius(YoRadius.SMALL)
        .padding({ left: YoSpace.M, right: YoSpace.M })
        .enabled(!this.vm.isScanning())
        .onChange((value: string) => {
          this.vm.setDeviceNameFilter(value);
        })
      YoActionButton({
        label: this.vm.isScanning() ? $r('app.string.nl_action_stop') : $r('app.string.nl_action_scan'),
        kind: this.vm.isScanning() ? YoActionButtonKind.SECONDARY : YoActionButtonKind.PRIMARY,
        isEnabled: this.vm.isScanning() || this.vm.canStartScan(),
        disabledReason: this.vm.scanDisabledReason(),
        onTap: () => {
          if (this.vm.isScanning()) {
            void this.vm.stopScan();
          } else {
            void this.vm.startScan();
          }
        }
      })
      if (this.vm.scanErrorCode.length > 0) {
        YoError({
          model: NearLinkOverviewCopy.scanError(this.vm.scanErrorCode),
          onRetry: () => {
            void this.vm.startScan();
          }
        })
      }
      Text($r('app.string.nl_section_devices'))
        .fontSize(YoTypeStyle.SUBTITLE_S.size)
        .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      if (this.vm.devices.length === 0) {
        Column() {
          if (this.vm.isScanning()) {
            YoEmpty({
              model: new YoEmptyStateModel(
                $r('app.string.nl_empty_title'),
                $r('app.string.nl_empty_scanning')
              )
            })
          } else {
            YoEmpty({
              model: new YoEmptyStateModel(
                $r('app.string.nl_empty_title'),
                $r('app.string.nl_empty_message')
              )
            })
          }
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Center)
      } else {
        List({ space: YoListToken.ITEM_GAP }) {
          ForEach(this.vm.devices, (device: NearLinkDevice, index: number) => {
            ListItem() {
              NearLinkDeviceRow({
                displayName: device.effectiveName,
                address: device.randomAddress,
                rssi: device.rssi,
                rssiValid: device.rssiValid,
                connectable: device.connectable,
                favorite: device.favorite,
                showDivider: index < this.vm.devices.length - 1
              })
            }
          }, (device: NearLinkDevice) => device.randomAddress)
        }
        .width('100%')
        .layoutWeight(1)
        .borderRadius(YoCardToken.RADIUS)
        .clip(true)
        .backgroundColor(YoCardToken.BACKGROUND)
        .scrollBar(BarState.Auto)
      }
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private statusCard() {
    Row({ space: YoSpace.M }) {
      this.statusCell(
        $r('app.string.nl_status_support'),
        this.vm.supported ? $r('app.string.nl_status_supported') : $r('app.string.nl_status_unsupported'),
        this.vm.supported ? 'success' : 'warning'
      )
      this.statusCell(
        $r('app.string.nl_status_switch'),
        this.vm.switchOn ? $r('app.string.nl_status_on') : $r('app.string.nl_status_off'),
        this.vm.switchOn ? 'success' : 'warning'
      )
      this.statusCell(
        $r('app.string.nl_status_permission'),
        this.vm.permissionGranted ? $r('app.string.nl_status_granted') : $r('app.string.nl_status_denied'),
        this.vm.permissionGranted ? 'success' : 'warning'
      )
    }
    .width('100%')
    .padding(YoCardToken.PADDING_COMPACT)
    .backgroundColor(YoCardToken.BACKGROUND)
    .borderRadius(YoCardToken.RADIUS)
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  private statusCell(label: ResourceStr, value: ResourceStr, tone: 'success' | 'warning') {
    Column({ space: YoSpace.XS }) {
      Text(label)
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_TERTIARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')
      YoStatusPill({ label: value, tone: tone })
    }
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Start)
  }
}
