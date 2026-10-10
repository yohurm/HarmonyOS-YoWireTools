import { SettingsHubPage } from 'feature_home';
import {
  YoNavDestinationKind,
  YoPageShell
} from 'youi_kit';

/** More root tab hosts the settings groups. Title stays 「更多」. */
@ComponentV2
export struct MoreFeaturePage {
  @LocalBuilder
  pageContent() {
    SettingsHubPage()
  }

  build() {
    YoPageShell({
      title: $r('app.string.more_hub_title'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      scrollable: false,
      content: this.pageContent
    })
  }
}
