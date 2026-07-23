import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import {
  ContentStateHost,
  LoadingStateModel,
  UiPageState,
  YoNavDestinationKind,
  YoPageShell,
  YoTitleBarMenuItem
} from 'common_ui';
import { openSppTitleMoreMenu, SPP_TITLE_MORE_MENU_ID } from '../menu/SppTitleMoreMenu';
import { SppMainContentView } from '../view/SppMainContentView';
import { SppMainViewModel } from '../../viewmodel/SppMainViewModel';

/**
 * Classic SPP page assembly — binds ViewModel lifecycle to YoPageShell only.
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
    ContentStateHost({
      state: this.vm.isLoading ? UiPageState.LOADING : UiPageState.CONTENT,
      loadingModel: new LoadingStateModel($r('app.string.ui_loading_default_message')),
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
        $r('app.string.ui_more_actions'),
        () => {
          openSppTitleMoreMenu(this.getUIContext(), SPP_TITLE_MORE_MENU_ID);
        },
        true,
        SPP_TITLE_MORE_MENU_ID
      )
    ];
  }
}
