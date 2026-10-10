import {
  YoColor,
  YoContentState,
  YoModeEntryCard,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoStatusPill,
  YoTypeStyle
} from 'youi_kit';
import { NearLinkDestination, NearLinkRadioCategory, NearLinkSupportCategory } from '../../domain/model/NearLinkScreenCategory';
import { NearLinkDebugModel } from '../state/NearLinkDebugModel';

@ComponentV2
export struct NearLinkRootView {
  @Param @Require vm: NearLinkDebugModel;

  @LocalBuilder
  pageContent() {
    YoContentState({
      state: this.vm.pageState,
      loadingModel: this.vm.loadingModel(),
      errorModel: this.vm.supportError(),
      content: this.body
    })
  }

  @LocalBuilder
  body() {
    Column({ space: YoSpace.M }) {
      Row({ space: YoSpace.S }) {
        YoStatusPill({
          label: this.vm.supportLabel(),
          tone: this.supportTone()
        })
        YoStatusPill({
          label: this.vm.radioLabel(),
          tone: this.radioTone()
        })
      }
      .width('100%')
      if (this.vm.localNameFailed) {
        Text($r('app.string.nl_local_unread'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
        Text(this.vm.nativeCode)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
      } else if (this.vm.localName.length > 0) {
        Text(this.vm.localName)
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_PRIMARY)
          .maxLines(1)
      } else {
        Text($r('app.string.nl_local_unread'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
      }
      if (this.vm.supportCategory === NearLinkSupportCategory.VERSION) {
        Text($r('app.string.nl_version_unavailable'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
        Text(this.vm.versionSince)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
      }
      if (this.vm.supportCategory === NearLinkSupportCategory.CAPABILITY) {
        Text($r('app.string.nl_not_radio_off'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
        Text(this.vm.nativeCode)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
      }
      if (this.vm.supportCategory === NearLinkSupportCategory.EMULATOR) {
        Text($r('app.string.nl_need_device'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
      }
      Text($r('app.string.nl_bluetooth_independent'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
      if (this.vm.radioCategory === NearLinkRadioCategory.OFF) {
        Text($r('app.string.nl_settings_path_a'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
        Text($r('app.string.nl_settings_path_b'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
      }
      YoModeEntryCard({
        title: $r('app.string.nl_entry_scan'),
        statusLabel: this.vm.scanEntryEnabled() ? $r('app.string.nl_radio_on') : $r('app.string.nl_querying'),
        statusTone: this.vm.scanEntryEnabled() ? 'success' : 'neutral',
        disabled: !this.vm.scanEntryEnabled(),
        disabledReason: this.vm.scanEntryEnabled() ? '' : this.vm.radioLabel(),
        onTap: () => {
          this.vm.open(NearLinkDestination.SCAN);
        }
      })
      YoModeEntryCard({
        title: $r('app.string.nl_entry_adv'),
        disabled: !this.vm.modesEnabled(),
        disabledReason: this.vm.radioLabel(),
        onTap: () => {
          this.vm.open(NearLinkDestination.ADVERTISING);
        }
      })
      YoModeEntryCard({
        title: $r('app.string.nl_entry_client'),
        disabled: !this.vm.modesEnabled(),
        disabledReason: this.vm.radioLabel(),
        onTap: () => {
          this.vm.open(NearLinkDestination.SSAP_CLIENT);
        }
      })
      YoModeEntryCard({
        title: $r('app.string.nl_entry_server'),
        disabled: !this.vm.modesEnabled(),
        disabledReason: this.vm.radioLabel(),
        onTap: () => {
          this.vm.open(NearLinkDestination.SSAP_SERVER);
        }
      })
      YoModeEntryCard({
        title: $r('app.string.nl_entry_port'),
        disabled: !this.vm.modesEnabled(),
        disabledReason: this.vm.radioLabel(),
        onTap: () => {
          this.vm.open(NearLinkDestination.PORT);
        }
      })
      YoModeEntryCard({
        title: $r('app.string.nl_entry_pair'),
        disabled: !this.vm.modesEnabled(),
        disabledReason: this.vm.radioLabel(),
        onTap: () => {
          this.vm.open(NearLinkDestination.PAIRING);
        }
      })
      YoModeEntryCard({
        title: $r('app.string.nl_entry_log'),
        onTap: () => {
          this.vm.open(NearLinkDestination.LOG);
        }
      })
      YoModeEntryCard({
        title: $r('app.string.nl_entry_cdsm'),
        statusLabel: $r('app.string.nl_cdsm_action'),
        statusTone: 'warning',
        onTap: () => {
          this.vm.open(NearLinkDestination.CDSM);
        }
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.nl_title_overview'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: true,
      content: this.pageContent
    })
  }

  private supportTone(): 'success' | 'warning' | 'error' | 'info' | 'neutral' {
    if (this.vm.supportCategory === NearLinkSupportCategory.SUPPORTED) {
      return 'success';
    }
    if (this.vm.supportCategory === NearLinkSupportCategory.EMULATOR ||
      this.vm.supportCategory === NearLinkSupportCategory.VERSION) {
      return 'warning';
    }
    if (this.vm.supportCategory === NearLinkSupportCategory.LOADING) {
      return 'info';
    }
    return 'error';
  }

  private radioTone(): 'success' | 'info' | 'neutral' {
    if (this.vm.radioCategory === NearLinkRadioCategory.ON) {
      return 'success';
    }
    if (this.vm.radioCategory === NearLinkRadioCategory.TURNING_ON ||
      this.vm.radioCategory === NearLinkRadioCategory.TURNING_OFF) {
      return 'info';
    }
    return 'neutral';
  }
}
