import { YoTabRootPage } from 'common_ui';

/**
 * Workbench tab root — placeholder until workbench flows are implemented.
 */
@ComponentV2
export struct HomeFeaturePage {
  build() {
    YoTabRootPage({
      title: $r('app.string.home_title')
    })
  }
}
