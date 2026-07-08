import { SymbolGlyphModifier } from '@kit.ArkUI';
import { hdsMaterial, HdsTabs, HdsTabsController } from '@kit.UIDesignKit';
import {
  WindowMetricsRegistry,
  WindowMetricsState,
  WindowWidthBreakpoint,
  WindowWidthBreakpointUtil
} from 'common_platform';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiColorToken } from '../theme/UiColorToken';
import { YoSideNavItem, YoSideNavRail } from './YoSideNavRail';

/**
 * Responsive app shell:
 * - <840vp: bottom floating HdsTabs
 * - >=840vp: side navigation rail + content (响应式应用架构)
 */
@ComponentV2
export struct YoAppShell {
  @Param currentTabIndex: number = 0;
  @Event onTabChange: (index: number) => void = (_index: number) => {
  };
  @BuilderParam workbenchContent: () => void = this.defaultTabContent;
  @BuilderParam bluetoothContent: () => void = this.defaultTabContent;
  @BuilderParam networkContent: () => void = this.defaultTabContent;
  @BuilderParam nearlinkContent: () => void = this.defaultTabContent;
  @BuilderParam moreContent: () => void = this.defaultTabContent;
  @Local private metrics: WindowMetricsState = WindowMetricsRegistry.connect();
  @Local materialLevel: hdsMaterial.MaterialLevel = hdsMaterial.MaterialLevel.EXQUISITE;
  private tabsController: HdsTabsController = new HdsTabsController();
  private sideNavItems: YoSideNavItem[] = [
    { index: 0, label: $r('app.string.tab_workbench'), symbol: $r('sys.symbol.house') },
    { index: 1, label: $r('app.string.tab_bluetooth'), symbol: $r('sys.symbol.trunk') },
    { index: 2, label: $r('app.string.tab_network'), symbol: $r('sys.symbol.ohos_wifi') },
    { index: 3, label: $r('app.string.tab_nearlink'), symbol: $r('sys.symbol.card_writer') },
    { index: 4, label: $r('app.string.tab_more'), symbol: $r('sys.symbol.more') }
  ];
  private workbenchIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.house'));
  private bluetoothIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.trunk'));
  private networkIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.ohos_wifi'));
  private nearlinkIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.card_writer'));
  private moreIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.more'));

  aboutToAppear(): void {
    const types = hdsMaterial.getSystemMaterialTypes();
    if (types.indexOf(hdsMaterial.MaterialType.IMMERSIVE) < 0) {
      this.materialLevel = hdsMaterial.MaterialLevel.SMOOTH;
    }
  }

  @Builder
  defaultTabContent() {
  }

  build() {
    Column() {
      if (this.metrics.breakpoint === WindowWidthBreakpoint.XL) {
        Row() {
          Column() {
            this.responsiveShell()
          }
          .width('100%')
          .constraintSize({ maxWidth: UiLayoutConstants.CONTENT_MAX_WIDTH_XL })
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
    .backgroundColor(UiColorToken.BACKGROUND)
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
        items: this.sideNavItems,
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
        this.workbenchContent()
      }
      .tabBar(BottomTabBarStyle.of({ normal: this.workbenchIcon }, $r('app.string.tab_workbench')))

      TabContent() {
        this.bluetoothContent()
      }
      .tabBar(BottomTabBarStyle.of({ normal: this.bluetoothIcon }, $r('app.string.tab_bluetooth')))

      TabContent() {
        this.networkContent()
      }
      .tabBar(BottomTabBarStyle.of({ normal: this.networkIcon }, $r('app.string.tab_network')))

      TabContent() {
        this.nearlinkContent()
      }
      .tabBar(BottomTabBarStyle.of({ normal: this.nearlinkIcon }, $r('app.string.tab_nearlink')))

      TabContent() {
        this.moreContent()
      }
      .tabBar(BottomTabBarStyle.of({ normal: this.moreIcon }, $r('app.string.tab_more')))
    }
    .barOverlap(true)
    .barPosition(BarPosition.End)
    .vertical(false)
    .barFloatingStyle({
      barBottomMargin: UiLayoutConstants.FLOATING_TAB_BAR_MARGIN,
      systemMaterialEffect: {
        materialType: hdsMaterial.MaterialType.ADAPTIVE,
        materialLevel: this.materialLevel
      }
    })
    .width('100%')
    .height('100%')
    .backgroundColor(UiColorToken.BACKGROUND)
    .onChange((index: number) => {
      this.onTabChange(index);
    })
  }

  @Builder
  private activeTabContent() {
    if (this.currentTabIndex === 0) {
      this.workbenchContent()
    } else if (this.currentTabIndex === 1) {
      this.bluetoothContent()
    } else if (this.currentTabIndex === 2) {
      this.networkContent()
    } else if (this.currentTabIndex === 3) {
      this.nearlinkContent()
    } else {
      this.moreContent()
    }
  }
}
