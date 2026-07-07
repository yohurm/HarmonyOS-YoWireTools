import { UIContextRegistry } from 'common_platform';
import { UiColorToken } from 'common_ui';
import { AppRoutes } from '../navigation/AppRoutes';
import { MainTabContainer } from '../shell/MainTabContainer';

@Entry
@ComponentV2
struct Index {
  @Local activeTabIndex: number = AppRoutes.TAB_INDEX_WORKBENCH;

  aboutToAppear(): void {
    UIContextRegistry.getInstance().bind(this.getUIContext());
  }

  build() {
    Column() {
      MainTabContainer({
        currentTabIndex: this.activeTabIndex,
        onTabChange: (index: number) => {
          this.activeTabIndex = index;
        }
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor(UiColorToken.BACKGROUND)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
