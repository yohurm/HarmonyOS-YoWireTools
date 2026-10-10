import { FeatureModuleId } from 'debug_core';
import { YoAppShell, YoSideNavItem } from 'youi_kit';
import { HomeFeaturePage } from 'feature_home';
import { NearLinkFeaturePage } from 'feature_nearlink';
import { WifiFeaturePage } from 'feature_wifi_network';
import { AppRoutes } from '../navigation/AppRoutes';
import { BluetoothOverviewPage } from '../pages/bluetooth/BluetoothOverviewPage';
import { AppSettingsPage } from './AppSettingsPage';
import { WorkbenchRadioState } from './WorkbenchRadioState';

@ComponentV2
export struct MainTabContainer {
  @Param currentTabIndex: number = AppRoutes.TAB_INDEX_HOME;
  @Event onTabChange: (index: number) => void = (_index: number) => {
  };
  @Event onOpenBluetoothSpp: () => void = () => {
  };
  @Event onOpenBluetoothBle: () => void = () => {
  };
  @Event onOpenBluetoothSettings: () => void = () => {
  };
  @Event onOpenBluetoothCommand: () => void = () => {
  };
  @Event onOpenNearLinkSettings: () => void = () => {
  };
  @Event onOpenNearLinkCommand: () => void = () => {
  };
  @Event onOpenWifiSettings: () => void = () => {
  };
  @Event onOpenWifiCommand: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };
  @Local radio: WorkbenchRadioState = new WorkbenchRadioState();
  private readonly tabItems: YoSideNavItem[] = [
    { index: 0, label: $r('app.string.tab_workbench'), symbol: $r('sys.symbol.house') },
    { index: 1, label: $r('app.string.tab_bluetooth'), symbol: $r('sys.symbol.trunk') },
    { index: 2, label: $r('app.string.tab_nearlink'), symbol: $r('sys.symbol.card_writer') },
    { index: 3, label: $r('app.string.tab_network'), symbol: $r('sys.symbol.ohos_wifi') },
    { index: 4, label: $r('app.string.tab_settings'), symbol: $r('sys.symbol.gear') }
  ];

  @LocalBuilder
  homeTab() {
    HomeFeaturePage({
      bluetoothReading: this.radio.bluetooth,
      wlanReading: this.radio.wlan,
      nearlinkReading: this.radio.nearlink,
      onOpenModule: (moduleId: string) => {
        this.openModule(moduleId);
      },
      onOpenAppSettings: () => {
        this.onTabChange(AppRoutes.TAB_INDEX_SETTINGS);
      },
      onOpenLog: () => {
        this.onOpenLog();
      }
    })
  }

  aboutToAppear(): void {
    this.radio.refresh();
  }

  private openModule(moduleId: string): void {
    if (moduleId === FeatureModuleId.BLUETOOTH) {
      this.onTabChange(AppRoutes.TAB_INDEX_BLUETOOTH);
      return;
    }
    if (moduleId === FeatureModuleId.NEARLINK) {
      this.onTabChange(AppRoutes.TAB_INDEX_NEARLINK);
      return;
    }
    if (moduleId === FeatureModuleId.WIFI) {
      this.onTabChange(AppRoutes.TAB_INDEX_WIFI);
    }
  }

  @LocalBuilder
  bluetoothTab() {
    BluetoothOverviewPage({
      onOpenSpp: this.onOpenBluetoothSpp,
      onOpenBle: this.onOpenBluetoothBle,
      onOpenModuleSettings: this.onOpenBluetoothSettings,
      onOpenCommand: this.onOpenBluetoothCommand
    })
  }

  @LocalBuilder
  nearlinkTab() {
    NearLinkFeaturePage({
      onOpenModuleSettings: this.onOpenNearLinkSettings,
      onOpenCommand: this.onOpenNearLinkCommand
    })
  }

  @LocalBuilder
  wifiTab() {
    WifiFeaturePage({
      onOpenModuleSettings: this.onOpenWifiSettings,
      onOpenCommand: this.onOpenWifiCommand
    })
  }

  @LocalBuilder
  settingsTab() {
    AppSettingsPage()
  }

  build() {
    YoAppShell({
      currentTabIndex: this.currentTabIndex,
      items: this.tabItems,
      onTabChange: (index: number) => {
        this.onTabChange(index);
        if (index === AppRoutes.TAB_INDEX_HOME) {
          this.radio.refresh();
        }
      },
      tabContent0: this.homeTab,
      tabContent1: this.bluetoothTab,
      tabContent2: this.nearlinkTab,
      tabContent3: this.wifiTab,
      tabContent4: this.settingsTab
    })
  }
}
