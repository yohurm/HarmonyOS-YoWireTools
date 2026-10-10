import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoStatusPill,
  YoTypeStyle
} from 'youi_kit';
import { NearLinkDestination } from '../../domain/model/NearLinkScreenCategory';
import { NearLinkDebugModel } from '../state/NearLinkDebugModel';

@ComponentV2
export struct NearLinkDetailBody {
  @Param @Require vm: NearLinkDebugModel;

  build() {
    Column({ space: YoSpace.S }) {
      Text(this.vm.selectedAddress)
        .fontSize(YoTypeStyle.BODY_M.size)
        .fontColor(YoColor.TEXT_PRIMARY)
      YoStatusPill({ label: $r('app.string.nl_random_address'), tone: 'neutral' })
      Text($r('app.string.nl_identity_may_change'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
      if (this.vm.detailEmpty) {
        Text($r('app.string.nl_no_adv'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
      } else {
        Text(this.vm.detailHex)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_PRIMARY)
        Text($r('app.string.nl_complete_name'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
        Text(this.vm.detailCompleteName)
          .fontSize(YoTypeStyle.BODY_M.size)
        Text($r('app.string.nl_short_name'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
        Text(this.vm.detailShortName)
          .fontSize(YoTypeStyle.BODY_M.size)
        Text($r('app.string.nl_reported_name'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
        Text(this.vm.detailReportedName)
          .fontSize(YoTypeStyle.BODY_M.size)
        Text($r('app.string.nl_name_from_tlv'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
        if (this.vm.detailNameBytes >= 0) {
          Text($r('app.string.nl_device_info_len'))
            .fontSize(YoTypeStyle.BODY_S.size)
          Text(`${this.vm.detailNameBytes}`)
            .fontSize(YoTypeStyle.BODY_S.size)
        }
        Text(this.vm.detailServiceText)
          .fontSize(YoTypeStyle.BODY_S.size)
        Text($r('app.string.nl_manufacturer'))
          .fontSize(YoTypeStyle.BODY_S.size)
        Text(this.vm.detailManufacturerText)
          .fontSize(YoTypeStyle.BODY_S.size)
        Text($r('app.string.nl_unknown_tlv'))
          .fontSize(YoTypeStyle.BODY_S.size)
        Text(this.vm.detailUnknownText)
          .fontSize(YoTypeStyle.BODY_S.size)
      }
      if (this.vm.pairedVersionUnavailable) {
        Text($r('app.string.nl_version_unavailable'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
        Text(this.vm.versionSince)
          .fontSize(YoTypeStyle.BODY_S.size)
      } else if (this.vm.pairedMatch()) {
        Text($r('app.string.nl_already_paired'))
          .fontSize(YoTypeStyle.BODY_S.size)
      } else if (this.vm.showPairedEmpty()) {
        Text($r('app.string.nl_no_paired'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
      }
      if (this.vm.addressStale()) {
        Text($r('app.string.nl_old_address'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
      }
      if (this.vm.favoriteNote === 'saved') {
        Text($r('app.string.nl_favorite_saved'))
          .fontSize(YoTypeStyle.BODY_S.size)
        Text($r('app.string.nl_old_address'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
      }
      YoActionButton({
        label: $r('app.string.nl_favorite'),
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.saveFavorite();
        }
      })
      YoActionButton({
        label: $r('app.string.nl_entry_client'),
        isEnabled: this.vm.modesEnabled(),
        disabledReason: this.vm.radioLabel(),
        onTap: () => {
          this.vm.open(NearLinkDestination.SSAP_CLIENT);
        }
      })
      YoActionButton({
        label: $r('app.string.nl_entry_port'),
        kind: YoActionButtonKind.SECONDARY,
        isEnabled: this.vm.modesEnabled(),
        disabledReason: this.vm.radioLabel(),
        onTap: () => {
          this.vm.open(NearLinkDestination.PORT);
        }
      })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}

@ComponentV2
export struct NearLinkDetailView {
  @Param @Require vm: NearLinkDebugModel;

  @LocalBuilder
  pageContent() {
    NearLinkDetailBody({ vm: this.vm })
  }

  build() {
    YoPageShell({
      title: $r('app.string.nl_title_detail'),
      destinationKind: YoNavDestinationKind.OBJECT,
      showBack: true,
      content: this.pageContent,
      onBack: () => {
        this.vm.back();
      }
    })
  }
}
