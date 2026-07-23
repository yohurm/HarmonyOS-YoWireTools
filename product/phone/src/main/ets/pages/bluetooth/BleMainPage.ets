import { YoNavDestinationKind, YoPageShell } from 'youi_kit';

/**
 * Product page shell: BLE main (empty until BLE UI rebuild).
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
