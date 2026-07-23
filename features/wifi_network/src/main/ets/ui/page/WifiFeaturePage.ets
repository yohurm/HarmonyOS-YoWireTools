import {
  YoNavDestinationKind,
  YoPageShell
} from 'youi_kit';

@ComponentV2
export struct WifiFeaturePage {
  @LocalBuilder
  pageContent() {
    Column()
      .width('100%')
      .height('100%')
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
