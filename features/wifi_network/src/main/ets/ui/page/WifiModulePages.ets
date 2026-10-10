import {
  YoActionButton,
  YoActionButtonKind,
  YoColor,
  YoNavDestinationKind,
  YoSegmentButton,
  YoSpace,
  YoStatusPill,
  YoTypeStyle
} from 'youi_kit';
import { WifiFeatureFact } from '../../domain/model/WifiDebugFacts';
import { WifiDebugViewModel, WifiSessionLine, WifiWallLine } from '../viewmodel/WifiDebugViewModel';
import { WifiBackShell } from './WifiOverviewPage';
import { WifiFactText, WifiFieldInput } from './WifiDebugWidgets';

@ComponentV2
export struct WifiPermissionPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  @LocalBuilder
  body() {
    Column({ space: YoSpace.S }) {
      WifiFactText({ text: 'GET_WIFI_INFO、SET_WIFI_INFO、GET_NETWORK_INFO、INTERNET 为系统授权，不弹运行时授权。' })
      WifiFactText({ text: '未声明时显示权限被拒绝与 201。' })
      ForEach(this.vm.features, (fact: WifiFeatureFact) => {
        Text(`${fact.name} ${fact.supported ? '是' : '否'} ${fact.nativeCode}`)
          .fontSize(YoTypeStyle.BODY_M.size)
          .fontColor(YoColor.TEXT_PRIMARY)
          .width('100%')
      }, (fact: WifiFeatureFact) => fact.name)
      YoActionButton({
        label: '重新读取能力',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.refreshFeatures();
        }
      })
    }
    .width('100%')
  }

  build() {
    WifiBackShell({
      title: '权限与能力',
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.body
    })
  }
}

@ComponentV2
export struct WifiWlanPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  @LocalBuilder
  body() {
    Column({ space: YoSpace.S }) {
      ForEach(this.vm.wlanLines, (line: string) => {
        WifiFactText({ text: line })
      }, (line: string, index: number) => `${index}-${line}`)
      WifiFactText({ text: `热点 ${this.vm.hotspotLabel}` })
      YoActionButton({
        label: '刷新状态',
        onTap: () => {
          void this.vm.refreshWlan();
        }
      })
      YoActionButton({
        label: '打开系统 WLAN',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => this.vm.refuseSystemWifiToggle()
      })
      if (this.vm.connectMessage.length > 0) {
        WifiFactText({ text: this.vm.connectMessage })
      }
    }
    .width('100%')
  }

  build() {
    WifiBackShell({
      title: 'WLAN 状态',
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.body
    })
  }
}

@ComponentV2
export struct WifiLinkPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  private ipv4Line(): string {
    const ipv4 = this.vm.ipv4;
    if (ipv4 === undefined) {
      return '';
    }
    return `IPv4 ${ipv4.address} 网关 ${ipv4.gateway} 掩码 ${ipv4.netmask} DNS ${ipv4.primaryDns} ${ipv4.secondDns} DHCP ${ipv4.dhcpServer} 租约 ${ipv4.leaseSeconds}`;
  }

  private ipv6Line(): string {
    const ipv6 = this.vm.ipv6;
    if (ipv6 === undefined) {
      return '';
    }
    return `IPv6 链路 ${ipv6.linkAddress} 全局 ${ipv6.globalAddress} 网关 ${ipv6.gateway} DNS ${ipv6.dns} 随机全局 ${ipv6.randomGlobal}`;
  }

  private linkLine(kind: string): string {
    const link = this.vm.link;
    if (link === undefined || !link.connected) {
      if (kind === 'state') {
        return '未连接';
      }
      return '';
    }
    if (kind === 'ssid') {
      return link.ssid.length > 0 ? link.ssid : '隐藏网络';
    }
    if (kind === 'rssi') {
      return `RSSI ${this.vm.linkRssi} dBm  档位 ${link.signalLevel}`;
    }
    if (kind === 'freq') {
      return `频率 ${link.frequency}`;
    }
    if (kind === 'tx') {
      return `上行 ${link.txLinkSpeedMbps} Mbps`;
    }
    if (kind === 'rx') {
      return `下行 ${link.rxLinkSpeedMbps} Mbps`;
    }
    if (kind === 'instant') {
      return `瞬时 linkSpeed ${link.linkSpeed}`;
    }
    if (kind === 'max') {
      return `协商 上行 ${link.maxTxMbps} Mbps  下行 ${link.maxRxMbps} Mbps`;
    }
    if (kind === 'width') {
      return `带宽 ${link.channelWidthLabel}`;
    }
    if (kind === 'std') {
      return `标准 ${link.wifiStandardLabel}`;
    }
    if (kind === 'conn') {
      return link.connStateLabel;
    }
    if (kind === 'hidden') {
      return `隐藏 ${link.hiddenLabel}`;
    }
    if (kind === 'restricted') {
      return link.restrictedLabel;
    }
    if (kind === 'type') {
      return link.linkTypeLabel.length > 0 ? link.linkTypeLabel : '当前系统无此字段';
    }
    if (kind === 'mac') {
      return link.macAddress.length > 0 ? link.macAddress : '无权限';
    }
    return link.addressKind.length > 0 ? link.addressKind : '随机地址';
  }

  @LocalBuilder
  body() {
    Column({ space: YoSpace.S }) {
      WifiFactText({ text: this.linkLine('state') })
      WifiFactText({ text: this.linkLine('ssid') })
      WifiFactText({ text: this.linkLine('rssi') })
      WifiFactText({ text: this.linkLine('freq') })
      WifiFactText({ text: this.linkLine('tx') })
      WifiFactText({ text: this.linkLine('rx') })
      WifiFactText({ text: this.linkLine('instant') })
      WifiFactText({ text: this.linkLine('max') })
      WifiFactText({ text: this.linkLine('width') })
      WifiFactText({ text: this.linkLine('std') })
      WifiFactText({ text: this.linkLine('conn') })
      WifiFactText({ text: this.linkLine('hidden') })
      WifiFactText({ text: this.linkLine('restricted') })
      WifiFactText({ text: this.linkLine('type') })
      WifiFactText({ text: this.linkLine('mac') })
      WifiFactText({ text: this.linkLine('addr') })
      WifiFactText({ text: `噪声 ${this.vm.gapLabel()}` })
      WifiFactText({ text: `SNR ${this.vm.gapLabel()}` })
      WifiFactText({ text: this.ipv4Line() })
      WifiFactText({ text: this.ipv6Line() })
      YoActionButton({
        label: '刷新链路',
        onTap: () => {
          void this.vm.refreshLink();
        }
      })
    }
    .width('100%')
  }

  build() {
    WifiBackShell({
      title: '链路',
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.body
    })
  }
}

@ComponentV2
export struct WifiConnectPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  @LocalBuilder
  body() {
    Column({ space: YoSpace.S }) {
      WifiFieldInput({
        label: 'SSID',
        text: this.vm.ssidInput,
        onValue: (value: string) => {
          this.vm.ssidInput = value;
        }
      })
      WifiFieldInput({
        label: '密钥',
        text: this.vm.keyInput,
        onValue: (value: string) => {
          this.vm.keyInput = value;
        }
      })
      YoSegmentButton({
        labels: ['PSK', 'OPEN', 'SAE', 'EAP', 'WEP'],
        initialIndex: 0,
        onSelectedIndexChange: (index: number) => {
          this.vm.securityInput = this.securityAt(index);
        }
      })
      YoActionButton({
        label: this.vm.hiddenInput ? '隐藏网络：是' : '隐藏网络：否',
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          this.vm.hiddenInput = !this.vm.hiddenInput;
        }
      })
      WifiFieldInput({
        label: 'EAP 身份',
        text: this.vm.eapIdentity,
        onValue: (value: string) => {
          this.vm.eapIdentity = value;
        }
      })
      WifiFieldInput({
        label: 'EAP 密码',
        text: this.vm.eapPassword,
        onValue: (value: string) => {
          this.vm.eapPassword = value;
        }
      })
      YoActionButton({
        label: this.vm.useUserAction ? '用户确认连接' : '直接连接',
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          this.vm.useUserAction = !this.vm.useUserAction;
        }
      })
      WifiFieldInput({
        label: '候选网络 ID',
        text: this.vm.networkIdInput,
        onValue: (value: string) => {
          this.vm.networkIdInput = value;
        }
      })
      YoActionButton({
        label: '添加并连接',
        onTap: () => {
          void this.vm.submitCandidate();
        }
      })
      YoActionButton({
        label: '移除候选',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.removeListedCandidate();
        }
      })
      YoActionButton({
        label: '断开系统 STA',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => this.vm.refuseStaDisconnect()
      })
      YoActionButton({
        label: '读取已保存密钥',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => this.vm.refuseSavedPsk()
      })
      if (this.vm.connectMessage.length > 0) {
        WifiFactText({ text: `${this.vm.connectMessage} ${this.vm.connectCode}` })
      }
      ForEach(this.vm.candidateNames, (name: string) => {
        WifiFactText({ text: name })
      }, (name: string, index: number) => `${index}-${name}`)
    }
    .width('100%')
  }

  private securityAt(index: number): string {
    if (index === 1) {
      return 'OPEN';
    }
    if (index === 2) {
      return 'SAE';
    }
    if (index === 3) {
      return 'EAP';
    }
    if (index === 4) {
      return 'WEP';
    }
    return 'PSK';
  }

  build() {
    WifiBackShell({
      title: '连接',
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.body
    })
  }
}

@ComponentV2
export struct WifiDefaultNetPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  @LocalBuilder
  body() {
    Column({ space: YoSpace.S }) {
      WifiFactText({ text: this.vm.capabilityLabel })
      ForEach(this.vm.defaultNetLines, (line: string) => {
        WifiFactText({ text: line })
      }, (line: string, index: number) => `${index}-${line}`)
      ForEach(this.vm.netEventLines, (line: string) => {
        WifiFactText({ text: line })
      }, (line: string, index: number) => `e${index}-${line}`)
      YoActionButton({
        label: '读取默认网络',
        onTap: () => {
          void this.vm.refreshDefaultNet();
        }
      })
    }
    .width('100%')
  }

  build() {
    WifiBackShell({
      title: '默认网络',
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.body
    })
  }
}

@ComponentV2
export struct WifiAddressPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  @LocalBuilder
  body() {
    Column({ space: YoSpace.S }) {
      YoActionButton({
        label: '读取连接属性',
        onTap: () => {
          void this.vm.loadProperties();
        }
      })
      ForEach(this.vm.propertyLines, (line: string) => {
        WifiFactText({ text: line })
      }, (line: string, index: number) => `p${index}-${line}`)
      WifiFieldInput({
        label: '主机名',
        text: this.vm.hostInput,
        onValue: (value: string) => {
          this.vm.hostInput = value;
        }
      })
      YoSegmentButton({
        labels: ['系统默认', '只要 IPv4', '只要 IPv6'],
        initialIndex: 0,
        onSelectedIndexChange: (index: number) => {
          this.vm.dnsFamily = index === 1 ? 1 : (index === 2 ? 2 : 0);
        }
      })
      YoActionButton({
        label: '解析',
        onTap: () => {
          void this.vm.resolveHost();
        }
      })
      WifiFieldInput({
        label: '端口',
        text: this.vm.portInput,
        onValue: (value: string) => {
          this.vm.portInput = value;
        }
      })
      YoActionButton({
        label: 'TCP 端口检查',
        isEnabled: !this.vm.portScanning,
        onTap: () => {
          void this.vm.probePort(this.vm.hostInput, this.vm.portInput);
        }
      })
      YoActionButton({
        label: '取消端口检查',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => this.vm.cancelPortScan()
      })
      YoActionButton({
        label: '系统探测',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.runProbe();
        }
      })
      YoActionButton({
        label: '路由跟踪',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.runTrace();
        }
      })
      YoActionButton({
        label: '整机监听表',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => this.vm.refuseSystemPorts()
      })
      ForEach(this.vm.addressLines, (line: string) => {
        WifiFactText({ text: line })
      }, (line: string, index: number) => `a${index}-${line}`)
      ForEach(this.vm.portLines, (line: string) => {
        WifiFactText({ text: line })
      }, (line: string, index: number) => `o${index}-${line}`)
    }
    .width('100%')
  }

  build() {
    WifiBackShell({
      title: '地址与诊断',
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.body
    })
  }
}

@ComponentV2
export struct WifiThroughputPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  @LocalBuilder
  body() {
    Column({ space: YoSpace.S }) {
      WifiFieldInput({
        label: '下载地址',
        text: this.vm.urlInput,
        onValue: (value: string) => {
          this.vm.urlInput = value;
        }
      })
      WifiFactText({ text: `阶段 ${this.vm.speedPhase}` })
      WifiFactText({ text: `下载 ${this.vm.speedMbps}` })
      WifiFactText({ text: `上传 ${this.vm.uploadMbps}` })
      WifiFactText({ text: `系统估计 ${this.vm.bandwidthLabel}` })
      ForEach(this.vm.timingLines, (line: string) => {
        WifiFactText({ text: line })
      }, (line: string, index: number) => `t${index}`)
      YoActionButton({
        label: '开始测速',
        onTap: () => {
          void this.vm.runSpeed(this.vm.urlInput);
        }
      })
      YoActionButton({
        label: '中止',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => this.vm.abortHttp()
      })
      ForEach(this.vm.httpLines, (line: string) => {
        WifiFactText({ text: line })
      }, (line: string, index: number) => `h${index}`)
    }
    .width('100%')
  }

  build() {
    WifiBackShell({
      title: '吞吐',
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.body
    })
  }
}

@ComponentV2
export struct WifiInspectPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  @LocalBuilder
  body() {
    Column({ space: YoSpace.S }) {
      WifiFieldInput({
        label: 'URL',
        text: this.vm.urlInput,
        onValue: (value: string) => {
          this.vm.urlInput = value;
        }
      })
      YoActionButton({
        label: 'HTTP GET',
        onTap: () => {
          void this.vm.runHttp('GET', this.vm.urlInput);
        }
      })
      YoActionButton({
        label: 'HTTP POST',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.runHttp('POST', this.vm.urlInput);
        }
      })
      YoActionButton({
        label: '取消 HTTP',
        kind: YoActionButtonKind.TEXT,
        onTap: () => this.vm.abortHttp()
      })
      YoActionButton({
        label: this.vm.httpBodyOpen ? '收起响应体' : '展开响应体',
        kind: YoActionButtonKind.TEXT,
        onTap: () => this.vm.toggleHttpBody()
      })
      if (this.vm.httpBodyOpen) {
        WifiFactText({ text: this.vm.httpBody.length > 0 ? this.vm.httpBody : '系统未返回' })
      }
      WifiFactText({ text: this.vm.proxyLine })
      YoActionButton({
        label: '读取代理',
        kind: YoActionButtonKind.TEXT,
        onTap: (): void => {
          void this.vm.loadProxy();
        }
      })
      WifiFactText({ text: this.vm.trafficLine })
      YoActionButton({
        label: '本应用近 1 天 Wi-Fi 流量',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.readTraffic(false);
        }
      })
      YoActionButton({
        label: '查询早于 31 天',
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          void this.vm.readTraffic(true);
        }
      })
      YoActionButton({
        label: '其他应用流量',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => this.vm.refuseOtherUidTraffic()
      })
      WifiFieldInput({
        label: '主机',
        text: this.vm.hostInput,
        onValue: (value: string) => {
          this.vm.hostInput = value;
        }
      })
      WifiFieldInput({
        label: '端口',
        text: this.vm.portInput,
        onValue: (value: string) => {
          this.vm.portInput = value;
        }
      })
      WifiFieldInput({
        label: '文本',
        text: this.vm.payloadInput,
        onValue: (value: string) => {
          this.vm.payloadInput = value;
        }
      })
      YoActionButton({
        label: 'TCP 连接',
        onTap: () => {
          void this.vm.connectInspectTcp();
        }
      })
      YoActionButton({
        label: 'TCP 发送',
        isEnabled: this.vm.tcpSendEnabled,
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.sendInspectTcp();
        }
      })
      YoActionButton({
        label: 'TCP 断开',
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          void this.vm.disconnectInspectTcp();
        }
      })
      YoActionButton({
        label: '发送数据报',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.sendInspectUdp();
        }
      })
      YoActionButton({
        label: '监听',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.startInspectTcpServer();
        }
      })
      YoActionButton({
        label: '停止监听',
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          void this.vm.stopInspectTcpServer();
        }
      })
      if (this.vm.tlsMark === 'TLS') {
        YoStatusPill({ label: 'TLS', tone: 'success' })
      } else if (this.vm.tlsMark === 'failed') {
        WifiFactText({ text: '未标为已加密成功' })
      } else {
        WifiFactText({ text: '未建立' })
      }
      YoActionButton({
        label: '建立 TLS',
        onTap: () => {
          void this.vm.connectInspectTls();
        }
      })
      YoActionButton({
        label: 'WebSocket 连接',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.connectInspectWs();
        }
      })
      YoActionButton({
        label: 'WebSocket 发送',
        isEnabled: this.vm.wsSendEnabled,
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.sendInspectWs();
        }
      })
      YoActionButton({
        label: 'WebSocket 断开',
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          void this.vm.disconnectInspectWs();
        }
      })
      WifiFactText({ text: this.vm.wsServerLine })
      YoActionButton({
        label: '启动服务',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.startInspectWsServer();
        }
      })
      YoActionButton({
        label: '停止服务',
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          void this.vm.stopInspectWsServer();
        }
      })
      YoActionButton({
        label: '加入',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.joinMulticast();
        }
      })
      ForEach(this.vm.inspectLines, (line: string) => {
        WifiFactText({ text: line })
      }, (line: string, index: number) => `n${index}-${line}`)
      ForEach(this.vm.httpLines, (line: string) => {
        WifiFactText({ text: line })
      }, (line: string, index: number) => `i${index}`)
      ForEach(this.vm.timingLines, (line: string) => {
        WifiFactText({ text: line })
      }, (line: string, index: number) => `m${index}`)
    }
    .width('100%')
  }

  build() {
    WifiBackShell({
      title: '连接检查',
      kind: YoNavDestinationKind.TERMINAL,
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.body
    })
  }
}

@ComponentV2
export struct WifiLanPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  @LocalBuilder
  body() {
    Column({ space: YoSpace.S }) {
      WifiFieldInput({
        label: '服务类型',
        text: this.vm.hostInput,
        onValue: (value: string) => {
          this.vm.hostInput = value;
        }
      })
      WifiFieldInput({
        label: '服务名',
        text: this.vm.ssidInput,
        onValue: (value: string) => {
          this.vm.ssidInput = value;
        }
      })
      WifiFieldInput({
        label: '端口',
        text: this.vm.portInput,
        onValue: (value: string) => {
          this.vm.portInput = value;
        }
      })
      if (this.vm.lanError.length > 0) {
        WifiFactText({ text: this.vm.lanError })
      }
      ForEach(this.vm.lanLines, (line: string) => {
        WifiFactText({ text: line })
      }, (line: string, index: number) => `l${index}-${line}`)
      YoActionButton({
        label: '开始发现',
        onTap: () => {
          void this.vm.startLan(this.vm.hostInput);
        }
      })
      YoActionButton({
        label: '停止发现',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.stopLan();
        }
      })
      YoActionButton({
        label: '发布本地服务',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => {
          void this.vm.publishLan(this.vm.ssidInput, this.vm.portInput);
        }
      })
      YoActionButton({
        label: '移除本地服务',
        kind: YoActionButtonKind.TEXT,
        onTap: () => {
          void this.vm.removeLan(this.vm.ssidInput);
        }
      })
    }
    .width('100%')
  }

  build() {
    WifiBackShell({
      title: '局域网',
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.body
    })
  }
}

@ComponentV2
export struct WifiWallPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  @LocalBuilder
  body() {
    Column({ space: YoSpace.M }) {
      if (this.vm.emulatorNotPassed) {
        YoStatusPill({ label: '未通过', tone: 'warning' })
      }
      ForEach(this.vm.walls, (wall: WifiWallLine) => {
        Column({ space: YoSpace.XS }) {
          Text(wall.title)
            .fontSize(YoTypeStyle.SUBTITLE_S.size)
            .fontColor(YoColor.TEXT_PRIMARY)
          YoStatusPill({
            label: wall.pill,
            tone: wall.tone === 'warning' ? 'warning' : 'neutral'
          })
          Text(wall.detail)
            .fontSize(YoTypeStyle.BODY_S.size)
            .fontColor(YoColor.TEXT_SECONDARY)
        }
        .width('100%')
      }, (wall: WifiWallLine) => wall.id)
      YoActionButton({
        label: '打开系统设置',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => this.vm.openSettings()
      })
    }
    .width('100%')
  }

  build() {
    WifiBackShell({
      title: '权限墙',
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.body
    })
  }
}

@ComponentV2
export struct WifiLogPage {
  @Param vm: WifiDebugViewModel = new WifiDebugViewModel();
  @Event onBack: () => void = () => {
  };
  @Event onOpenLog: () => void = () => {
  };

  @LocalBuilder
  body() {
    Column({ space: YoSpace.S }) {
      YoActionButton({
        label: '清空',
        kind: YoActionButtonKind.SECONDARY,
        onTap: () => this.vm.clearLog()
      })
      ForEach(this.vm.logs, (line: WifiSessionLine) => {
        Text(`${line.timeText}  ${line.action}  ${line.result}  ${line.nativeCode}`)
          .fontSize(YoTypeStyle.BODY_S.size)
          .fontColor(YoColor.TEXT_PRIMARY)
          .width('100%')
      }, (line: WifiSessionLine, index: number) => `${index}-${line.timeText}-${line.action}`)
    }
    .width('100%')
  }

  build() {
    WifiBackShell({
      title: '会话日志',
      vm: this.vm,
      onBack: () => this.onBack(),
      onOpenLog: () => this.onOpenLog(),
      content: this.body
    })
  }
}
