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
  openSppTitleMoreMenu,
  SPP_TITLE_MORE_MENU_ID,
  SppMainContentView,
  SppMainViewModel
} from 'feature_bluetooth';

/**
 * Product page shell: Classic SPP.
 */
@ComponentV2
export struct SppMainPage {
  @Event onBack: () => void = () => {
  };
  @Local private vm: SppMainViewModel = new SppMainViewModel();
  @Local private titleMenus: YoTitleBarMenuItem[] = [];
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();

  aboutToAppear(): void {
    this.titleMenus = this.buildTitleMenus();
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
      bottomInsetVp: this.metrics.navigationBottomInsetVp
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
      titleBarMenus: this.titleMenus,
      onBack: this.onBack,
      content: this.pageContent
    })
  }

  private buildTitleMenus(): YoTitleBarMenuItem[] {
    return [
      new YoTitleBarMenuItem(
        'refresh',
        $r('sys.symbol.arrow_clockwise'),
        $r('app.string.bt_spp_action_refresh'),
        () => {
          void this.vm.refresh(false);
        }
      ),
      new YoTitleBarMenuItem(
        'more',
        $r('sys.symbol.more'),
        $r('app.string.youi_more_actions'),
        () => {
          openSppTitleMoreMenu(this.getUIContext(), SPP_TITLE_MORE_MENU_ID);
        },
        true,
        SPP_TITLE_MORE_MENU_ID
      )
    ];
  }
}
