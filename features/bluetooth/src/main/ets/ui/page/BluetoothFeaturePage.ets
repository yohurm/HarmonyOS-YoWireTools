import { PendingModuleNavigation } from 'common_platform';
import { EmptyPageView } from 'common_ui';
import { BluetoothNavRoutes, BluetoothNavParams } from '../navigation/BluetoothNavRoutes';

@ComponentV2
export struct BluetoothFeaturePage {
  @Param moduleNavToken: number = 0;
  @Local pathStack: NavPathStack = new NavPathStack();
  @Local navParams: BluetoothNavParams = new BluetoothNavParams();
  @Local lastNavToken: number = -1;

  aboutToAppear(): void {
    if (this.pathStack.size() === 0) {
      this.pathStack.pushPath({ name: BluetoothNavRoutes.OVERVIEW }, false);
    }
    this.syncPendingNavigation();
  }

  @Monitor('moduleNavToken')
  onModuleNavTokenChange(): void {
    this.syncPendingNavigation();
  }

  build() {
    Navigation(this.pathStack) {
    }
      .navDestination(this.bluetoothDestination)
      .hideNavBar(true)
      .hideTitleBar(true)
      .mode(NavigationMode.Stack)
      .width('100%')
      .height('100%')
  }

  @Builder
  bluetoothDestination(name: string, param: Object) {
    NavDestination() {
      EmptyPageView({ title: this.routeTitle(name, this.resolveParams(param)) })
    }
      .hideTitleBar(true)
  }

  private syncPendingNavigation(): void {
    if (this.moduleNavToken === this.lastNavToken) {
      return;
    }
    this.lastNavToken = this.moduleNavToken;
    const pendingRoute = PendingModuleNavigation.pullBluetooth();
    const extras = PendingModuleNavigation.pullBluetoothExtras();
    if (pendingRoute.length === 0) {
      return;
    }
    const params = BluetoothFeaturePage.paramsFromExtras(extras);
    if (this.pathStack.size() <= 1) {
      this.pathStack.pushPath({ name: pendingRoute, param: params }, false);
      return;
    }
    while (this.pathStack.size() > 1) {
      this.pathStack.pop();
    }
    this.pathStack.pushPath({ name: pendingRoute, param: params }, false);
  }

  private static paramsFromExtras(extras: Record<string, string>): BluetoothNavParams {
    return new BluetoothNavParams(
      extras['deviceId'] ?? '',
      extras['displayName'] ?? '',
      extras['sessionId'] ?? ''
    );
  }

  private routeTitle(route: string, params: BluetoothNavParams): string {
    if (route === BluetoothNavRoutes.SPP_TERMINAL && params.displayName.length > 0) {
      return params.displayName;
    }
    switch (route) {
      case BluetoothNavRoutes.CLASSIC_SCAN:
        return '经典扫描';
      case BluetoothNavRoutes.SPP_CONNECT:
        return 'SPP 连接';
      case BluetoothNavRoutes.SPP_TERMINAL:
        return 'SPP 终端';
      case BluetoothNavRoutes.BLE_SCAN:
        return 'BLE 扫描';
      case BluetoothNavRoutes.BLE_DETAIL:
        return 'BLE 详情';
      case BluetoothNavRoutes.GATT_SERVICE:
        return 'GATT 服务';
      case BluetoothNavRoutes.MODULE_SETTINGS:
        return '蓝牙设置';
      default:
        return '蓝牙';
    }
  }

  private resolveParams(param: Object): BluetoothNavParams {
    if (param instanceof BluetoothNavParams) {
      return param;
    }
    return this.navParams;
  }
}
