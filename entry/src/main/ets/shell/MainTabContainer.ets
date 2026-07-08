import { YoAppShell } from 'common_ui';
import { BluetoothFeaturePage } from 'feature_bluetooth';
import { HomeFeaturePage } from 'feature_home';
import { NearLinkFeaturePage } from 'feature_nearlink';
import { WifiFeaturePage } from 'feature_wifi_network';
import { AppRoutes } from '../navigation/AppRoutes';
import { MoreFeaturePage } from './MoreFeaturePage';

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
      workbenchContent: (): void => {
        this.workbenchTab();
      },
      bluetoothContent: (): void => {
        this.bluetoothTab();
      },
      networkContent: (): void => {
        this.networkTab();
      },
      nearlinkContent: (): void => {
        this.nearlinkTab();
      },
      moreContent: (): void => {
        this.moreTab();
      }
    })
  }

  @Builder
  workbenchTab() {
    HomeFeaturePage()
  }

  @Builder
  bluetoothTab() {
    BluetoothFeaturePage()
  }

  @Builder
  networkTab() {
    WifiFeaturePage()
  }

  @Builder
  nearlinkTab() {
    NearLinkFeaturePage()
  }

  @Builder
  moreTab() {
    MoreFeaturePage()
  }
}
