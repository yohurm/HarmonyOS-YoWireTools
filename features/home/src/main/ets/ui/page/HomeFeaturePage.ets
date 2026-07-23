import {
  YoNavDestinationKind,
  YoPageShell
} from 'youi_kit';

@ComponentV2
export struct HomeFeaturePage {
  @LocalBuilder
  pageContent() {
    Column()
      .width('100%')
      .height('100%')
  }

  build() {
    YoPageShell({
      title: $r('app.string.home_title'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: this.pageContent
    })
  }
}
