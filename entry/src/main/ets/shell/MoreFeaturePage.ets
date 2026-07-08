import {
  UiColorToken,
  UiTypography,
  YoNavDestinationKind,
  YoPageShell,
  YoSplitScaffold
} from 'common_ui';

@Builder
function moreListPane() {
  Column() {
    Text('Settings list placeholder')
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(UiColorToken.TEXT_SECONDARY)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

@Builder
function moreDetailPane() {
  Column() {
    Text('Settings detail placeholder')
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(UiColorToken.TEXT_SECONDARY)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

@Builder
function moreContent() {
  YoSplitScaffold({
    listPane: moreListPane,
    detailPane: moreDetailPane
  })
}

@ComponentV2
export struct MoreFeaturePage {
  build() {
    YoPageShell({
      title: $r('app.string.more_hub_title'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: moreContent
    })
  }
}

