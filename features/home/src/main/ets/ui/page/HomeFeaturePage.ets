import {
  UiColorToken,
  UiTypography,
  YoNavDestinationKind,
  YoPageShell,
  YoSplitScaffold
} from 'common_ui';

@Builder
function homeListPane() {
  Column() {
    Text('Workbench list placeholder')
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(UiColorToken.TEXT_SECONDARY)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

@Builder
function homeDetailPane() {
  Column() {
    Text('Workbench detail placeholder')
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(UiColorToken.TEXT_SECONDARY)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

@Builder
function homeContent() {
  YoSplitScaffold({
    listPane: homeListPane,
    detailPane: homeDetailPane
  })
}

@ComponentV2
export struct HomeFeaturePage {
  build() {
    YoPageShell({
      title: $r('app.string.home_title'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: homeContent
    })
  }
}

