import {
  YoActionButton,
  YoContentState,
  YoEmptyStateModel,
  YoErrorStateModel,
  YoLoadingStateModel,
  YoModeEntryCard,
  YoNavDestinationKind,
  YoPageShell,
  YoPageState,
  YoSpace,
  YoStatusPill
} from 'youi_kit';
import { WifiDebugRoutes } from '../navigation/WifiDebugRoutes';
import { WifiDebugViewModel } from '../viewmodel/WifiDebugViewModel';
import { wifiLogMenu } from './WifiDebugWidgets';

@ComponentV2
export struct WifiOverviewPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onOpen: (name: string) => void = (_name: string) => {
  };

  @LocalBuilder
  pageBody() {
    Column({ space: YoSpace.L }) {
      Row({ space: YoSpace.S }) {
        YoStatusPill({
          label: this.vm.wifiActiveLabel,
          tone: this.vm.wifiActiveLabel === '已激活' ? 'success' : 'neutral'
        })
        YoStatusPill({ label: `netId ${this.vm.netIdLabel}`, tone: 'info' })
        YoStatusPill({ label: this.vm.cachePill, tone: 'neutral' })
      }
      .width('100%')

      YoModeEntryCard({
        title: '权限与能力',
        description: this.vm.features.length > 0 ? '能力已列出' : '未读取',
        statusLabel: this.vm.featureState === YoPageState.ERROR ? '本机不支持 801' : '未读取',
        statusTone: 'neutral',
        onTap: () => this.onOpen(WifiDebugRoutes.PERMISSION)
      })
      YoModeEntryCard({
        title: 'WLAN 状态',
        description: this.vm.wifiActiveLabel,
        statusLabel: this.vm.wifiActiveLabel,
        statusTone: this.vm.wifiActiveLabel === '已激活' ? 'success' : 'neutral',
        onTap: () => this.onOpen(WifiDebugRoutes.WLAN)
      })
      YoModeEntryCard({
        title: '扫描',
        description: this.vm.cachePill,
        statusLabel: this.vm.scanStatus.length > 0 ? this.vm.scanStatus : '未读取',
        statusTone: 'neutral',
        onTap: () => this.onOpen(WifiDebugRoutes.SCAN)
      })
      YoModeEntryCard({
        title: '链路',
        description: this.vm.link !== undefined && this.vm.link.connected ? this.vm.link.ssid : '未连接',
        statusLabel: this.vm.link !== undefined && this.vm.link.connected ? '已连接' : '未读取',
        statusTone: 'neutral',
        onTap: () => this.onOpen(WifiDebugRoutes.LINK)
      })
      YoModeEntryCard({
        title: '连接',
        description: '候选网络',
        statusLabel: '未读取',
        statusTone: 'neutral',
        onTap: () => this.onOpen(WifiDebugRoutes.CONNECT)
      })
      YoModeEntryCard({
        title: '默认网络',
        description: this.vm.capabilityLabel,
        statusLabel: this.vm.netIdLabel,
        statusTone: 'neutral',
        onTap: () => this.onOpen(WifiDebugRoutes.DEFAULT_NET)
      })
      YoModeEntryCard({
        title: '地址与诊断',
        description: '属性、DNS、端口',
        statusLabel: '未读取',
        statusTone: 'neutral',
        onTap: () => this.onOpen(WifiDebugRoutes.ADDRESS)
      })
      YoModeEntryCard({
        title: '吞吐',
        description: this.vm.bandwidthLabel,
        statusLabel: this.vm.speedPhase,
        statusTone: 'neutral',
        onTap: () => this.onOpen(WifiDebugRoutes.THROUGHPUT)
      })
      YoModeEntryCard({
        title: '连接检查',
        description: '本应用 HTTP',
        statusLabel: '未读取',
        statusTone: 'neutral',
        onTap: () => this.onOpen(WifiDebugRoutes.INSPECT)
      })
      YoModeEntryCard({
        title: '局域网',
        description: this.vm.lanError.length > 0 ? this.vm.lanError : 'mDNS',
        statusLabel: '未读取',
        statusTone: 'neutral',
        onTap: () => this.onOpen(WifiDebugRoutes.LAN)
      })
      YoModeEntryCard({
        title: '权限墙',
        description: '需系统设置或未提供',
        statusLabel: '需系统设置',
        statusTone: 'warning',
        onTap: () => this.onOpen(WifiDebugRoutes.WALL)
      })
    }
    .width('100%')
  }

  @LocalBuilder
  pageContent() {
    YoContentState({
      state: this.vm.pageState,
      loadingModel: new YoLoadingStateModel(this.vm.loadingText),
      emptyModel: new YoEmptyStateModel('尚未读取', '从 WLAN 状态或扫描开始', '', '打开 WLAN 状态'),
      errorModel: new YoErrorStateModel(
        this.vm.errorUser,
        this.vm.errorCause,
        this.vm.errorNext,
        '',
        this.vm.errorCode,
        true,
        '重试'
      ),
      content: this.pageBody,
      onEmptyPrimaryAction: () => this.onOpen(WifiDebugRoutes.WLAN),
      onRetry: () => {
        void this.vm.enter();
      }
    })
  }

  build() {
    YoPageShell({
      title: $r('app.string.wifi_title_overview'),
      destinationKind: YoNavDestinationKind.ROOT_TAB,
      titleBarMenus: wifiLogMenu(() => this.onOpen(WifiDebugRoutes.LOG)),
      content: this.pageContent
    })
  }
}

@ComponentV2
export struct WifiBackShell {
  @Param title: string = '';
  @Param kind: YoNavDestinationKind = YoNavDestinationKind.MODULE;
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };
  @BuilderParam content: () => void = this.empty;

  @Builder
  empty() {
  }

  @Builder
  forward() {
    this.content()
  }

  build() {
    YoPageShell({
      title: this.title,
      showBack: true,
      destinationKind: this.kind,
      titleBarMenus: wifiLogMenu(() => this.onOpenLog()),
      onBack: () => this.onBack(),
      content: this.forward
    })
  }
}
