import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoSpace,
  YoSplitScaffold,
  YoStatusPill,
  YoTypeStyle
} from 'youi_kit';
import { YoSegmentButton } from 'youi_kit';
import { WifiAccessPointSnapshot } from '../../domain/model/WifiAccessPointSnapshot';
import { WifiChannelOccupancyRow } from '../../domain/model/WifiDebugFacts';
import { WifiDebugViewModel } from '../viewmodel/WifiDebugViewModel';
import { WifiBackShell } from './WifiOverviewPage';
import { WifiFactText, WifiFieldInput } from './WifiDebugWidgets';

@ComponentV2
export struct WifiScanPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };
  @Event onOpenChannel: () => void = () => {
  };
  @Event onOpenAp: (id: string) => void = (_id: string) => {
  };

  @LocalBuilder
  scanList() {
    Column({ space: YoSpace.S }) {
      if (this.vm.groupBySsid) {
        ForEach(this.vm.ssidGroups(), (ssid: string) => {
          Column({ space: YoSpace.XS }) {
            Text(ssid)
              .fontSize(YoTypeStyle.SUBTITLE_S.size)
              .fontColor(YoColor.TEXT_PRIMARY)
              .width('100%')
              .onClick(() => this.vm.toggleGroupRow(ssid))
            if (this.vm.isGroupOpen(ssid)) {
              ForEach(this.vm.rowsForSsid(ssid), (row: WifiAccessPointSnapshot) => {
                this.apRow(row)
              }, (row: WifiAccessPointSnapshot) => row.id)
            }
          }
          .width('100%')
        }, (ssid: string) => ssid)
      } else {
        ForEach(this.vm.visibleRows(), (row: WifiAccessPointSnapshot) => {
          this.apRow(row)
        }, (row: WifiAccessPointSnapshot) => row.id)
      }
    }
    .width('100%')
  }

  @Builder
  apRow(row: WifiAccessPointSnapshot) {
    Column({ space: YoSpace.XS }) {
      Text(row.ssid.length > 0 ? row.ssid : '空 SSID')
        .fontSize(YoTypeStyle.SUBTITLE_S.size)
        .fontColor(YoColor.TEXT_PRIMARY)
      Text(`${row.securityType}  ${row.rssi} dBm  ${row.frequency}  ${row.channelWidthLabel}`)
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
      Text(`信道 ${row.channel} · 由频率换算  ${row.addressKind.length > 0 ? row.addressKind : '随机地址'}`)
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_TERTIARY)
      Text(`噪声 ${this.vm.gapLabel()}  SNR ${this.vm.gapLabel()}  MCS ${this.vm.gapLabel()}  重传 ${this.vm.gapLabel()}`)
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_TERTIARY)
    }
    .width('100%')
    .padding({ top: YoSpace.S, bottom: YoSpace.S })
    .onClick(() => {
      this.vm.selectRow(row.id);
      this.onOpenAp(row.id);
    })
  }

  @LocalBuilder
  scanBody() {
    Column({ space: YoSpace.M }) {
      Row({ space: YoSpace.S }) {
        YoStatusPill({ label: '缓存', tone: 'neutral' })
        Text(this.vm.cacheTimeText.length > 0 ? `缓存于 ${this.vm.cacheTimeText}` : '距读取 n 秒')
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
        Text(this.vm.cooldownText.length > 0 ? this.vm.cooldownText : '2 分钟内还可扫描 4 次')
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_SECONDARY)
      }
      .width('100%')
      if (this.vm.emulatorNotPassed) {
        YoStatusPill({ label: '未通过 · 未用真机', tone: 'warning' })
      }
      if (this.vm.scanFailure.length > 0) {
        Text(`${this.vm.scanFailure} ${this.vm.scanFailureCode}`)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.WARNING)
          .width('100%')
      }
      WifiFieldInput({
        label: 'SSID',
        text: this.vm.filterSsid,
        onValue: (value: string) => this.vm.setFilterSsid(value)
      })
      YoSegmentButton({
        labels: ['全部', '2.4 GHz', '5 GHz'],
        initialIndex: this.vm.filterBand,
        onSelectedIndexChange: (index: number) => this.vm.setFilterBand(index)
      })
      YoSegmentButton({
        labels: ['全部', '0', '1', '2', '3', '4'],
        initialIndex: this.vm.filterSignal < 0 ? 0 : this.vm.filterSignal + 1,
        onSelectedIndexChange: (index: number) => this.vm.setFilterSignal(index === 0 ? -1 : index - 1)
      })
      YoSegmentButton({
        labels: ['全部', 'OPEN', 'PSK', 'SAE', 'EAP'],
        initialIndex: 0,
        onSelectedIndexChange: (index: number) => this.vm.setFilterSecurity(this.securityAt(index))
      })
      if (this.vm.scanStatus === '缓存' && this.vm.visibleRows().length === 0) {
        Text('缓存中没有接入点')
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
      } else {
        YoSplitScaffold({
          listPane: this.scanList,
          detailPane: this.detailPane
        })
      }
      YoActionButton({
        label: '扫描',
        isEnabled: this.vm.scanDisabledReason().length === 0 && !this.vm.scanLoading,
        loading: this.vm.scanLoading,
        disabledReason: this.vm.scanDisabledReason(),
        onTap: () => {
          void this.vm.scan();
        }
      })
      YoActionButton({
        label: this.vm.scanPaused ? '继续' : '暂停',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          if (this.vm.scanPaused) {
            this.vm.resumeScan();
          } else {
            this.vm.pauseScan();
          }
        }
      })
      YoActionButton({
        label: '只刷新缓存',
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          void this.vm.refreshCacheOnly();
        }
      })
      YoActionButton({
        label: '信道',
        kind: YoActionButtonKind.TEXT,
        onTap: () => this.onOpenChannel()
      })
      YoActionButton({
        label: this.vm.groupBySsid ? '取消分组' : '按 SSID 分组',
        kind: YoActionButtonKind.TEXT,
        onTap: () => this.vm.toggleGroup()
      })
      YoActionButton({
        label: '导出',
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          void this.vm.exportScan();
        }
      })
    }
    .width('100%')
  }

  private securityAt(index: number): string {
    if (index === 1) {
      return 'OPEN';
    }
    if (index === 2) {
      return 'PSK';
    }
    if (index === 3) {
      return 'SAE';
    }
    if (index === 4) {
      return 'EAP';
    }
    return '';
  }

  private selectedFrequency(): string {
    const row = this.vm.selectedRow();
    if (row === undefined) {
      return '';
    }
    return `${row.frequency}`;
  }

  @LocalBuilder
  detailPane() {
    Column({ space: YoSpace.S }) {
      if (this.vm.selectedRow() === undefined) {
        Text('选择一项接入点')
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
      } else {
        WifiFactText({ text: this.vm.selectedTitle })
        WifiFactText({ text: this.selectedFrequency() })
      }
    }
    .width('100%')
  }

  build() {
    WifiBackShell({
      title: '扫描',
      kind: YoNavDestinationKind.MODULE,
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.scanBody
    })
  }
}

@ComponentV2
export struct WifiAccessPointPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  private apLine(kind: string): string {
    const row = this.vm.selectedRow();
    if (row === undefined) {
      return '';
    }
    if (kind === 'ssid') {
      return row.ssid.length > 0 ? row.ssid : '空 SSID';
    }
    if (kind === 'rssi') {
      return `RSSI ${row.rssi} dBm`;
    }
    if (kind === 'freq') {
      return `频率 ${row.frequency}`;
    }
    if (kind === 'sec') {
      return `加密 ${row.securityType}`;
    }
    if (kind === 'width') {
      return `带宽 ${row.channelWidthLabel}`;
    }
    if (kind === 'channel') {
      return `信道 ${row.channel} · 由频率换算`;
    }
    return row.addressKind.length > 0 ? row.addressKind : '随机地址';
  }

  @LocalBuilder
  body() {
    Column({ space: YoSpace.S }) {
      if (this.vm.selectedRow() === undefined) {
        Text('隐藏网络')
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_SECONDARY)
      } else {
        WifiFactText({ text: this.apLine('ssid') })
        WifiFactText({ text: this.apLine('rssi') })
        WifiFactText({ text: this.apLine('freq') })
        WifiFactText({ text: this.apLine('sec') })
        WifiFactText({ text: this.apLine('width') })
        WifiFactText({ text: this.apLine('channel') })
        WifiFactText({ text: this.apLine('addr') })
        WifiFactText({ text: `噪声 ${this.vm.gapLabel()}` })
        YoActionButton({
          label: this.vm.showDistance ? '关闭距离估算' : '距离估算',
          kind: YoActionButtonKind.SECONDARY,
          onTap: () => {
            this.vm.showDistance = !this.vm.showDistance;
          }
        })
        if (this.vm.showDistance) {
          WifiFactText({ text: this.vm.distanceText().length > 0 ? this.vm.distanceText() : '按自由空间路径损耗估算' })
        }
      }
    }
    .width('100%')
  }

  build() {
    WifiBackShell({
      title: this.vm.selectedTitle.length > 0 ? this.vm.selectedTitle : '隐藏网络',
      kind: YoNavDestinationKind.OBJECT,
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.body
    })
  }
}

@ComponentV2
export struct WifiChannelPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  @LocalBuilder
  body() {
    Column({ space: YoSpace.S }) {
      Text('重叠估计')
        .fontSize(YoTypeStyle.BODY_S.size)
        .fontColor(YoColor.TEXT_SECONDARY)
      ForEach(this.vm.channelRows(), (row: WifiChannelOccupancyRow) => {
        Text(`信道 ${row.channel}  AP ${row.apCount}  干扰 ${row.intensity}  最强 ${row.strongestRssi} dBm`)
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_PRIMARY)
          .width('100%')
      }, (row: WifiChannelOccupancyRow) => `${row.channel}`)
      Text('推荐')
        .fontSize(YoTypeStyle.SUBTITLE_S.size)
        .fontColor(YoColor.TEXT_PRIMARY)
      ForEach(this.vm.recommendedChannels(), (row: WifiChannelOccupancyRow) => {
        Row({ space: YoSpace.S }) {
          Text(`信道 ${row.channel}`)
            .fontSize(YoTypeStyle.BODY_M.size)
            .fontColor(YoColor.TEXT_PRIMARY)
          YoStatusPill({ label: '重叠估计', tone: 'neutral' })
        }
        .width('100%')
      }, (row: WifiChannelOccupancyRow) => `r${row.channel}`)
    }
    .width('100%')
  }

  build() {
    WifiBackShell({
      title: '信道',
      kind: YoNavDestinationKind.OBJECT,
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.body
    })
  }
}
