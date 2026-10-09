import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import {
  YoContentState,
  YoLoadingStateModel,
  YoPageState,
  YoNavDestinationKind,
  YoPageShell,
  YoTitleBarMenuItem
} from 'youi_kit';
import {
  ClassicDeviceListItem,
  openSppTitleMoreMenu,
  SPP_TITLE_MORE_MENU_ID,
  SppMainContentView,
  SppMainViewModel,
  SppSegmentTab
} from 'feature_bluetooth';

/**
 * Product page shell: Classic SPP.
 */
@ComponentV2
export struct SppMainPage {
  @Event onBack: () => void = () => {
  };
  @Event onOpenConnect: (item: ClassicDeviceListItem) => void = (_item: ClassicDeviceListItem) => {
  };
  @Event onOpenTerminal: (sessionId: string) => void = (_sessionId: string) => {
  };
  @Event onOpenIdentity: (item: ClassicDeviceListItem) => void = (_item: ClassicDeviceListItem) => {
  };
  @Local private vm: SppMainViewModel = new SppMainViewModel();
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();

  aboutToAppear(): void {
    void this.vm.onPageAppear();
  }

  aboutToDisappear(): void {
    void this.vm.onPageDisappear();
  }

  private pageHorizontalPadding(): number {
    return WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint);
  }

  @LocalBuilder
  pageContent() {
    YoContentState({
      state: this.vm.isLoading ? YoPageState.LOADING : YoPageState.CONTENT,
      loadingModel: new YoLoadingStateModel($r('app.string.youi_loading_default_message')),
      content: this.pageBody
    })
  }

  @LocalBuilder
  pageBody() {
    SppMainContentView({
      vm: this.vm,
      horizontalPadding: this.pageHorizontalPadding(),
      bottomInsetVp: this.metrics.navigationBottomInsetVp,
      onOpenConnect: (item: ClassicDeviceListItem) => {
        this.onOpenConnect(item);
      },
      onOpenTerminal: (sessionId: string) => {
        this.onOpenTerminal(sessionId);
      },
      onOpenIdentity: (item: ClassicDeviceListItem) => {
        this.onOpenIdentity(item);
      }
    })
  }

  build() {
    YoPageShell({
      title: $r('app.string.bt_spp_page_title'),
      showBack: true,
      destinationKind: YoNavDestinationKind.MODULE,
      scrollable: false,
      contentEdgeToEdge: true,
      immersiveTitleBar: true,
      titleBarMenus: this.buildTitleMenus(),
      onBack: this.onBack,
      content: this.pageContent
    })
  }

  /**
   * Filter icon is scan-rail only (left of refresh).
   * Rebuilt when selectedSegment / filterPanelExpanded changes via @Trace.
   */
  private buildTitleMenus(): YoTitleBarMenuItem[] {
    const menus: YoTitleBarMenuItem[] = [];
    if (this.vm.selectedSegment === SppSegmentTab.SCAN) {
      menus.push(new YoTitleBarMenuItem(
        'filter',
        $r('sys.symbol.funnel'),
        $r('app.string.bt_spp_action_filter'),
        () => {
          this.vm.toggleFilterPanel();
        }
      ));
    }
    menus.push(new YoTitleBarMenuItem(
      'refresh',
      $r('sys.symbol.arrow_clockwise'),
      $r('app.string.bt_spp_action_refresh'),
      () => {
        void this.vm.refresh(false);
      }
    ));
    menus.push(new YoTitleBarMenuItem(
      'more',
      $r('sys.symbol.more'),
      $r('app.string.youi_more_actions'),
      () => {
        openSppTitleMoreMenu(this.getUIContext(), SPP_TITLE_MORE_MENU_ID, () => {
          void this.vm.openBluetoothSettings();
        });
      },
      true,
      SPP_TITLE_MORE_MENU_ID
    ));
    return menus;
  }
}
