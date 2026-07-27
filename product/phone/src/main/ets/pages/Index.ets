import { UIContextRegistry } from 'common_platform';
import { YoColor } from 'youi_kit';
import {
  ClassicDeviceListItem,
  PairingGuideDialog,
  SppConnectDialog,
  SppTerminalNavParams,
  SppTerminalPage
} from 'feature_bluetooth';
import { AppRoutes } from '../navigation/AppRoutes';
import { MainTabContainer } from '../shell/MainTabContainer';
import { BleMainPage } from './bluetooth/BleMainPage';
import { SppMainPage } from './bluetooth/SppMainPage';

@Entry
@ComponentV2
struct Index {
  @Local activeTabIndex: number = AppRoutes.TAB_INDEX_WORKBENCH;
  private rootNavStack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    UIContextRegistry.getInstance().bind(this.getUIContext());
  }

  /**
   * Unpaired → PairingGuideDialog (app explain + pairDevice) → SppConnectDialog.
   * System pairing / PIN UI is never replaced by the app dialog.
   */
  private openSppConnectDialog(item: ClassicDeviceListItem): void {
    const openConnect = (): void => {
      SppConnectDialog.open(item, (sessionId: string) => {
        this.openSppTerminal(sessionId);
      }, this.getUIContext());
    };
    if (!item.paired) {
      PairingGuideDialog.open(item, () => {
        openConnect();
      }, this.getUIContext());
      return;
    }
    openConnect();
  }

  private openSppTerminal(sessionId: string): void {
    if (sessionId.length === 0) {
      return;
    }
    this.rootNavStack.pushPath({
      name: AppRoutes.BLUETOOTH_SPP_TERMINAL,
      param: new SppTerminalNavParams(sessionId)
    });
  }

  private readTerminalSessionId(param: Object): string {
    const raw = param as SppTerminalNavParams;
    return raw.sessionId !== undefined ? raw.sessionId : '';
  }

  @LocalBuilder
  terminalDestination(param: Object) {
    NavDestination() {
      SppTerminalPage({
        sessionId: this.readTerminalSessionId(param),
        onBack: () => {
          this.rootNavStack.pop();
        }
      })
    }
    .hideTitleBar(true, false)
  }

  @LocalBuilder
  rootDestination(name: string, param: Object) {
    if (name === AppRoutes.BLUETOOTH_SPP) {
      NavDestination() {
        SppMainPage({
          onBack: () => {
            this.rootNavStack.pop();
          },
          onOpenConnect: (item: ClassicDeviceListItem) => {
            this.openSppConnectDialog(item);
          },
          onOpenTerminal: (sessionId: string) => {
            this.openSppTerminal(sessionId);
          }
        })
      }
      .hideTitleBar(true, false)
    } else if (name === AppRoutes.BLUETOOTH_SPP_TERMINAL) {
      this.terminalDestination(param)
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
    .backgroundColor(YoColor.BACKGROUND_PRIMARY)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
