import { YoTabRootPage } from 'common_ui';

/**
 * More tab root — placeholder until global settings flows are implemented.
 */
@ComponentV2
export struct MoreFeaturePage {
  build() {
    YoTabRootPage({
      title: $r('app.string.more_hub_title')
    })
  }
}
