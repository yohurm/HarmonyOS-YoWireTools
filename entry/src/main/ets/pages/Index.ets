import { UIContextRegistry } from 'common_platform';
import { UiColorToken } from 'common_ui';
import { BleMainPage, SppMainPage } from 'feature_bluetooth';
import { AppRoutes } from '../navigation/AppRoutes';
import { MainTabContainer } from '../shell/MainTabContainer';

@Entry
@ComponentV2
struct Index {
  @Local activeTabIndex: number = AppRoutes.TAB_INDEX_WORKBENCH;
  private rootNavStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    UIContextRegistry.getInstance().bind(this.getUIContext());
  }

  @LocalBuilder
  rootDestination(name: string, _param: Object) {
    if (name === AppRoutes.BLUETOOTH_SPP) {
      NavDestination() {
        SppMainPage({
          onBack: () => {
            this.rootNavStack.pop();
          }
        })
      }
      .hideTitleBar(true, false)
    } else if (name === AppRoutes.BLUETOOTH_BLE) {
      NavDestination() {
        BleMainPage({
          onBack: () => {
            this.rootNavStack.pop();
          }
        })
      }
      .hideTitleBar(true, false)
    }
  }

  build() {
    Column() {
      Navigation(this.rootNavStack) {
        MainTabContainer({
          currentTabIndex: this.activeTabIndex,
          onTabChange: (index: number) => {
            this.activeTabIndex = index;
          },
          onOpenBluetoothSpp: () => {
            this.activeTabIndex = AppRoutes.TAB_INDEX_BLUETOOTH;
            this.rootNavStack.pushPath({ name: AppRoutes.BLUETOOTH_SPP });
          },
          onOpenBluetoothBle: () => {
            this.activeTabIndex = AppRoutes.TAB_INDEX_BLUETOOTH;
            this.rootNavStack.pushPath({ name: AppRoutes.BLUETOOTH_BLE });
          }
        })
      }
      .navDestination(this.rootDestination)
      .mode(NavigationMode.Stack)
      .hideTitleBar(true, false)
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .backgroundColor(UiColorToken.BACKGROUND)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
