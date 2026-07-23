import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationMenuItemOptions, HdsNavigationIconOptions, HdsNavigationMenuContentOptions } from '@kit.UIDesignKit';
import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { YoNavigationToken } from '../../token/component/YoNavigationToken';
import { YoColor } from '../../token/semantic/YoColor';
import { YoResponsive } from '../../token/semantic/YoResponsive';
import { YoTypeStyle } from '../../token/semantic/YoTypeStyle';
import { YoNavDestinationKind } from './YoNavDestinationKind';
import {
  HdsSystemBarStyleBundle,
  HdsTitleBarPolicy,
  HdsTitleBarScene,
  YoNavigationTitleBarConfig,
  YoTitleBarContent
} from '../../theme/HdsTitleBarPolicy';
import { YoResourceUtil } from '../../util/YoResourceUtil';
import { YoTitleBarMenuItem } from '../../model/YoTitleBarMenuItem';

/**
 * L4 页面壳：HdsNavigation 沉浸式标题栏 + 内容安全区。
 */
@ComponentV2
export struct YoPageShell {
  @Param title: ResourceStr = '';
  @Param subtitle: ResourceStr = '';
  @Param showBack: boolean = false;
  @Param destinationKind: YoNavDestinationKind = YoNavDestinationKind.ROOT_TAB;
  @Param titleBarMenus: YoTitleBarMenuItem[] = [];
  @Param scrollable: boolean = true;
  /**
   * 为 true 时，页面内容自行负责水平内边距（常见于全宽 List 页）。
   * 按 ArkUI 可滚动组件指引，使滚动条贴齐内容视口边缘。
   */
  @Param contentEdgeToEdge: boolean = false;
  @Param immersiveTitleBar: boolean = true;
  @Param immersiveHeroContent: boolean = false;
  @Param bottomPaddingVp: number = -1;
  @BuilderParam content: () => void = this.defaultContent;
  @BuilderParam actionDock: () => void = this.defaultActionDock;
  @Event onBack: () => void = () => {
  };
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();
  private scroller: Scroller = new Scroller();

  @Builder
  defaultContent() {
  }

  @Builder
  defaultActionDock() {
  }

  private isEdgeToEdgeFill(): boolean {
    return this.contentEdgeToEdge && !this.scrollable;
  }

  build() {
    Column() {
      HdsNavigation() {
        if (this.scrollable) {
          Scroll(this.scroller) {
            Column({ space: YoResponsive.SECTION_GAP }) {
              if (YoResourceUtil.hasText(this.subtitle)) {
                Text(this.subtitle)
                  .fontSize(YoTypeStyle.BODY_S.size)
                  .fontColor(YoColor.TEXT_SECONDARY)
                  .width('100%')
                  .padding({
                    left: this.resolveHorizontalPadding(),
                    right: this.resolveHorizontalPadding()
                  })
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              Column() {
                this.content()
              }
              .width('100%')
              .padding({
                left: this.resolveHorizontalPadding(),
                right: this.resolveHorizontalPadding()
              })
            }
            .width('100%')
            .padding({ bottom: this.resolveBottomPadding() })
          }
          .width('100%')
          .height('100%')
          .scrollBar(BarState.Auto)
          .clipContent(ContentClipMode.SAFE_AREA)
        } else {
          Column({ space: this.isEdgeToEdgeFill() ? 0 : YoResponsive.SECTION_GAP }) {
            Column() {
              this.content()
            }
            .width('100%')
            .height('100%')
            .padding({
              left: this.resolveHorizontalPadding(),
              right: this.resolveHorizontalPadding()
            })
            .layoutWeight(1)
            .clip(true)
          }
          .width('100%')
          .height('100%')
          .padding({ bottom: this.resolveBottomPadding() })
          .clip(true)
          .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
        }
      }
      .titleBar(this.buildTitleBarConfig())
      .systemBarStyle(
        this.resolveSystemBarOriginalStyle(),
        this.resolveSystemBarScrollStyle()
      )
      .bindToScrollable(this.scrollable ? [this.scroller] : [])
      .titleMode(HdsNavigationTitleMode.MINI)
      .hideBackButton(!this.showBack)
      .ignoreLayoutSafeArea(
        [LayoutSafeAreaType.SYSTEM],
        this.isEdgeToEdgeFill() ?
          [LayoutSafeAreaEdge.TOP, LayoutSafeAreaEdge.BOTTOM] :
          [LayoutSafeAreaEdge.TOP]
      )
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Color.Transparent)
      this.actionDock()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(YoColor.BACKGROUND_PRIMARY)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
  }

  private buildTitleBarConfig(): YoNavigationTitleBarConfig {
    const scene = HdsTitleBarPolicy.resolveScene(this.immersiveHeroContent);
    const style = HdsTitleBarPolicy.buildStyleBundle(scene, this.scrollable, this.immersiveTitleBar);
    const content: YoTitleBarContent = {
      title: { mainTitle: this.title }
    };
    if (this.showBack) {
      content.backIcon = {
        action: (): void => {
          this.onBack();
        }
      };
    }
    if (this.titleBarMenus.length > 0) {
      const menu: HdsNavigationMenuContentOptions = {
        value: this.buildTitleBarMenuValues()
      };
      content.menu = menu;
    }
    const config: YoNavigationTitleBarConfig = {
      avoidLayoutSafeArea: true,
      enableComponentSafeArea: true,
      style,
      content
    };
    return config;
  }

  private buildTitleBarMenuValues(): Array<HdsNavigationMenuItemOptions> {
    const menus: Array<HdsNavigationMenuItemOptions> = [];
    for (let i = 0; i < this.titleBarMenus.length; i++) {
      const item = this.titleBarMenus[i];
      const iconContent: HdsNavigationIconOptions = {
        label: item.label,
        icon: item.icon,
        isEnabled: item.enabled,
        componentId: item.componentId,
        action: (): void => {
          item.action();
        }
      };
      const menuItem: HdsNavigationMenuItemOptions = {
        content: iconContent
      };
      menus.push(menuItem);
    }
    return menus;
  }

  private resolveSystemBarOriginalStyle(): HdsSystemBarStyleBundle | undefined {
    if (!this.immersiveTitleBar) {
      return undefined;
    }
    const scene = HdsTitleBarPolicy.resolveScene(this.immersiveHeroContent);
    if (scene === HdsTitleBarScene.HERO_IMMERSIVE) {
      return HdsTitleBarPolicy.buildHeroSystemBarOriginalStyle();
    }
    return HdsTitleBarPolicy.buildSystemBarStyle(this.metrics.colorMode);
  }

  private resolveSystemBarScrollStyle(): HdsSystemBarStyleBundle | undefined {
    if (!this.immersiveTitleBar) {
      return undefined;
    }
    return HdsTitleBarPolicy.buildSystemBarStyle(this.metrics.colorMode);
  }

  private resolveHorizontalPadding(): number {
    if (this.contentEdgeToEdge) {
      return 0;
    }
    return WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint);
  }

  private resolveBottomPadding(): number {
    if (this.bottomPaddingVp >= 0) {
      return this.bottomPaddingVp;
    }
    if (this.isEdgeToEdgeFill()) {
      return 0;
    }
    const navInset = this.metrics.navigationBottomInsetVp;
    if (this.destinationKind === YoNavDestinationKind.ROOT_TAB) {
      if (WindowWidthBreakpointUtil.isSideNavCapable(this.metrics.breakpoint)) {
        return navInset + YoResponsive.FORM_GAP;
      }
      return YoNavigationToken.FLOATING_TAB_BOTTOM_PADDING;
    }
    return navInset + YoResponsive.FORM_GAP;
  }
}

export { YoTitleBarMenuItem };
