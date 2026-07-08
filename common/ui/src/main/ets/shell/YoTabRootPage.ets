import { YoNavDestinationKind } from './YoNavDestinationKind';
import { YoPageShell } from '../component/YoPageShell';

/**
 * Canonical feature-tab root. Responsive frame is provided by YoAppShell.
 */
@ComponentV2
export struct YoTabRootPage {
  @Param title: ResourceStr = '';

  build() {
    YoPageShell({
      title: this.title,
      destinationKind: YoNavDestinationKind.ROOT_TAB
    })
  }
}
