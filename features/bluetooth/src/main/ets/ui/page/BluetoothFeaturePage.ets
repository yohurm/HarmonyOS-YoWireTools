import { YoTabRootPage } from 'common_ui';

/**
 * Bluetooth tab root — placeholder until module flows are implemented.
 */
@ComponentV2
export struct BluetoothFeaturePage {
  build() {
    YoTabRootPage({
      title: $r('app.string.bt_title_overview')
    })
  }
}
