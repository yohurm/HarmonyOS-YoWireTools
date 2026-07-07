import { SymbolGlyphModifier } from '@kit.ArkUI';
import { hdsMaterial, HdsTabs, HdsTabsController } from '@kit.UIDesignKit';
import { UiColorToken } from '../theme/UiColorToken';

/**
 * V2 app shell: only keeps the bottom HdsTabs bar and empty tab pages.
 */
@ComponentV2
export struct YoAppShell {
  @Param currentTabIndex: number = 0;
  @Event onTabChange: (index: number) => void = (_index: number) => {
  };
  private tabsController: HdsTabsController = new HdsTabsController();
  private workbenchIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.house'));
  private bluetoothIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.trunk'));
  private networkIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.ohos_wifi'));
  private nearlinkIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.card_writer'));
  private moreIcon: SymbolGlyphModifier = new SymbolGlyphModifier($r('sys.symbol.more'));
  @Local materialLevel: hdsMaterial.MaterialLevel = hdsMaterial.MaterialLevel.EXQUISITE;

  aboutToAppear(): void {
    const types = hdsMaterial.getSystemMaterialTypes();
    if (types.indexOf(hdsMaterial.MaterialType.IMMERSIVE) < 0) {
      this.materialLevel = hdsMaterial.MaterialLevel.SMOOTH;
    }
  }

  build() {
    Column() {
      HdsTabs({
        controller: this.tabsController,
        index: this.currentTabIndex,
        barPosition: BarPosition.End
      }) {
        TabContent() {
        }
        .tabBar(BottomTabBarStyle.of({ normal: this.workbenchIcon }, $r('app.string.tab_workbench')))

        TabContent() {
        }
        .tabBar(BottomTabBarStyle.of({ normal: this.bluetoothIcon }, $r('app.string.tab_bluetooth')))

        TabContent() {
        }
        .tabBar(BottomTabBarStyle.of({ normal: this.networkIcon }, $r('app.string.tab_network')))

        TabContent() {
        }
        .tabBar(BottomTabBarStyle.of({ normal: this.nearlinkIcon }, $r('app.string.tab_nearlink')))

        TabContent() {
        }
        .tabBar(BottomTabBarStyle.of({ normal: this.moreIcon }, $r('app.string.tab_more')))
      }
      .barOverlap(true)
      .barPosition(BarPosition.End)
      .vertical(false)
      .barFloatingStyle({
        barBottomMargin: 28,
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
    .width('100%')
    .height('100%')
    .backgroundColor(UiColorToken.BACKGROUND)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
