import {
  YoActionButton,
  YoActionButtonKind,
  YoCardToken,
  YoColor,
  YoEmpty,
  YoEmptyStateModel,
  YoError,
  YoListToken,
  YoSpace,
  YoStatusPill,
  YoTypeStyle
} from 'youi_kit';
import { WifiAccessPointRowModel, WifiOverviewViewModel } from '../../viewmodel/WifiOverviewViewModel';
import { WifiAccessPointRow } from '../component/WifiAccessPointRow';
import { WifiOverviewCopy } from '../copy/WifiOverviewCopy';

@ComponentV2
export struct WifiOverviewContentView {
  @Param @Require vm: WifiOverviewViewModel;

  build() {
    Column({ space: YoSpace.XL }) {
      this.statusCard()
      if (this.vm.permissionGranted) {
        this.linkCard()
        YoActionButton({
          label: $r('app.string.wifi_action_scan'),
          kind: YoActionButtonKind.PRIMARY,
          isEnabled: this.vm.wifiActive && !this.vm.scanInFlight,
          loading: this.vm.scanInFlight,
          disabledReason: this.vm.wifiActive ? '' : $r('app.string.wifi_action_scan_disabled_off'),
          onTap: () => {
            void this.vm.scan();
          }
        })
        if (this.vm.scanErrorCode.length > 0) {
          YoError({
            model: WifiOverviewCopy.scanError(this.vm.scanErrorCode),
            onRetry: () => {
              void this.vm.scan();
            }
          })
        }
        Text($r('app.string.wifi_section_aps'))
          .fontSize(YoTypeStyle.SUBTITLE_S.size)
          .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
        if (this.vm.accessPoints.length === 0) {
          Column() {
            YoEmpty({
              model: new YoEmptyStateModel(
                $r('app.string.wifi_ap_empty_title'),
                $r('app.string.wifi_ap_empty_message')
              )
            })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
        } else {
          List({ space: YoListToken.ITEM_GAP }) {
            ForEach(this.vm.accessPoints, (ap: WifiAccessPointRowModel, index: number) => {
              ListItem() {
                WifiAccessPointRow({
                  ssid: ap.ssid,
                  channel: ap.channel,
                  securityType: ap.securityType,
                  rssi: ap.rssi,
                  showDivider: index < this.vm.accessPoints.length - 1
                })
              }
            }, (ap: WifiAccessPointRowModel) => ap.id)
          }
          .width('100%')
          .layoutWeight(1)
          .borderRadius(YoCardToken.RADIUS)
          .clip(true)
          .backgroundColor(YoCardToken.BACKGROUND)
          .scrollBar(BarState.Auto)
        }
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
        $r('app.string.wifi_status_radio'),
        this.vm.wifiActive ? $r('app.string.wifi_status_on') : $r('app.string.wifi_status_off'),
        this.vm.wifiActive ? 'success' : 'warning'
      )
      this.statusCell(
        $r('app.string.wifi_status_permission'),
        this.vm.permissionGranted ? $r('app.string.wifi_status_granted') : $r('app.string.wifi_status_denied'),
        this.vm.permissionGranted ? 'success' : 'warning'
      )
      this.statusCell(
        $r('app.string.wifi_status_bssid'),
        this.vm.peersMacGranted ? $r('app.string.wifi_status_bssid_visible') : $r('app.string.wifi_status_bssid_hidden'),
        this.vm.peersMacGranted ? 'success' : 'neutral'
      )
    }
    .width('100%')
    .padding(YoCardToken.PADDING_COMPACT)
    .backgroundColor(YoCardToken.BACKGROUND)
    .borderRadius(YoCardToken.RADIUS)
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  private statusCell(label: ResourceStr, value: ResourceStr, tone: 'success' | 'warning' | 'neutral') {
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

  @Builder
  private linkCard() {
    Column({ space: YoSpace.S }) {
      Text($r('app.string.wifi_section_link'))
        .fontSize(YoTypeStyle.SUBTITLE_S.size)
        .fontWeight(YoTypeStyle.SUBTITLE_S.weight)
        .fontColor(YoColor.TEXT_SECONDARY)
        .width('100%')
      if (this.vm.linkedConnected) {
        if (this.vm.linkedSsid.length > 0) {
          this.linkLine($r('app.string.wifi_label_ssid'), this.vm.linkedSsid)
        } else {
          this.linkLine($r('app.string.wifi_label_ssid'), $r('app.string.wifi_ap_hidden'))
        }
        if (this.vm.linkedBssid.length > 0) {
          this.linkLine($r('app.string.wifi_label_bssid'), this.vm.linkedBssid)
        }
        this.linkLine($r('app.string.wifi_label_rssi'), `${this.vm.linkedRssi}`)
        if (this.vm.linkedFrequency > 0) {
          this.linkLine($r('app.string.wifi_label_frequency'), `${this.vm.linkedFrequency}`)
        }
        if (this.vm.linkedLinkSpeed > 0) {
          this.linkLine($r('app.string.wifi_label_link_speed'), `${this.vm.linkedLinkSpeed}`)
        }
      } else {
        Text($r('app.string.wifi_status_disconnected'))
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
      }
    }
    .width('100%')
    .padding(YoCardToken.PADDING_COMPACT)
    .backgroundColor(YoCardToken.BACKGROUND)
    .borderRadius(YoCardToken.RADIUS)
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private linkLine(label: ResourceStr, value: ResourceStr) {
    Row({ space: YoSpace.M }) {
      Text(label)
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_TERTIARY)
        .constraintSize({ minWidth: 72 })
      Text(value)
        .fontSize(YoTypeStyle.BODY_M.size)
        .fontColor(YoColor.TEXT_PRIMARY)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .layoutWeight(1)
    }
    .width('100%')
  }
}
