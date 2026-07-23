import { HdsNavigation, HdsNavigationTitleMode, HdsNavigationMenuItemOptions, HdsNavigationIconOptions, HdsNavigationMenuContentOptions } from '@kit.UIDesignKit';
import { WindowMetricsRegistry, WindowMetricsState, WindowWidthBreakpointUtil } from 'common_platform';
import { NavigationToken } from '../token/component/NavigationToken';
import { UiColor } from '../token/semantic/UiColor';
import { UiResponsive } from '../token/semantic/UiResponsive';
import { UiTypeStyle } from '../token/semantic/UiTypeStyle';
import { YoNavDestinationKind } from '../shell/YoNavDestinationKind';
import {
  HdsSystemBarStyleBundle,
  HdsTitleBarPolicy,
  HdsTitleBarScene,
  YoNavigationTitleBarConfig,
  YoTitleBarContent
} from '../theme/HdsTitleBarPolicy';
import { UiResourceUtil } from '../util/UiResourceUtil';
import { YoTitleBarMenuItem } from '../model/YoTitleBarMenuItem';
import { YoContextStrip, YoContextStripItem } from './YoContextStrip';

/**
 * L4 页面壳：HdsNavigation 标题栏沉浸 + 内容安全区。
 */
@ComponentV2
export struct YoPageShell {
  @Param title: ResourceStr = '';
  @Param subtitle: ResourceStr = '';
  @Param showBack: boolean = false;
  @Param destinationKind: YoNavDestinationKind = YoNavDestinationKind.ROOT_TAB;
  @Param contextItems: YoContextStripItem[] = [];
  @Param contextRiskMessage: ResourceStr = '';
  @Param titleBarMenus: YoTitleBarMenuItem[] = [];
  @Param scrollable: boolean = true;
  /**
   * When true, page content owns horizontal insets (typical for full-width List pages).
   * Keeps scrollbar flush to the content viewport edge per ArkUI scrollable guidance.
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
            Column({ space: UiResponsive.SECTION_GAP }) {
              if (UiResourceUtil.hasText(this.subtitle)) {
                Text(this.subtitle)
                  .fontSize(UiTypeStyle.BODY_S.size)
                  .fontColor(UiColor.TEXT_SECONDARY)
                  .width('100%')
                  .padding({
                    left: this.resolveHorizontalPadding(),
                    right: this.resolveHorizontalPadding()
                  })
                  .maxLines(2)
                  .textOverflow({ overflow: TextOverflow.Ellipsis })
              }
              YoContextStrip({
                items: this.contextItems,
                riskMessage: this.contextRiskMessage
              })
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
          Column({ space: this.isEdgeToEdgeFill() ? 0 : UiResponsive.SECTION_GAP }) {
            YoContextStrip({
              items: this.contextItems,
              riskMessage: this.contextRiskMessage
            })
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
    .backgroundColor(UiColor.BACKGROUND_PRIMARY)
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
    // Edge-to-edge fill pages draw under the gesture bar; list footer owns the inset.
    // Adding navInset here would create a double blank band under full-screen layout.
    if (this.isEdgeToEdgeFill()) {
      return 0;
    }
    const navInset = this.metrics.navigationBottomInsetVp;
    if (this.destinationKind === YoNavDestinationKind.ROOT_TAB) {
      if (WindowWidthBreakpointUtil.isSideNavCapable(this.metrics.breakpoint)) {
        return navInset + UiResponsive.FORM_GAP;
      }
      return NavigationToken.FLOATING_TAB_BOTTOM_PADDING;
    }
    return navInset + UiResponsive.FORM_GAP;
  }
}

export { YoContextStripItem };
export { YoTitleBarMenuItem };
