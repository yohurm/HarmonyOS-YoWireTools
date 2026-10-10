import { SettingsHubPage } from 'feature_home';
import {
  YoNavDestinationKind,
  YoPageShell
} from 'youi_kit';

/** App settings tab. Same page the home dashboard opens. Not a feature settings page. */
@ComponentV2
export struct AppSettingsPage {
  @LocalBuilder
  pageContent() {
    SettingsHubPage()
  }

  build() {
    YoPageShell({
      title: $r('app.string.settings_app_title'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: true,
      content: this.pageContent
    })
  }
}
