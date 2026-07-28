import {
  YoNavDestinationKind,
  YoPageShell
} from 'youi_kit';

/** NearLink root tab — placeholder until NearLink UI is rebuilt. */
@ComponentV2
export struct NearLinkFeaturePage {
  @LocalBuilder
  pageContent() {
    Column()
      .width('100%')
      .height('100%')
  }

  build() {
    YoPageShell({
      title: $r('app.string.nl_title_overview'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: this.pageContent
    })
  }
}
