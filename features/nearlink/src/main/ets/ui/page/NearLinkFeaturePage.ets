import { PendingModuleNavigation } from 'common_platform';
import { EmptyPageView } from 'common_ui';
import { NearLinkNavRoutes, NearLinkNavParams } from '../navigation/NearLinkNavRoutes';

@ComponentV2
export struct NearLinkFeaturePage {
  @Param moduleNavToken: number = 0;
  @Local pathStack: NavPathStack = new NavPathStack();
  @Local navParams: NearLinkNavParams = new NearLinkNavParams();
  @Local lastNavToken: number = -1;

  aboutToAppear(): void {
    if (this.pathStack.size() === 0) {
      this.pathStack.pushPath({ name: NearLinkNavRoutes.OVERVIEW }, false);
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
      .navDestination(this.nearLinkDestination)
      .hideNavBar(true)
      .hideTitleBar(true)
      .mode(NavigationMode.Stack)
      .width('100%')
      .height('100%')
  }

  @Builder
  nearLinkDestination(name: string, param: Object) {
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
    const pendingRoute = PendingModuleNavigation.pullNearlink();
    const extras = PendingModuleNavigation.pullNearlinkExtras();
    if (pendingRoute.length === 0) {
      return;
    }
    const params = NearLinkFeaturePage.paramsFromExtras(extras);
    if (this.pathStack.size() <= 1) {
      this.pathStack.pushPath({ name: pendingRoute, param: params }, false);
      return;
    }
    while (this.pathStack.size() > 1) {
      this.pathStack.pop();
    }
    this.pathStack.pushPath({ name: pendingRoute, param: params }, false);
  }

  private static paramsFromExtras(extras: Record<string, string>): NearLinkNavParams {
    return new NearLinkNavParams(
      extras['deviceId'] ?? '',
      extras['displayName'] ?? '',
      extras['sessionId'] ?? ''
    );
  }

  private routeTitle(route: string, params: NearLinkNavParams): string {
    if (params.displayName.length > 0) {
      return params.displayName;
    }
    switch (route) {
      case NearLinkNavRoutes.SCAN:
        return '星闪扫描';
      case NearLinkNavRoutes.DEVICE_DETAIL:
        return '星闪设备详情';
      case NearLinkNavRoutes.SSAP_CLIENT:
        return 'SSAP 客户端';
      case NearLinkNavRoutes.DATA_TRANSFER:
        return '数据传输';
      case NearLinkNavRoutes.MODULE_SETTINGS:
        return '星闪设置';
      default:
        return '星闪';
    }
  }

  private resolveParams(param: Object): NearLinkNavParams {
    if (param instanceof NearLinkNavParams) {
      return param;
    }
    return this.navParams;
  }
}
