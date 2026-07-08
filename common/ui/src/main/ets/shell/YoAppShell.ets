import { SymbolGlyphModifier } from '@kit.ArkUI';
import { hdsMaterial, HdsTabs, HdsTabsController } from '@kit.UIDesignKit';
import { UiLayoutConstants } from '../theme/UiLayoutConstants';
import { UiColorToken } from '../theme/UiColorToken';

/**
 * V2 app shell: bottom HdsTabs with one root page per tab via BuilderParam slots.
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

  @Builder
  defaultTabContent() {
  }

  build() {
    Column() {
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
    .width('100%')
    .height('100%')
    .backgroundColor(UiColorToken.BACKGROUND)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
