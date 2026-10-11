import { YoAppShell, YoSideNavItem } from 'youi_kit';
import { HomeFeaturePage } from 'feature_home';
import { NearLinkFeaturePage } from 'feature_nearlink';
import { WifiFeaturePage } from 'feature_wifi_network';
import { AppRoutes } from '../navigation/AppRoutes';
import { BluetoothOverviewPage } from '../pages/bluetooth/BluetoothOverviewPage';
import { MoreFeaturePage } from './MoreFeaturePage';

@Builder
function networkTab() {
  WifiFeaturePage()
}

@Builder
function nearlinkTab() {
  NearLinkFeaturePage()
}

@Builder
function moreTab() {
  MoreFeaturePage()
}

@ComponentV2
export struct MainTabContainer {
  @Param currentTabIndex: number = AppRoutes.TAB_INDEX_WORKBENCH;
  @Event onTabChange: (index: number) => void = (_index: number) => {
  };
  @Event onOpenBluetoothSpp: () => void = () => {
  };
  @Event onOpenBluetoothBle: () => void = () => {
  };
  @Event onOpenTarget: (target: string) => void = (_target: string) => {
  };
  @Event onOpenBluetoothDiagnostics: () => void = () => {
  };
  @Event onOpenBluetoothIdentity: () => void = () => {
  };
  private readonly tabItems: YoSideNavItem[] = [
    { index: 0, label: $r('app.string.tab_workbench'), symbol: $r('sys.symbol.house') },
    { index: 1, label: $r('app.string.tab_bluetooth'), symbol: $r('sys.symbol.trunk') },
    { index: 2, label: $r('app.string.tab_network'), symbol: $r('sys.symbol.ohos_wifi') },
    { index: 3, label: $r('app.string.tab_nearlink'), symbol: $r('sys.symbol.card_writer') },
    { index: 4, label: $r('app.string.tab_more'), symbol: $r('sys.symbol.more') }
  ];

  @LocalBuilder
  workbenchTab() {
    HomeFeaturePage({
      onOpenTarget: (target: string) => {
        this.onOpenTarget(target);
      }
    })
  }

  @LocalBuilder
  bluetoothTab() {
    BluetoothOverviewPage({
      onOpenSpp: this.onOpenBluetoothSpp,
      onOpenBle: this.onOpenBluetoothBle,
      onOpenDiagnostics: this.onOpenBluetoothDiagnostics,
      onOpenIdentity: this.onOpenBluetoothIdentity
    })
  }

  build() {
    YoAppShell({
      currentTabIndex: this.currentTabIndex,
      items: this.tabItems,
      onTabChange: (index: number) => {
        this.onTabChange(index);
      },
      tabContent0: this.workbenchTab,
      tabContent1: this.bluetoothTab,
      tabContent2: networkTab,
      tabContent3: nearlinkTab,
      tabContent4: moreTab
    })
  }
}
