import {
  UiColorToken,
  UiTypography,
  YoNavDestinationKind,
  YoPageShell,
  YoSplitScaffold
} from 'common_ui';

@Builder
function wifiListPane() {
  Column() {
    Text('WiFi network list placeholder')
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(UiColorToken.TEXT_SECONDARY)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

@Builder
function wifiDetailPane() {
  Column() {
    Text('WiFi network detail placeholder')
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(UiColorToken.TEXT_SECONDARY)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

@Builder
function wifiContent() {
  YoSplitScaffold({
    listPane: wifiListPane,
    detailPane: wifiDetailPane
  })
}

@ComponentV2
export struct WifiFeaturePage {
  build() {
    YoPageShell({
      title: $r('app.string.wifi_title_overview'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: wifiContent
    })
  }
}

