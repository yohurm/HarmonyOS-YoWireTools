import { YoNavDestinationKind, YoPageShell } from 'common_ui';

/**
 * BLE main page — intentionally empty shell until BLE UI is rebuilt.
 */
@ComponentV2
export struct BleMainPage {
  @Event onBack: () => void = () => {
  };

  @LocalBuilder
  emptyContent() {
    Column()
      .width('100%')
      .height('100%')
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_ble_page_title'),
      showBack: true,
      destinationKind: YoNavDestinationKind.MODULE,
      scrollable: false,
      immersiveTitleBar: true,
      onBack: this.onBack,
      content: this.emptyContent
    })
  }
}
