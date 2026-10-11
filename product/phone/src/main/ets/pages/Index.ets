import { UIContextRegistry } from 'common_platform';
import { HomeSessionTarget } from 'feature_home';
import { YoColor } from 'youi_kit';
import {
  BleDeviceRow,
  BluetoothDiagnosticsPage,
  BluetoothObjectNavParams,
  BlePeripheralPage,
  ClassicDeviceListItem,
  DeviceIdentityPage,
  GattClientPage,
  PairingGuideDialog,
  SessionLogPage,
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

  private openHomeTarget(target: string): void {
    this.rootNavStack.clear(false);
    if (target === HomeSessionTarget.BLUETOOTH_SPP) {
      this.activeTabIndex = AppRoutes.TAB_INDEX_BLUETOOTH;
      this.rootNavStack.pushPath({ name: AppRoutes.BLUETOOTH_SPP });
      return;
    }
    if (target === HomeSessionTarget.BLUETOOTH_BLE) {
      this.activeTabIndex = AppRoutes.TAB_INDEX_BLUETOOTH;
      this.rootNavStack.pushPath({ name: AppRoutes.BLUETOOTH_BLE });
      return;
    }
    if (target === HomeSessionTarget.BLUETOOTH) {
      this.activeTabIndex = AppRoutes.TAB_INDEX_BLUETOOTH;
      return;
    }
    if (target === HomeSessionTarget.WIFI) {
      this.activeTabIndex = AppRoutes.TAB_INDEX_NETWORK;
      return;
    }
    if (target === HomeSessionTarget.NEARLINK) {
      this.activeTabIndex = AppRoutes.TAB_INDEX_NEARLINK;
    }
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
          },
          onOpenIdentity: (item: ClassicDeviceListItem) => {
            this.rootNavStack.pushPath({
              name: AppRoutes.BLUETOOTH_DEVICE,
              param: new BluetoothObjectNavParams(
                item.classicDeviceId,
                item.displayName,
                item.address,
                true,
                ''
              )
            });
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
          },
          onOpenIdentity: (row: BleDeviceRow) => {
            this.openBleIdentity(row);
          },
          onOpenClient: (row: BleDeviceRow) => {
            this.rootNavStack.pushPath({
              name: AppRoutes.BLUETOOTH_BLE_CLIENT,
              param: new BluetoothObjectNavParams(row.deviceId, row.name, row.address, row.connectable, '')
            });
          },
          onOpenPeripheral: () => {
            this.rootNavStack.pushPath({ name: AppRoutes.BLUETOOTH_BLE_PERIPHERAL });
          },
          onOpenLog: () => {
            this.rootNavStack.pushPath({
              name: AppRoutes.BLUETOOTH_SESSION_LOG,
              param: new BluetoothObjectNavParams()
            });
          }
        })
      }
      .hideTitleBar(true, false)
    } else if (name === AppRoutes.BLUETOOTH_DEVICE) {
      NavDestination() {
        DeviceIdentityPage({
          params: this.readObjectParams(param),
          onBack: () => {
            this.rootNavStack.pop();
          }
        })
      }
      .hideTitleBar(true, false)
    } else if (name === AppRoutes.BLUETOOTH_BLE_PERIPHERAL) {
      NavDestination() {
        BlePeripheralPage({
          onBack: () => {
            this.rootNavStack.pop();
          }
        })
      }
      .hideTitleBar(true, false)
    } else if (name === AppRoutes.BLUETOOTH_BLE_CLIENT) {
      NavDestination() {
        GattClientPage({
          params: this.readObjectParams(param),
          onBack: () => {
            this.rootNavStack.pop();
          },
          onOpenLog: (sessionId: string) => {
            this.rootNavStack.pushPath({
              name: AppRoutes.BLUETOOTH_SESSION_LOG,
              param: new BluetoothObjectNavParams('', '', '', true, sessionId)
            });
          }
        })
      }
      .hideTitleBar(true, false)
    } else if (name === AppRoutes.BLUETOOTH_SESSION_LOG) {
      NavDestination() {
        SessionLogPage({
          params: this.readObjectParams(param),
          onBack: () => {
            this.rootNavStack.pop();
          }
        })
      }
      .hideTitleBar(true, false)
    } else if (name === AppRoutes.BLUETOOTH_DIAGNOSTICS) {
      NavDestination() {
        BluetoothDiagnosticsPage({
          onBack: () => {
            this.rootNavStack.pop();
          }
        })
      }
      .hideTitleBar(true, false)
    }
  }

  private openBleIdentity(row: BleDeviceRow): void {
    this.rootNavStack.pushPath({
      name: AppRoutes.BLUETOOTH_DEVICE,
      param: new BluetoothObjectNavParams(row.deviceId, row.name, row.address, row.connectable, '')
    });
  }

  private readObjectParams(param: Object): BluetoothObjectNavParams {
    const raw = param as BluetoothObjectNavParams;
    return new BluetoothObjectNavParams(
      raw.deviceId !== undefined ? raw.deviceId : '',
      raw.displayName !== undefined ? raw.displayName : '',
      raw.addressText !== undefined ? raw.addressText : '',
      raw.connectable !== undefined ? raw.connectable : true,
      raw.sessionId !== undefined ? raw.sessionId : ''
    );
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
          },
          onOpenTarget: (target: string) => {
            this.openHomeTarget(target);
          },
          onOpenBluetoothDiagnostics: () => {
            this.activeTabIndex = AppRoutes.TAB_INDEX_BLUETOOTH;
            this.rootNavStack.pushPath({ name: AppRoutes.BLUETOOTH_DIAGNOSTICS });
          },
          onOpenBluetoothIdentity: () => {
            this.activeTabIndex = AppRoutes.TAB_INDEX_BLUETOOTH;
            this.rootNavStack.pushPath({
              name: AppRoutes.BLUETOOTH_DEVICE,
              param: new BluetoothObjectNavParams()
            });
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
