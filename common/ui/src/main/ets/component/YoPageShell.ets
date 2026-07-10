import { HdsNavigation, HdsNavigationTitleMode } from '@kit.UIDesignKit';
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
  @Param scrollable: boolean = true;
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
          Column({ space: UiResponsive.SECTION_GAP }) {
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
            .layoutWeight(1)
          }
          .width('100%')
          .height('100%')
          .padding({ bottom: this.resolveBottomPadding() })
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
      .ignoreLayoutSafeArea([LayoutSafeAreaType.SYSTEM], [LayoutSafeAreaEdge.TOP])
      .width('100%')
      .layoutWeight(1)
      .backgroundColor(Color.Transparent)
      this.actionDock()
    }
    .width('100%')
    .height('100%')
    .backgroundColor(UiColor.BACKGROUND_PRIMARY)
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
    const config: YoNavigationTitleBarConfig = {
      avoidLayoutSafeArea: true,
      enableComponentSafeArea: true,
      style,
      content
    };
    return config;
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
    return WindowWidthBreakpointUtil.pagePaddingVp(this.metrics.breakpoint);
  }

  private resolveBottomPadding(): number {
    if (this.bottomPaddingVp >= 0) {
      return this.bottomPaddingVp;
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
