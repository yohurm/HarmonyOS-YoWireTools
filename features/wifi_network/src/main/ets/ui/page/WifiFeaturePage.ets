import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { YoColor } from 'youi_kit';
import { WifiDebugRoutes } from '../navigation/WifiDebugRoutes';
import { WifiDebugViewModel } from '../viewmodel/WifiDebugViewModel';
import {
  WifiAddressPage,
  WifiConnectPage,
  WifiDefaultNetPage,
  WifiInspectPage,
  WifiLanPage,
  WifiLinkPage,
  WifiLogPage,
  WifiPermissionPage,
  WifiThroughputPage,
  WifiWallPage,
  WifiWlanPage
} from './WifiModulePages';
import { WifiOverviewPage } from './WifiOverviewPage';
import { WifiAccessPointPage, WifiChannelPage, WifiScanPage } from './WifiScanPage';

@ComponentV2
export struct WifiFeaturePage {
  @Local vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Local metrics: WindowMetricsState = WindowMetricsRegistry.connect();
  private stack: NavPathStack = new NavPathStack();

  aboutToAppear(): void {
    void this.vm.enter();
  }

  aboutToDisappear(): void {
    this.vm.leave();
  }

  private open(name: string): void {
    this.stack.pushPath({ name: name });
  }

  private back(): void {
    this.stack.pop();
  }

  @Builder
  destination(name: string, _param: Object) {
    if (name === WifiDebugRoutes.PERMISSION) {
      NavDestination() {
        WifiPermissionPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => this.open(WifiDebugRoutes.LOG)
        })
      }
      .hideTitleBar(true, false)
    } else if (name === WifiDebugRoutes.WLAN) {
      NavDestination() {
        WifiWlanPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => this.open(WifiDebugRoutes.LOG)
        })
      }
      .hideTitleBar(true, false)
    } else if (name === WifiDebugRoutes.SCAN) {
      NavDestination() {
        WifiScanPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => this.open(WifiDebugRoutes.LOG),
          onOpenChannel: () => this.open(WifiDebugRoutes.CHANNEL),
          onOpenAp: (_id: string) => this.open(WifiDebugRoutes.ACCESS_POINT)
        })
      }
      .hideTitleBar(true, false)
    } else if (name === WifiDebugRoutes.ACCESS_POINT) {
      NavDestination() {
        WifiAccessPointPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => this.open(WifiDebugRoutes.LOG)
        })
      }
      .hideTitleBar(true, false)
    } else if (name === WifiDebugRoutes.CHANNEL) {
      NavDestination() {
        WifiChannelPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => this.open(WifiDebugRoutes.LOG)
        })
      }
      .hideTitleBar(true, false)
    } else if (name === WifiDebugRoutes.LINK) {
      NavDestination() {
        WifiLinkPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => this.open(WifiDebugRoutes.LOG)
        })
      }
      .hideTitleBar(true, false)
    } else if (name === WifiDebugRoutes.CONNECT) {
      NavDestination() {
        WifiConnectPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => this.open(WifiDebugRoutes.LOG)
        })
      }
      .hideTitleBar(true, false)
    } else if (name === WifiDebugRoutes.DEFAULT_NET) {
      NavDestination() {
        WifiDefaultNetPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => this.open(WifiDebugRoutes.LOG)
        })
      }
      .hideTitleBar(true, false)
    } else if (name === WifiDebugRoutes.ADDRESS) {
      NavDestination() {
        WifiAddressPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => this.open(WifiDebugRoutes.LOG)
        })
      }
      .hideTitleBar(true, false)
    } else if (name === WifiDebugRoutes.THROUGHPUT) {
      NavDestination() {
        WifiThroughputPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => this.open(WifiDebugRoutes.LOG)
        })
      }
      .hideTitleBar(true, false)
    } else if (name === WifiDebugRoutes.INSPECT) {
      NavDestination() {
        WifiInspectPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => this.open(WifiDebugRoutes.LOG)
        })
      }
      .hideTitleBar(true, false)
    } else if (name === WifiDebugRoutes.LAN) {
      NavDestination() {
        WifiLanPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => this.open(WifiDebugRoutes.LOG)
        })
      }
      .hideTitleBar(true, false)
    } else if (name === WifiDebugRoutes.WALL) {
      NavDestination() {
        WifiWallPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => this.open(WifiDebugRoutes.LOG)
        })
      }
      .hideTitleBar(true, false)
    } else if (name === WifiDebugRoutes.LOG) {
      NavDestination() {
        WifiLogPage({
          vm: this.vm,
          onBack: () => this.back(),
          onOpenLog: () => {
          }
        })
      }
      .hideTitleBar(true, false)
    } else {
      NavDestination() {
        WifiOverviewPage({
          vm: this.vm,
          onOpen: (route: string) => this.open(route)
        })
      }
      .hideTitleBar(true, false)
    }
  }

  build() {
    Navigation(this.stack) {
      WifiOverviewPage({
        vm: this.vm,
        onOpen: (name: string) => this.open(name)
      })
    }
    .navDestination(this.destination)
    .mode(WindowWidthBreakpointUtil.isSplitCapable(this.metrics.breakpoint) ? NavigationMode.Auto : NavigationMode.Stack)
    .hideTitleBar(true, false)
    .hideNavBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor(YoColor.BACKGROUND_PRIMARY)
  }
}
