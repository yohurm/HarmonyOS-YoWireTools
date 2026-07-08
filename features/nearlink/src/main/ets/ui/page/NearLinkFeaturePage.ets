import { YoTabRootPage } from 'common_ui';

/**
 * NearLink tab root — placeholder until module flows are implemented.
 */
@ComponentV2
export struct NearLinkFeaturePage {
  build() {
    YoTabRootPage({
      title: $r('app.string.nl_title_overview')
    })
  }
}
