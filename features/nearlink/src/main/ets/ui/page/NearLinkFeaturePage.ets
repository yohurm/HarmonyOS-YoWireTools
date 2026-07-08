import {
  UiColorToken,
  UiTypography,
  YoNavDestinationKind,
  YoPageShell,
  YoSplitScaffold
} from 'common_ui';

@Builder
function nearLinkListPane() {
  Column() {
    Text('NearLink device list placeholder')
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(UiColorToken.TEXT_SECONDARY)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

@Builder
function nearLinkDetailPane() {
  Column() {
    Text('NearLink device detail placeholder')
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(UiColorToken.TEXT_SECONDARY)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

@Builder
function nearLinkContent() {
  YoSplitScaffold({
    listPane: nearLinkListPane,
    detailPane: nearLinkDetailPane
  })
}

@ComponentV2
export struct NearLinkFeaturePage {
  build() {
    YoPageShell({
      title: $r('app.string.nl_title_overview'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: nearLinkContent
    })
  }
}

