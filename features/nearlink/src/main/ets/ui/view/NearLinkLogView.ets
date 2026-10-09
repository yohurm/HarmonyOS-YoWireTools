import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoEmpty,
  YoEmptyStateModel,
  YoNavDestinationKind,
  YoPageShell,
  YoSegmentButton,
  YoSize,
  YoSpace,
  YoSplitScaffold,
  YoStatusPill,
  YoTypeStyle
} from 'youi_kit';
import { NearLinkLogEntry } from '../../domain/model/NearLinkLogEntry';
import { NearLinkDebugModel } from '../state/NearLinkDebugModel';

@ComponentV2
export struct NearLinkLogView {
  @Param @Require vm: NearLinkDebugModel;

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.S }) {
      YoStatusPill({ label: $r('app.string.nl_phy_title'), tone: 'warning' })
      Text($r('app.string.nl_phy_gap'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.WARNING)
      Text($r('app.string.nl_rssi_scan_only'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
      YoStatusPill({ label: $r('app.string.nl_air_gap'), tone: 'warning' })
      YoSegmentButton({
        labels: [
          $r('app.string.nl_log_all'),
          $r('app.string.nl_log_error'),
          $r('app.string.nl_log_perm'),
          $r('app.string.nl_log_io')
        ],
        initialIndex: this.vm.logFilter,
        onSelectedIndexChange: (index: number) => {
          this.vm.logFilter = index;
        }
      })
      YoActionButton({
        label: $r('app.string.nl_export'),
        kind: YoActionButtonKind.SECONDARY,
        isEnabled: this.vm.logs.length > 0,
        disabledReason: $r('app.string.nl_export_empty'),
        onTap: () => {
          void this.vm.exportLogs();
        }
      })
      if (this.vm.exportFailed) {
        Text($r('app.string.nl_export_fail'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.ERROR)
      }
      YoSplitScaffold({
        listPane: this.listPane,
        detailPane: this.detailPane
      })
    }
    .width('100%')
    .height('100%')
  }

  @LocalBuilder
  listPane() {
    if (this.vm.visibleLogs().length === 0) {
      YoEmpty({
        model: new YoEmptyStateModel($r('app.string.nl_log_empty'), '', '', '', '')
      })
      Text($r('app.string.nl_log_empty'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
    } else {
      List() {
        ForEach(this.vm.visibleLogs(), (item: NearLinkLogEntry) => {
          ListItem() {
            Column({ space: YoSpace.XS }) {
              Text(`${item.timeMs} ${item.direction} ${item.apiName}`)
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(YoColor.TEXT_PRIMARY)
              if (item.nativeCode.length > 0) {
                YoStatusPill({ label: item.nativeCode, tone: 'error' })
              }
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .constraintSize({ minHeight: YoSize.LIST_ROW_HEIGHT })
            .onClick(() => {
              this.vm.selectedLogId = item.id;
            })
          }
        }, (item: NearLinkLogEntry) => item.id)
      }
      .width('100%')
      .layoutWeight(1)
    }
  }

  @LocalBuilder
  detailPane() {
    if (this.vm.selectedLog() === undefined) {
      Text($r('app.string.nl_log_pick'))
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
    } else {
      Column({ space: YoSpace.S }) {
        Text(this.vm.selectedLog()?.apiName ?? '')
          .fontSize(YoTypeStyle.BODY_M.size)
        Text(this.vm.selectedLog()?.hex ?? '')
          .fontSize(YoTypeStyle.BODY_S.size)
        Text(this.vm.selectedLog()?.reasonMsg ?? '')
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
        Text(this.vm.selectedLog()?.summary ?? '')
          .fontSize(YoTypeStyle.BODY_S.size)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
    }
  }

  build() {
    YoPageShell({
      title: $r('app.string.nl_title_log'),
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
}
