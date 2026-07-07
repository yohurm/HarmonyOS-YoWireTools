import { YoAppShell } from 'common_ui';
import { AppRoutes } from '../navigation/AppRoutes';

@ComponentV2
export struct MainTabContainer {
  @Param currentTabIndex: number = AppRoutes.TAB_INDEX_WORKBENCH;
  @Event onTabChange: (index: number) => void = (_index: number) => {
  };

  build() {
    YoAppShell({
      currentTabIndex: this.currentTabIndex,
      onTabChange: (index: number) => {
        this.onTabChange(index);
      }
    })
  }
}
