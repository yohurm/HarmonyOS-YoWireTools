import {
  YoNavDestinationKind,
  YoPageShell
} from 'youi_kit';

/** Network root tab — placeholder until network UI is rebuilt. */
@ComponentV2
export struct WifiFeaturePage {
  @Event onOpenModuleSettings: () => void = () => {
  };
  @Event onOpenCommand: () => void = () => {
  };

  @LocalBuilder
  pageContent() {
    Column() {
      Button($r('app.string.wifi_open_module_settings'), {
        type: ButtonType.Normal,
        buttonStyle: ButtonStyleMode.TEXTUAL,
        role: ButtonRole.NORMAL
      })
        .onClick(() => {
          this.onOpenModuleSettings();
        })
      Button($r('app.string.wifi_open_command'), {
        type: ButtonType.Normal,
        buttonStyle: ButtonStyleMode.TEXTUAL,
        role: ButtonRole.NORMAL
      })
        .onClick(() => {
          this.onOpenCommand();
        })
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  build() {
    YoPageShell({
      title: $r('app.string.wifi_title_overview'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: this.pageContent
    })
  }
}
