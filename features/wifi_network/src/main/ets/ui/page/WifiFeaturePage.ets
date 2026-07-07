import { PendingModuleNavigation } from 'common_platform';
import { EmptyPageView } from 'common_ui';
import { WifiNavRoutes } from '../navigation/WifiNavRoutes';

@ComponentV2
export struct WifiFeaturePage {
  @Param moduleNavToken: number = 0;
  @Local pathStack: NavPathStack = new NavPathStack();
  @Local lastNavToken: number = -1;

  aboutToAppear(): void {
    if (this.pathStack.size() === 0) {
      this.pathStack.pushPath({ name: WifiNavRoutes.OVERVIEW }, false);
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
      .navDestination(this.wifiDestination)
      .hideNavBar(true)
      .hideTitleBar(true)
      .mode(NavigationMode.Stack)
      .width('100%')
      .height('100%')
  }

  @Builder
  wifiDestination(name: string, _param: Object) {
    NavDestination() {
      EmptyPageView({ title: this.routeTitle(name) })
    }
      .hideTitleBar(true)
  }

  private syncPendingNavigation(): void {
    if (this.moduleNavToken === this.lastNavToken) {
      return;
    }
    this.lastNavToken = this.moduleNavToken;
    const pendingRoute = PendingModuleNavigation.pullWifi();
    if (pendingRoute.length === 0) {
      return;
    }
    if (this.pathStack.size() <= 1) {
      this.pathStack.pushPath({ name: pendingRoute }, false);
      return;
    }
    while (this.pathStack.size() > 1) {
      this.pathStack.pop();
    }
    this.pathStack.pushPath({ name: pendingRoute }, false);
  }

  private routeTitle(route: string): string {
    switch (route) {
      case WifiNavRoutes.SCAN:
        return 'WiFi 扫描';
      case WifiNavRoutes.DIAGNOSTICS:
        return '网络诊断';
      case WifiNavRoutes.SOCKET:
        return 'Socket 工作台';
      case WifiNavRoutes.HTTP:
        return 'HTTP 客户端';
      case WifiNavRoutes.WEBSOCKET:
        return 'WebSocket';
      case WifiNavRoutes.MQTT:
        return 'MQTT 客户端';
      case WifiNavRoutes.LAN:
        return '局域网发现';
      case WifiNavRoutes.MODULE_SETTINGS:
        return '网络设置';
      default:
        return '网络';
    }
  }
}
