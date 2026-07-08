import { YoAppShell } from 'common_ui';
import { BluetoothFeaturePage } from 'feature_bluetooth';
import { HomeFeaturePage } from 'feature_home';
import { NearLinkFeaturePage } from 'feature_nearlink';
import { WifiFeaturePage } from 'feature_wifi_network';
import { AppRoutes } from '../navigation/AppRoutes';
import { MoreFeaturePage } from './MoreFeaturePage';

@Builder
function workbenchTab() {
  HomeFeaturePage()
}

@Builder
function bluetoothTab() {
  BluetoothFeaturePage()
}

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

  build() {
    YoAppShell({
      currentTabIndex: this.currentTabIndex,
      onTabChange: (index: number) => {
        this.onTabChange(index);
      },
      workbenchContent: workbenchTab,
      bluetoothContent: bluetoothTab,
      networkContent: networkTab,
      nearlinkContent: nearlinkTab,
      moreContent: moreTab
    })
  }
}
