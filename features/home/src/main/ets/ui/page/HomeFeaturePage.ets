import { DebugSessionSummary, FeatureModuleId } from 'debug_core';
import {
  YoEmpty,
  YoEmptyStateModel,
  YoModeEntryCard,
  YoNavDestinationKind,
  YoPageShell,
  YoSpace,
  YoTypeStyle,
  YoColor
} from 'youi_kit';
import { WorkbenchViewModel } from '../../viewmodel/WorkbenchViewModel';

/** Workbench root tab. Cards switch the existing shell tab. They do not scan. */
@ComponentV2
export struct HomeFeaturePage {
  @Event onOpenModule: (moduleId: string) => void = (_moduleId: string) => {
  };
  @Event onOpenLog: () => void = () => {
  };
  @Event onOpenCommand: () => void = () => {
  };
  @Local vm: WorkbenchViewModel = new WorkbenchViewModel();

  aboutToAppear(): void {
    this.vm.refresh();
  }

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.L }) {
      Row({ space: YoSpace.M }) {
        Column() {
          YoModeEntryCard({
            title: $r('app.string.home_card_bluetooth'),
            description: $r('app.string.home_card_module_hint'),
            onTap: () => {
              this.onOpenModule(FeatureModuleId.BLUETOOTH);
            }
          })
        }
        .layoutWeight(1)

        Column() {
          YoModeEntryCard({
            title: $r('app.string.home_card_network'),
            description: $r('app.string.home_card_module_hint'),
            onTap: () => {
              this.onOpenModule(FeatureModuleId.WIFI);
            }
          })
        }
        .layoutWeight(1)

        Column() {
          YoModeEntryCard({
            title: $r('app.string.home_card_nearlink'),
            description: $r('app.string.home_card_module_hint'),
            onTap: () => {
              this.onOpenModule(FeatureModuleId.NEARLINK);
            }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Row({ space: YoSpace.M }) {
        Column() {
          YoModeEntryCard({
            title: $r('app.string.home_card_log'),
            description: $r('app.string.home_card_tool_hint'),
            onTap: () => {
              this.onOpenLog();
            }
          })
        }
        .layoutWeight(1)

        Column() {
          YoModeEntryCard({
            title: $r('app.string.home_card_command'),
            description: $r('app.string.home_card_tool_hint'),
            onTap: () => {
              this.onOpenCommand();
            }
          })
        }
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Top)

      Text($r('app.string.home_recent_title'))
        .fontSize(YoTypeStyle.SUBTITLE_M.size)
        .fontWeight(YoTypeStyle.SUBTITLE_M.weight)
        .fontColor(YoColor.TEXT_PRIMARY)
        .width('100%')

      if (this.vm.sessions.length === 0) {
        YoEmpty({
          model: new YoEmptyStateModel(
            $r('app.string.home_recent_empty_title'),
            $r('app.string.home_recent_empty_message')
          )
        })
      } else {
        Column({ space: YoSpace.S }) {
          ForEach(this.vm.sessions, (item: DebugSessionSummary) => {
            Column({ space: YoSpace.XS }) {
              Text(item.displayName)
                .fontSize(YoTypeStyle.BODY_M.size)
                .fontColor(YoColor.TEXT_PRIMARY)
                .width('100%')
                .maxLines(1)
                .textOverflow({ overflow: TextOverflow.Ellipsis })
              Text(`${item.module} · ${item.protocol}`)
                .fontSize(YoTypeStyle.BODY_S.size)
                .fontColor(YoColor.TEXT_SECONDARY)
                .width('100%')
                .maxLines(1)
            }
            .width('100%')
            .alignItems(HorizontalAlign.Start)
            .padding({ top: YoSpace.S, bottom: YoSpace.S })
          }, (item: DebugSessionSummary) => item.id)
        }
        .width('100%')
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.home_title'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: true,
      content: this.pageContent
    })
  }
}
