import { YoTabRootPage } from 'common_ui';

/**
 * WiFi/Network tab root — placeholder until module flows are implemented.
 */
@ComponentV2
export struct WifiFeaturePage {
  build() {
    YoTabRootPage({
      title: $r('app.string.wifi_title_overview')
    })
  }
}
