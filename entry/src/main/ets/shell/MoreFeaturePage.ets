import {
  YoNavDestinationKind,
  YoPageShell
} from 'youi_kit';

@ComponentV2
export struct MoreFeaturePage {
  @LocalBuilder
  pageContent() {
    Column()
      .width('100%')
      .height('100%')
  }

  build() {
    YoPageShell({
      title: $r('app.string.more_hub_title'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: this.pageContent
    })
  }
}
