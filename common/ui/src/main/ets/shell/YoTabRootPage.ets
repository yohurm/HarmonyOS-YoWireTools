import { YoNavDestinationKind } from './YoNavDestinationKind';
import { YoPageShell } from '../component/YoPageShell';

/**
 * Canonical empty feature-tab root: title bar only, no work area content.
 * All feature modules should use this until real flows land.
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
