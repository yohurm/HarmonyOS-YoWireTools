import { CommandTemplate } from 'debug_core';
import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoEmpty,
  YoEmptyStateModel,
  YoNavDestinationKind,
  YoPageShell,
  YoResourceUtil,
  YoSpace,
  YoTypeStyle
} from 'youi_kit';
import { CommandPanelViewModel } from '../../viewmodel/CommandPanelViewModel';

@ComponentV2
export struct CommandPanelPage {
  @Event onBack: () => void = () => {
  };
  @Local vm: CommandPanelViewModel = new CommandPanelViewModel();

  aboutToAppear(): void {
    void this.vm.refresh();
  }

  @LocalBuilder
  pageContent() {
    Column({ space: YoSpace.L }) {
      if (this.vm.favorites().length === 0 && !this.vm.creating) {
        YoEmpty({
          model: new YoEmptyStateModel(
            $r('app.string.command_empty_title'),
            $r('app.string.command_empty_message'),
            '',
            $r('app.string.command_new')
          ),
          onPrimaryAction: () => {
            this.vm.startCreate();
          }
        })
      } else {
        Column({ space: YoSpace.S }) {
          ForEach(this.vm.favorites(), (item: CommandTemplate) => {
            Text(item.name)
              .fontSize(YoTypeStyle.BODY_M.size)
              .fontColor(item.id === this.vm.selectedId ? YoColor.BRAND_PRIMARY : YoColor.TEXT_PRIMARY)
              .width('100%')
              .maxLines(1)
              .textOverflow({ overflow: TextOverflow.Ellipsis })
              .padding({ top: YoSpace.S, bottom: YoSpace.S })
              .onClick(() => {
                this.vm.select(item.id);
              })
          }, (item: CommandTemplate) => item.id)
        }
        .width('100%')

        if (!this.vm.creating) {
          YoActionButton({
            label: $r('app.string.command_new'),
            kind: YoActionButtonKind.SECONDARY,
            onTap: () => {
              this.vm.startCreate();
            }
          })
        }
      }

      if (this.vm.creating) {
        Column({ space: YoSpace.S }) {
          TextInput({ placeholder: $r('app.string.command_name_hint'), text: this.vm.draftName })
            .width('100%')
            .onChange((value: string) => {
              this.vm.draftName = value;
            })
          TextInput({ placeholder: $r('app.string.command_payload_hint'), text: this.vm.draftPayload })
            .width('100%')
            .onChange((value: string) => {
              this.vm.draftPayload = value;
            })
          YoActionButton({
            label: $r('app.string.command_save'),
            onTap: () => {
              void this.vm.saveDraft(true);
            }
          })
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      if (this.vm.saved) {
        Text($r('app.string.command_saved'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
      }

      if (this.vm.selectedId.length > 0 && this.vm.selected() !== undefined) {
        Column({ space: YoSpace.S }) {
          Text($r('app.string.command_params'))
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_SECONDARY)
            .width('100%')
          Text(this.vm.selectedPayload())
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontColor(YoColor.TEXT_PRIMARY)
            .width('100%')
          YoActionButton({
            label: $r('app.string.command_run_once'),
            onTap: () => {
              void this.vm.runOnce();
            }
          })
          YoActionButton({
            label: $r('app.string.command_repeat'),
            kind: YoActionButtonKind.SECONDARY,
            isEnabled: this.vm.repeatAllowed && !this.vm.repeating,
            disabledReason: this.vm.repeatAllowed ? '' : $r('app.string.command_repeat_off'),
            onTap: () => {
              void this.vm.startRepeat();
            }
          })
          if (this.vm.repeating) {
            Text($r('app.string.command_running'))
              .fontSize(YoTypeStyle.BODY_S.size)
              .fontColor(YoColor.TEXT_SECONDARY)
              .width('100%')
            YoActionButton({
              label: $r('app.string.command_stop'),
              kind: YoActionButtonKind.DANGER,
              onTap: () => {
                this.vm.askStop();
              }
            })
          }
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      if (this.vm.confirmingStop) {
        Column({ space: YoSpace.S }) {
          Text($r('app.string.command_stop_confirm'))
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontColor(YoColor.TEXT_PRIMARY)
            .width('100%')
          Row({ space: YoSpace.M }) {
            YoActionButton({
              label: $r('app.string.log_confirm'),
              kind: YoActionButtonKind.DANGER,
              fullWidth: false,
              onTap: () => {
                this.vm.confirmStop();
              }
            })
            YoActionButton({
              label: $r('app.string.log_cancel'),
              kind: YoActionButtonKind.SECONDARY,
              fullWidth: false,
              onTap: () => {
                this.vm.cancelStop();
              }
            })
          }
          .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)
      }

      if (this.vm.ran) {
        Text($r('app.string.command_ran'))
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
          .width('100%')
      }

      if (YoResourceUtil.hasText(this.vm.failureText())) {
        Text(this.vm.failureText())
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
          .width('100%')
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.command_panel_title'),
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
