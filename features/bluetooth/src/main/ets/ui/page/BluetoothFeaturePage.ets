import {
  UiColorToken,
  UiTypography,
  YoNavDestinationKind,
  YoPageShell,
  YoSplitScaffold
} from 'common_ui';

@Builder
function bluetoothListPane() {
  Column() {
    Text('Bluetooth device list placeholder')
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(UiColorToken.TEXT_SECONDARY)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

@Builder
function bluetoothDetailPane() {
  Column() {
    Text('Bluetooth device detail placeholder')
      .fontSize(UiTypography.BODY_SIZE)
      .fontColor(UiColorToken.TEXT_SECONDARY)
  }
  .width('100%')
  .height('100%')
  .justifyContent(FlexAlign.Center)
  .alignItems(HorizontalAlign.Center)
}

@Builder
function bluetoothContent() {
  YoSplitScaffold({
    listPane: bluetoothListPane,
    detailPane: bluetoothDetailPane
  })
}

@ComponentV2
export struct BluetoothFeaturePage {
  build() {
    YoPageShell({
      title: $r('app.string.bt_title_overview'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: bluetoothContent
    })
  }
}

