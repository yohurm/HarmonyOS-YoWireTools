import { WorkbenchLogLine } from 'debug_core';
import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoEmpty,
  YoEmptyStateModel,
  YoNavDestinationKind,
  YoPageShell,
  YoSegmentButton,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { LogDetailNavParams } from '../../navigation/ShellNavParams';
import { LogCenterViewModel } from '../../viewmodel/LogCenterViewModel';

@ComponentV2
export struct LogCenterPage {
  @Event onBack: () => void = () => {
  };
  @Event onOpenDetail: (params: LogDetailNavParams) => void = (_params: LogDetailNavParams) => {
  };
  @Local vm: LogCenterViewModel = new LogCenterViewModel();

  aboutToAppear(): void {
    void this.vm.refresh();
  }

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.L }) {
      YoSegmentButton({
        labels: [
          $r('app.string.log_filter_all'),
          $r('app.string.log_filter_bluetooth'),
          $r('app.string.log_filter_network'),
          $r('app.string.log_filter_nearlink')
        ],
        initialIndex: 0,
        onSelectedIndexChange: (index: number): void => {
          const values = this.vm.moduleValues();
          if (index >= 0 && index < values.length) {
            this.vm.setModule(values[index]);
          }
        }
      })

      TextInput({ placeholder: $r('app.string.log_keyword_hint'), text: this.vm.keyword })
        .width('100%')
        .onChange((value: string) => {
          this.vm.setKeyword(value);
        })

      Row({ space: YoSpace.M }) {
        YoActionButton({
          label: $r('app.string.log_export'),
          kind: YoActionButtonKind.SECONDARY,
          fullWidth: false,
          onTap: () => {
            void this.vm.exportCurrent();
          }
        })
        YoActionButton({
          label: $r('app.string.log_clear'),
          kind: YoActionButtonKind.DANGER,
          fullWidth: false,
          onTap: () => {
            this.vm.askClear();
          }
        })
      }
      .width('100%')

      if (this.vm.confirmingClear) {
        Column({ space: YoSpace.S }) {
          Text($r('app.string.log_clear_confirm'))
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontColor(YoColor.TEXT_PRIMARY)
            .width('100%')
          Row({ space: YoSpace.M }) {
            YoActionButton({
              label: $r('app.string.log_confirm'),
              kind: YoActionButtonKind.DANGER,
              fullWidth: false,
              onTap: () => {
                void this.vm.confirmClear();
              }
            })
            YoActionButton({
              label: $r('app.string.log_cancel'),
              kind: YoActionButtonKind.SECONDARY,
              fullWidth: false,
              onTap: () => {
                this.vm.cancelClear();
              }
            })
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      if (this.vm.exported) {
        Text($r('app.string.log_exported'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
      }

      if (this.vm.failed) {
        Text($r('app.string.log_failed'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
          .width('100%')
      }

      if (this.vm.lines.length === 0) {
        YoEmpty({
          model: new YoEmptyStateModel(
            $r('app.string.log_empty_title'),
            $r('app.string.log_empty_message')
          )
        })
      } else {
        Column({ space: YoSpace.S }) {
          ForEach(this.vm.lines, (line: WorkbenchLogLine) => {
            Column({ space: YoSpace.XS }) {
              Text(`${line.module} · ${line.protocol}`)
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(YoColor.TEXT_SECONDARY)
                .width('100%')
              Text(line.summary)
                .fontSize(YoTypeStyle.BODY_M.size)
                .fontColor(YoColor.TEXT_PRIMARY)
                .width('100%')
                .maxLines(2)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ top: YoSpace.S, bottom: YoSpace.S })
            .onClick(() => {
              this.onOpenDetail(new LogDetailNavParams(
                line.id,
                line.module,
                line.protocol,
                line.summary,
                line.direction,
                line.timestampMs
              ));
            })
          }, (line: WorkbenchLogLine) => line.id)
        }
        .width('100%')
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.log_center_title'),
      destinationKind: YoNavDestinationKind.MODULE,
      showBack: true,
      scrollable: true,
      onBack: () => {
        this.onBack();
      },
      content: this.pageContent
    })
  }
}
