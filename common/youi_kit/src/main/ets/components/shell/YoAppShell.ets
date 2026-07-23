import { SymbolGlyphModifier } from '@kit.ArkUI';
import { hdsMaterial, HdsTabs, HdsTabsController } from '@kit.UIDesignKit';
import {
  WindowMetricsRegistry,
  WindowMetricsState,
  WindowWidthBreakpoint,
  WindowWidthBreakpointUtil
} from 'common_platform';
import { YoNavigationToken } from '../../token/component/YoNavigationToken';
import { YoColor } from '../../token/semantic/YoColor';
import { YoResponsive } from '../../token/semantic/YoResponsive';
import { YoSideNavItem, YoSideNavRail } from './YoSideNavRail';

/**
 * 响应式应用壳（与具体产品无关）：
 * - <840vp：底部浮动 HdsTabs
 * - >=840vp：侧边导航栏 + 内容区
 *
 * Tab 文案 / 符号 / 页面内容由 Entry 注入。
 */
@ComponentV2
export struct YoAppShell {
  @Param currentTabIndex: number = 0;
  @Param items: YoSideNavItem[] = [];
  @Event onTabChange: (index: number) => void = (_index: number) => {
  };
  @BuilderParam tabContent0: () => void = this.defaultTabContent;
  @BuilderParam tabContent1: () => void = this.defaultTabContent;
  @BuilderParam tabContent2: () => void = this.defaultTabContent;
  @BuilderParam tabContent3: () => void = this.defaultTabContent;
  @BuilderParam tabContent4: () => void = this.defaultTabContent;
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();
  private tabsController: HdsTabsController = new HdsTabsController();

  @Builder
  defaultTabContent() {
  }

  private labelAt(index: number): ResourceStr {
    if (index >= 0 && index < this.items.length) {
      return this.items[index].label;
    }
    return '';
  }

  private iconAt(index: number): SymbolGlyphModifier {
    const symbol: Resource = (index >= 0 && index < this.items.length) ?
      this.items[index].symbol :
      $r('sys.symbol.circle');
    return new SymbolGlyphModifier(symbol);
  }

  build() {
    Column() {
      if (this.metrics.breakpoint === WindowWidthBreakpoint.XL) {
        Row() {
          Column() {
            this.responsiveShell()
          }
          .width('100%')
          .constraintSize({ maxWidth: YoResponsive.CONTENT_MAX_WIDTH })
        }
        .width('100%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
      } else {
        this.responsiveShell()
      }
    }
    .width('100%')
    .height('100%')
    .backgroundColor(YoColor.BACKGROUND_PRIMARY)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }

  @Builder
  private responsiveShell() {
    if (WindowWidthBreakpointUtil.isSideNavCapable(this.metrics.breakpoint)) {
      this.sideNavShell()
    } else {
      this.bottomTabShell()
    }
  }

  @Builder
  private sideNavShell() {
    Row() {
      YoSideNavRail({
        currentIndex: this.currentTabIndex,
        items: this.items,
        onSelect: (index: number) => {
          this.onTabChange(index);
        }
      })
      Column() {
        this.activeTabContent()
      }
      .layoutWeight(1)
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private bottomTabShell() {
    HdsTabs({
      controller: this.tabsController,
      index: this.currentTabIndex,
      barPosition: BarPosition.End
    }) {
      TabContent() {
        this.tabContent0()
      }
      .tabBar(BottomTabBarStyle.of({ normal: this.iconAt(0) }, this.labelAt(0)))

      TabContent() {
        this.tabContent1()
      }
      .tabBar(BottomTabBarStyle.of({ normal: this.iconAt(1) }, this.labelAt(1)))

      TabContent() {
        this.tabContent2()
      }
      .tabBar(BottomTabBarStyle.of({ normal: this.iconAt(2) }, this.labelAt(2)))

      TabContent() {
        this.tabContent3()
      }
      .tabBar(BottomTabBarStyle.of({ normal: this.iconAt(3) }, this.labelAt(3)))

      TabContent() {
        this.tabContent4()
      }
      .tabBar(BottomTabBarStyle.of({ normal: this.iconAt(4) }, this.labelAt(4)))
    }
    .barOverlap(true)
    .barPosition(BarPosition.End)
    .vertical(false)
    .barFloatingStyle({
      barBottomMargin: YoNavigationToken.FLOATING_TAB_MARGIN,
      systemMaterialEffect: {
        materialType: hdsMaterial.MaterialType.ADAPTIVE,
        materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
      }
    })
    .width('100%')
    .height('100%')
    .backgroundColor(YoColor.BACKGROUND_PRIMARY)
    .onChange((index: number) => {
      this.onTabChange(index);
    })
  }

  @Builder
  private activeTabContent() {
    if (this.currentTabIndex === 0) {
      this.tabContent0()
    } else if (this.currentTabIndex === 1) {
      this.tabContent1()
    } else if (this.currentTabIndex === 2) {
      this.tabContent2()
    } else if (this.currentTabIndex === 3) {
      this.tabContent3()
    } else {
      this.tabContent4()
    }
  }
}
