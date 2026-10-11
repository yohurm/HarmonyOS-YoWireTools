import {
  YoColor,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoStatusPill,
  YoTypeStyle
} from 'youi_kit';
import { NearLinkConstants } from '../../constants/NearLinkConstants';
import { NearLinkDebugModel } from '../state/NearLinkDebugModel';

@ComponentV2
export struct NearLinkCdsmView {
  @Param @Require vm: NearLinkDebugModel;

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.S }) {
      YoStatusPill({ label: $r('app.string.nl_cdsm_gap'), tone: 'warning' })
      Text(`${NearLinkConstants.NATIVE_CDSM_UNSUPPORTED}`)
        .fontSize(YoTypeStyle.BODY_M.size)
        .fontColor(YoColor.ERROR)
      Text($r('app.string.nl_cdsm_gap'))
        .fontSize(YoTypeStyle.BODY_M.size)
        .fontColor(YoColor.TEXT_PRIMARY)
      Text($r('app.string.nl_cdsm_next'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.nl_title_cdsm'),
      destinationKind: YoNavDestinationKind.MODULE,
      showBack: true,
      content: this.pageContent,
      onBack: () => {
        this.vm.back();
      }
    })
  }
}
