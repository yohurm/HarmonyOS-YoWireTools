import { ResultError, TimeUtil } from 'common_core';
import {
  AbilityContextRegistry,
  AppLifecycleState,
  LifecycleCoordinator,
  WifiSettingsNavigator
} from 'common_platform';
import { ExportFileWriter } from 'common_storage';
import { YoPageState, YoToast } from 'youi_kit';
import { WifiNetworkRepository } from '../../data/repository/WifiNetworkRepository';
import { WifiNetworkConstants } from '../../constants/WifiNetworkConstants';
import { WifiAccessPointSnapshot } from '../../domain/model/WifiAccessPointSnapshot';
import { WifiCandidateDraft, WifiFeatureFact, WifiIpv4Facts, WifiIpv6Facts } from '../../domain/model/WifiDebugFacts';
import { WifiLinkedInfoSnapshot } from '../../domain/model/WifiLinkedInfoSnapshot';
import { NetworkStateSnapshot } from '../../domain/model/NetworkStateSnapshot';
import { WifiChannelOccupancyRow } from '../../domain/model/WifiDebugFacts';
import { WifiDebugUseCases } from '../../domain/usecase/WifiDebugUseCases';
import { ExecuteHttpRequestUseCase } from '../../domain/usecase/WifiNetworkUseCases';
import { StartMdnsDiscoveryUseCase, StopMdnsDiscoveryUseCase } from '../../domain/usecase/WifiNetworkSessionUseCases';
import { StartPortScanUseCase } from '../../domain/usecase/WifiNetworkUseCases';
import { HttpRequestDraft } from '../../domain/model/HttpModels';
import { PortProbeResult, PortScanConfig } from '../../domain/model/LanDiscoveryModels';
import { WifiChannelOccupancy } from '../../domain/service/WifiChannelOccupancy';
import { WifiCandidateRules } from '../../domain/service/WifiCandidateRules';
import { WifiDistanceEstimator } from '../../domain/service/WifiDistanceEstimator';
import { WifiFieldLabels } from '../../domain/service/WifiFieldLabels';
import { WifiScanListPolicy } from '../../domain/service/WifiScanListPolicy';
import { IdGenerator } from 'common_core';

export class WifiSessionLine {
  readonly timeText: string;
  readonly action: string;
  readonly result: string;
  readonly nativeCode: string;

  constructor(timeText: string, action: string, result: string, nativeCode: string) {
    this.timeText = timeText;
    this.action = action;
    this.result = result;
    this.nativeCode = nativeCode;
  }
}

export class WifiWallLine {
  readonly id: string;
  readonly title: string;
  readonly detail: string;
  readonly pill: string;
  readonly tone: string;

  constructor(id: string, title: string, detail: string, pill: string, tone: string) {
    this.id = id;
    this.title = title;
    this.detail = detail;
    this.pill = pill;
    this.tone = tone;
  }
}

@ObservedV2
export class WifiDebugViewModel {
  @Trace pageState: YoPageState = YoPageState.LOADING;
  @Trace loadingText: string = '正在核对权限声明';
  @Trace errorUser: string = '';
  @Trace errorCause: string = '';
  @Trace errorNext: string = '';
  @Trace errorCode: string = '';
  @Trace wifiActiveLabel: string = '未读取';
  @Trace netIdLabel: string = '未读取';
  @Trace cachePill: string = '未读取';
  @Trace features: WifiFeatureFact[] = [];
  @Trace featureState: YoPageState = YoPageState.EMPTY;
  @Trace wlanLines: string[] = [];
  @Trace hotspotLabel: string = '未读取';
  @Trace scanRows: WifiAccessPointSnapshot[] = [];
  @Trace scanStatus: string = '';
  @Trace cacheTimeText: string = '';
  @Trace cooldownText: string = '';
  @Trace scanLoading: boolean = false;
  @Trace scanPaused: boolean = false;
  @Trace scanFailure: string = '';
  @Trace scanFailureCode: string = '';
  @Trace filterSsid: string = '';
  @Trace filterSignal: number = -1;
  @Trace filterSecurity: string = '';
  @Trace filterBand: number = 0;
  @Trace groupBySsid: boolean = false;
  @Trace selectedApId: string = '';
  @Trace showDistance: boolean = false;
  @Trace emulatorNotPassed: boolean = true;
  @Trace link: WifiLinkedInfoSnapshot | undefined = undefined;
  @Trace ipv4: WifiIpv4Facts | undefined = undefined;
  @Trace ipv6: WifiIpv6Facts | undefined = undefined;
  @Trace linkRssi: number = 0;
  @Trace connectMessage: string = '';
  @Trace connectCode: string = '';
  @Trace candidateNames: string[] = [];
  @Trace ssidInput: string = '';
  @Trace keyInput: string = '';
  @Trace securityInput: string = 'PSK';
  @Trace hiddenInput: boolean = false;
  @Trace eapIdentity: string = '';
  @Trace eapPassword: string = '';
  @Trace useUserAction: boolean = false;
  @Trace networkIdInput: string = '';
  @Trace defaultNetLines: string[] = [];
  @Trace addressLines: string[] = [];
  @Trace portLines: string[] = [];
  @Trace portScanning: boolean = false;
  @Trace httpLines: string[] = [];
  @Trace speedPhase: string = '未开始';
  @Trace speedMbps: string = '';
  @Trace lanLines: string[] = [];
  @Trace lanError: string = '';
  @Trace inspectLines: string[] = [];
  @Trace logs: WifiSessionLine[] = [];
  @Trace exportText: string = '';
  @Trace toastText: string = '';
  @Trace walls: WifiWallLine[] = WifiDebugViewModel.buildWalls(true);
  @Trace hostInput: string = '';
  @Trace portInput: string = '80';
  @Trace urlInput: string = '';
  @Trace dnsFamily: number = 0;
  @Trace propertyLines: string[] = [];
  @Trace proxyLine: string = '未读取';
  @Trace bandwidthLabel: string = '未读取';
  @Trace timingLines: string[] = [];
  @Trace uploadMbps: string = '';
  @Trace trafficLine: string = '';
  @Trace netEventLines: string[] = [];
  @Trace capabilityLabel: string = '未读取';
  @Trace openGroups: string[] = [];
  @Trace httpCancelled: boolean = false;
  @Trace selectedTitle: string = '';

  private readonly repository: WifiNetworkRepository = WifiNetworkRepository.getInstance();
  private readonly debugCases: WifiDebugUseCases = new WifiDebugUseCases(this.repository);
  private readonly httpCase: ExecuteHttpRequestUseCase = new ExecuteHttpRequestUseCase();
  private readonly portCase: StartPortScanUseCase = new StartPortScanUseCase();
  private readonly mdnsCase: StartMdnsDiscoveryUseCase = new StartMdnsDiscoveryUseCase();
  private readonly stopMdnsCase: StopMdnsDiscoveryUseCase = new StopMdnsDiscoveryUseCase();
  private subscribed: boolean = false;
  private peersMacGranted: boolean = false;
  private cacheReadAtMs: number = 0;
  private backgroundBlocked: boolean = false;

  async enter(): Promise<void> {
    this.pageState = YoPageState.LOADING;
    this.loadingText = '正在核对权限声明';
    this.emulatorNotPassed = this.repository.isEmulatorRuntime();
    this.walls = WifiDebugViewModel.buildWalls(this.emulatorNotPassed);
    const opened = await this.debugCases.openPage();
    if (!opened.success) {
      this.failPage(opened.error !== undefined ? opened.error.message : '权限被拒绝', '声明缺失', '打开对应子页', '201');
      this.appendLog('openWifiDebug', 'declarationMismatch', '201');
      return;
    }
    this.appendLog('openWifiDebug', 'noRuntimeDialog', '');
    this.pageState = YoPageState.CONTENT;
    this.wifiActiveLabel = '未读取';
    this.subscribe();
    this.repository.startNetObservation((snapshot: NetworkStateSnapshot) => {
      this.netIdLabel = snapshot.hasDefaultNet ? snapshot.netType : '无';
    }, (name: string, detail: string) => {
      this.noteNetEvent(name, detail);
    });
    await this.refreshWlan();
    await this.refreshFeatures();
    await this.refreshLink();
  }

  leave(): void {
    this.unsubscribe();
    this.repository.stopNetObservation();
    void this.stopMdnsCase.execute();
  }

  subscribe(): void {
    if (this.subscribed) {
      return;
    }
    this.subscribed = true;
    this.repository.onWifiPowerState((state: number) => {
      const label = WifiFieldLabels.wifiPowerState(state);
      this.appendLog('wifiStateChange', label, '');
      this.wifiActiveLabel = state === 1 ? '已激活' : '未激活';
      if (state === 0 || state === 3) {
        this.link = undefined;
        this.wlanLines = ['未激活', 'STA 未打开'];
      }
    });
    this.repository.onWifiConnectionState((state: number) => {
      const label = WifiFieldLabels.connState(state);
      this.appendLog('wifiConnectionChange', label, '');
      if (label === 'DISCONNECTED' || label === 'UNKNOWN') {
        this.clearSsid();
      }
    });
    this.repository.onWifiRssi((rssi: number) => {
      this.linkRssi = rssi;
      this.appendLog('wifiRssiChange', `${rssi} dBm`, '');
    });
  }

  unsubscribe(): void {
    if (!this.subscribed) {
      return;
    }
    this.repository.offWifiPowerState();
    this.repository.offWifiConnectionState();
    this.repository.offWifiRssi();
    this.subscribed = false;
  }

  async refreshWlan(): Promise<void> {
    const active = await this.repository.getWifiState();
    if (!active.success) {
      this.applyNative(active.error !== undefined ? active.error : undefined, 'readWifiState');
      return;
    }
    this.wifiActiveLabel = active.value === true ? '已激活' : '未激活';
    const connected = await this.repository.isStaConnected();
    const hotspot = await this.repository.isHotspotActive();
    const lines: string[] = [];
    lines.push(active.value === true ? '已激活' : '未激活');
    if (connected.success) {
      lines.push(connected.value === true ? '已连接' : '未连接');
      if (connected.value !== true) {
        this.clearSsid();
      }
    } else {
      this.applyNative(connected.error, 'isConnected');
    }
    if (hotspot.success) {
      this.hotspotLabel = hotspot.value === true ? '是' : '否';
    } else if (hotspot.error !== undefined && hotspot.error.message === '当前系统版本没有该接口') {
      this.hotspotLabel = '当前系统版本没有该接口';
    } else {
      this.hotspotLabel = hotspot.error !== undefined ? hotspot.error.message : '未读取';
    }
    lines.push(`热点 ${this.hotspotLabel}`);
    lines.push('没有打开热点的动作');
    this.wlanLines = lines;
    this.appendLog('readWifiActive', active.value === true ? 'active' : 'inactive', '');
  }

  refuseSystemWifiToggle(): void {
    this.appendLog('toggleWifi', 'refused', '');
    this.errorUser = '需要系统应用或企业权限';
    this.connectMessage = '需要系统应用或企业权限。WLAN 开关状态保持不变。';
  }

  async refreshFeatures(): Promise<void> {
    this.featureState = YoPageState.LOADING;
    const result = await this.repository.readFeatureSupport();
    if (!result.success || result.value === undefined) {
      this.featureState = YoPageState.ERROR;
      this.applyNative(result.error, 'featureProbe');
      return;
    }
    this.features = result.value;
    this.featureState = YoPageState.CONTENT;
    this.appendLog('featureProbe', 'listed', '');
  }

  async scan(): Promise<void> {
    if (this.scanPaused) {
      this.scanFailure = '已暂停';
      return;
    }
    const foreground = LifecycleCoordinator.getInstance().state === AppLifecycleState.FOREGROUND;
    this.scanLoading = true;
    this.scanStatus = '正在扫描';
    const result = await this.debugCases.startScan(this.peersMacGranted, foreground, this.scanPaused);
    this.scanLoading = false;
    this.refreshCooldown();
    if (!result.success || result.value === undefined) {
      const message = result.error !== undefined ? result.error.message : '扫描失败';
      const code = result.error !== undefined ? result.error.nativeCode : '';
      this.scanFailure = WifiFieldLabels.errorSentence(code, message);
      this.scanFailureCode = code;
      if (message === '该次未执行') {
        this.backgroundBlocked = true;
        this.scanStatus = '该次未执行';
      } else if (message === '剩余冷却') {
        this.scanStatus = `剩余冷却 ${this.formatDuration(this.repository.getScanCooldownRemainingMs())}`;
      } else {
        this.scanStatus = this.scanFailure;
      }
      this.appendLog('startScan', this.scanFailure, code);
      return;
    }
    this.scanRows = result.value.rows;
    this.cacheReadAtMs = result.value.readAtMs;
    this.scanFailure = '';
    this.scanFailureCode = '';
    this.backgroundBlocked = false;
    this.scanStatus = '缓存';
    this.cacheTimeText = this.formatClock(result.value.readAtMs);
    this.cachePill = `缓存 ${this.cacheAgeSeconds()} 秒前`;
    this.appendLog('startScan', 'success', '');
    if (this.scanRows.length === 0) {
      this.pageState = YoPageState.CONTENT;
    }
  }

  async refreshCacheOnly(): Promise<void> {
    const result = await this.debugCases.refreshCache(this.peersMacGranted);
    if (!result.success || result.value === undefined) {
      this.applyNative(result.error, 'refreshCache');
      return;
    }
    this.scanRows = result.value.rows;
    this.cacheReadAtMs = result.value.readAtMs;
    this.scanStatus = '缓存';
    this.cacheTimeText = this.formatClock(result.value.readAtMs);
    this.cachePill = `缓存 ${this.cacheAgeSeconds()} 秒前`;
    this.appendLog('refreshCache', 'cache', '');
  }

  pauseScan(): void {
    this.scanPaused = true;
    this.appendLog('pauseScan', 'paused', '');
  }

  resumeScan(): void {
    this.scanPaused = false;
  }

  setFilterSsid(value: string): void {
    this.filterSsid = value;
    this.appendLog('filterSsid', 'applied', '');
  }

  setFilterSignal(level: number): void {
    this.filterSignal = level;
    this.appendLog('filterSignal', 'applied', '');
  }

  setFilterSecurity(value: string): void {
    this.filterSecurity = value;
    this.appendLog('filterSecurity', 'applied', '');
  }

  setFilterBand(band: number): void {
    this.filterBand = band;
    this.appendLog('filterBand', 'applied', '');
  }

  toggleGroup(): void {
    this.groupBySsid = !this.groupBySsid;
    this.appendLog('groupSsid', this.groupBySsid ? 'expanded' : 'flat', '');
  }

  visibleRows(): WifiAccessPointSnapshot[] {
    const filtered = WifiScanListPolicy.filter(
      this.scanRows,
      this.filterSsid,
      this.filterSignal,
      this.filterSecurity,
      this.filterBand
    );
    return WifiScanListPolicy.sortByRssiDesc(filtered);
  }

  channelRows(): WifiChannelOccupancyRow[] {
    const connected = this.link !== undefined ? this.link.bssid : '';
    return WifiChannelOccupancy.rate(this.scanRows, connected);
  }

  recommendedChannels(): WifiChannelOccupancyRow[] {
    return WifiChannelOccupancy.recommend(this.channelRows());
  }

  async exportScan(): Promise<void> {
    const lines: string[] = [];
    const rows = this.visibleRows();
    for (let i = 0; i < rows.length; i++) {
      const row = rows[i];
      lines.push(`${row.ssid}\t${row.frequency}\t${row.rssi}\t${row.securityType}\t${row.capturedAtMs}`);
    }
    this.exportText = lines.join('\n');
    const context = AbilityContextRegistry.getInstance().get();
    if (context !== undefined) {
      const writer = new ExportFileWriter(context);
      await writer.writeText('wifi-scan.txt', this.exportText);
    }
    this.toastText = '已导出';
    YoToast.show('已导出');
    this.appendLog('exportScan', 'written', '');
  }

  async refreshLink(): Promise<void> {
    const linked = await this.repository.getLinkedInfo(this.peersMacGranted);
    if (!linked.success || linked.value === undefined) {
      const code = linked.error !== undefined ? linked.error.nativeCode : '';
      const message = linked.error !== undefined ? linked.error.message : '读取失败';
      this.wlanLines = [`${WifiFieldLabels.errorSentence(code, message)} ${code}`];
      if (code === '2501001') {
        this.link = undefined;
      }
      this.appendLog('getLinkedInfo', WifiFieldLabels.errorSentence(code, message), code);
      return;
    }
    if (!linked.value.connected) {
      this.link = new WifiLinkedInfoSnapshot(
        linked.value.capturedAtMs,
        linked.value.wifiActive,
        false,
        '',
        '',
        false,
        linked.value.rssi,
        linked.value.signalLevel,
        linked.value.band,
        linked.value.frequency,
        linked.value.linkSpeed
      );
    } else {
      this.link = linked.value;
      this.linkRssi = linked.value.rssi;
    }
    const ipv4 = await this.repository.readIpv4();
    if (ipv4.success) {
      this.ipv4 = ipv4.value;
    }
    const ipv6 = await this.repository.readIpv6();
    if (ipv6.success) {
      this.ipv6 = ipv6.value;
    }
    this.appendLog('readLink', linked.value.connStateLabel, '');
  }

  distanceText(): string {
    if (!this.showDistance || this.link === undefined) {
      return '';
    }
    const meters = WifiDistanceEstimator.meters(this.linkRssi, this.link.frequency);
    return `${meters} 米 · 按自由空间路径损耗估算`;
  }

  async submitCandidate(): Promise<void> {
    const networkId = this.networkIdInput.length === 0 ? -1 : Number(this.networkIdInput);
    const draft = new WifiCandidateDraft(
      this.ssidInput,
      this.keyInput,
      this.securityInput,
      this.hiddenInput,
      this.eapIdentity,
      this.eapPassword,
      this.useUserAction,
      isNaN(networkId) ? -1 : networkId
    );
    const masked = WifiCandidateRules.maskSecret(draft.key);
    const result = await this.debugCases.connectCandidate(draft);
    if (!result.success) {
      const code = result.error !== undefined ? result.error.nativeCode : '';
      this.connectMessage = result.error !== undefined ? result.error.message : '连接失败';
      this.connectCode = code;
      this.appendLog('connectCandidate', this.connectMessage, code);
      return;
    }
    this.connectMessage = this.useUserAction ? '已发起用户确认连接' : '已发起连接';
    this.connectCode = '';
    this.appendLog('connectCandidate', this.connectMessage, '');
    this.appendLog('secret', masked, '');
    const names = await this.repository.listCandidateSsids();
    if (names.success && names.value !== undefined) {
      this.candidateNames = names.value;
    }
  }

  async removeListedCandidate(): Promise<void> {
    const networkId = Number(this.networkIdInput);
    if (isNaN(networkId)) {
      this.connectMessage = '参数无效';
      this.connectCode = '2501007';
      return;
    }
    const removed = await this.debugCases.removeCandidate(networkId);
    this.connectMessage = removed.success ? '已移除' : (removed.error !== undefined ? removed.error.message : '移除失败');
    const names = await this.repository.listCandidateSsids();
    if (names.success && names.value !== undefined) {
      this.candidateNames = names.value;
    }
    this.appendLog('removeCandidate', this.connectMessage, '');
  }

  async refreshDefaultNet(): Promise<void> {
    const state = await this.repository.getWifiState();
    const net = await this.repository.readDefaultNet();
    const lines: string[] = [];
    if (!net.success || net.value === undefined) {
      const message = net.error !== undefined ? net.error.message : 'netUnavailable';
      lines.push(message);
      this.netIdLabel = '无';
      this.appendLog('readDefaultNet', message, net.error !== undefined ? net.error.nativeCode : '');
    } else if (net.value.hasDefaultNet) {
      lines.push(`netId ${net.value.netType}`);
      this.netIdLabel = net.value.netType;
      this.appendLog('readDefaultNet', 'netAvailable', '');
    } else {
      lines.push('netUnavailable');
      this.netIdLabel = '无';
      this.appendLog('readDefaultNet', 'netUnavailable', '');
    }
    const online = await this.repository.readOnlineStatus();
    if (online.success && online.value !== undefined) {
      this.capabilityLabel = online.value;
      lines.push(online.value);
      this.bandwidthLabel = this.bandwidthFromStatus(online.value);
    } else if (online.error !== undefined) {
      this.capabilityLabel = online.error.message;
      lines.push(online.error.message);
    }
    lines.push(state.success && state.value === true ? 'WLAN 状态已读' : 'WLAN 未确认');
    this.defaultNetLines = lines;
  }

  async probePort(host: string, portText: string): Promise<void> {
    const port = Number(portText);
    if (host.length === 0 || isNaN(port)) {
      this.addressLines = ['失败可见，不发起后续端口扫描'];
      this.appendLog('dns', 'invalidHost', '');
      return;
    }
    this.portScanning = true;
    const config = new PortScanConfig(host, port, port, 'tcp', 3000, 1);
    const result = await this.portCase.execute(config, (probe: PortProbeResult) => {
      if (!this.portScanning) {
        return;
      }
      const line = `${probe.host}:${probe.port} ${probe.state} ${probe.latencyMs}ms`;
      const next: string[] = [];
      for (let i = 0; i < this.portLines.length; i++) {
        next.push(this.portLines[i]);
      }
      next.push(line);
      this.portLines = next;
      this.portScanning = false;
    });
    if (!result.success) {
      this.portScanning = false;
      this.portLines = [result.error !== undefined ? result.error.message : '端口检查失败'];
      return;
    }
    this.appendLog('tcpProbe', 'started', '');
  }

  cancelPortScan(): void {
    this.repository.cancelPortScan();
    this.portScanning = false;
    this.appendLog('portScan', 'cancelled', '');
  }

  refuseTrace(): void {
    this.addressLines = ['失败码 201。未授予 ACCESS_NET_TRACE_INFO，不显示跳数表。'];
    this.appendLog('traceRoute', 'denied', '201');
  }

  refuseSystemPorts(): void {
    this.addressLines = ['没有 GET_IP_MAC_INFO，拒绝读取整机监听表与邻居 MAC。'];
    this.appendLog('readSystemPorts', 'denied', '201');
  }

  async runHttp(method: string, url: string): Promise<void> {
    if (url.indexOf('http://') === 0) {
      this.httpLines = ['明文 HTTP 若被网络安全配置禁止，失败说明明文被拒绝。'];
    }
    this.httpCancelled = false;
    this.speedPhase = '请求中';
    const draft = new HttpRequestDraft(IdGenerator.next('http'), method, url);
    const result = await this.httpCase.execute(draft);
    if (this.httpCancelled) {
      this.speedPhase = '中止';
      this.speedMbps = '';
      this.httpLines = ['已取消'];
      return;
    }
    if (!result.success || result.value === undefined) {
      const message = result.error !== undefined ? result.error.message : '失败';
      this.speedPhase = message === '已取消' ? '中止' : '未开始';
      this.httpLines = [message.indexOf('cleartext') >= 0 || message.indexOf('明文') >= 0 ? '明文被拒绝' : message];
      this.appendLog('httpExchange', message === '已取消' ? 'cancelled' : 'failed', result.error !== undefined ? result.error.nativeCode : '');
      return;
    }
    const record = result.value;
    this.speedPhase = '完成';
    this.timingLines = [
      `DNS ${record.dnsMs} 毫秒`,
      `TCP ${record.tcpMs} 毫秒`,
      `TLS ${record.tlsMs} 毫秒`,
      `首字节 ${record.firstByteMs} 毫秒`,
      `总完成 ${record.totalFinishMs} 毫秒`
    ];
    this.httpLines = [
      `${method} ${url}`,
      `状态码 ${record.responseCode}`,
      `耗时 ${record.latencyMs} 毫秒`,
      record.bodyText
    ];
    this.appendLog('httpExchange', `${record.responseCode}`, '');
  }

  async runSpeed(url: string): Promise<void> {
    this.httpCancelled = false;
    this.speedMbps = '';
    this.uploadMbps = '';
    this.speedPhase = '下载';
    const down = await this.httpCase.execute(new HttpRequestDraft(IdGenerator.next('http'), 'GET', url));
    if (this.httpCancelled || (down.error !== undefined && down.error.message === '已取消')) {
      this.speedPhase = '中止';
      this.speedMbps = '';
      this.uploadMbps = '';
      this.appendLog('speedTest', 'aborted', '');
      return;
    }
    if (!down.success || down.value === undefined) {
      const message = down.error !== undefined ? down.error.message : '失败';
      this.speedPhase = '未开始';
      this.httpLines = [message.indexOf('cleartext') >= 0 || message.indexOf('明文') >= 0 ? '明文被拒绝' : message];
      this.appendLog('speedTest', 'failed', '');
      return;
    }
    this.speedMbps = this.mbps(down.value.bodySize, down.value.latencyMs);
    this.timingLines = [
      `DNS ${down.value.dnsMs} 毫秒`,
      `TCP ${down.value.tcpMs} 毫秒`,
      `TLS ${down.value.tlsMs} 毫秒`,
      `首字节 ${down.value.firstByteMs} 毫秒`,
      `总完成 ${down.value.totalFinishMs} 毫秒`
    ];
    this.speedPhase = '上传';
    const up = await this.httpCase.execute(new HttpRequestDraft(IdGenerator.next('http'), 'POST', url, [], [], 'speed'));
    if (this.httpCancelled || (up.error !== undefined && up.error.message === '已取消')) {
      this.speedPhase = '中止';
      this.uploadMbps = '';
      this.appendLog('speedTest', 'aborted', '');
      return;
    }
    if (!up.success || up.value === undefined) {
      this.speedPhase = '未开始';
      this.httpLines = [up.error !== undefined ? up.error.message : '上传失败'];
      this.appendLog('speedTest', 'uploadFailed', '');
      return;
    }
    this.uploadMbps = this.mbps(up.value.bodySize, up.value.latencyMs);
    this.speedPhase = '完成';
    this.appendLog('speedTest', 'done', '');
  }

  abortHttp(): void {
    this.httpCancelled = true;
    this.repository.abortHttp();
    this.speedPhase = '中止';
    this.speedMbps = '';
    this.uploadMbps = '';
    this.appendLog('speedTest', 'aborted', '');
  }

  async startLan(serviceType: string): Promise<void> {
    const connected = await this.repository.isStaConnected();
    if (!connected.success || connected.value !== true) {
      this.lanError = '需要 Wi-Fi';
      this.lanLines = [];
      this.appendLog('mdnsDiscover', 'wifiRequired', '');
      return;
    }
    const started = await this.mdnsCase.execute(serviceType);
    if (!started.success) {
      this.lanError = started.error !== undefined ? started.error.message : '发现失败';
      this.appendLog('mdnsDiscover', this.lanError, '');
      return;
    }
    this.lanError = '';
    const services = this.mdnsCase.getDataSource().getServices();
    const lines: string[] = [];
    for (let i = 0; i < services.length; i++) {
      lines.push(`${services[i].name} ${services[i].type} ${services[i].port}`);
    }
    this.lanLines = lines;
    this.appendLog('mdnsDiscover', 'found', '');
  }

  async stopLan(): Promise<void> {
    await this.stopMdnsCase.execute();
    this.appendLog('mdnsStop', 'stopped', '');
  }

  async publishLan(name: string, portText: string): Promise<void> {
    const port = Number(portText);
    const published = await this.mdnsCase.publish(name, '_http._tcp', isNaN(port) ? 80 : port);
    this.lanError = published.success ? '' : (published.error !== undefined ? published.error.message : '发布失败');
    this.appendLog('mdnsPublish', published.success ? 'published' : this.lanError, '');
  }

  openSettings(): void {
    const context = AbilityContextRegistry.getInstance().get();
    if (context !== undefined) {
      void WifiSettingsNavigator.openWifiSettings(context);
    }
    this.appendLog('openSettings', 'left', '');
  }

  appendLog(action: string, result: string, nativeCode: string): void {
    const line = new WifiSessionLine(this.formatClock(TimeUtil.nowMs()), action, result, nativeCode);
    const next: WifiSessionLine[] = [];
    for (let i = 0; i < this.logs.length; i++) {
      next.push(this.logs[i]);
    }
    next.push(line);
    this.logs = next;
  }

  clearLog(): void {
    this.logs = [];
    this.appendLog('clearLog', 'emptyThenWritable', '');
  }

  scanDisabledReason(): string {
    if (this.scanPaused) {
      return '已暂停';
    }
    if (this.repository.foregroundSlotsLeft() === 0) {
      return `剩余冷却 ${this.formatDuration(this.repository.getScanCooldownRemainingMs())}`;
    }
    if (this.wifiActiveLabel === '未激活') {
      return '先打开 WLAN';
    }
    return '';
  }

  refreshCooldown(): void {
    const left = this.repository.foregroundSlotsLeft();
    if (left === 0) {
      this.cooldownText = `冷却中 ${this.formatDuration(this.repository.getScanCooldownRemainingMs())}`;
    } else {
      this.cooldownText = `2 分钟内还可扫描 ${left} 次`;
    }
  }

  private clearSsid(): void {
    if (this.link === undefined) {
      return;
    }
    this.link = new WifiLinkedInfoSnapshot(
      this.link.capturedAtMs,
      this.link.wifiActive,
      false
    );
  }

  private cacheAgeSeconds(): number {
    if (this.cacheReadAtMs <= 0) {
      return 0;
    }
    return Math.max(0, Math.floor((Date.now() - this.cacheReadAtMs) / 1000));
  }

  private formatClock(ms: number): string {
    const date = new Date(ms);
    const hh = `${date.getHours()}`.padStart(2, '0');
    const mm = `${date.getMinutes()}`.padStart(2, '0');
    const ss = `${date.getSeconds()}`.padStart(2, '0');
    return `${hh}:${mm}:${ss}`;
  }

  private formatDuration(ms: number): string {
    const total = Math.ceil(ms / 1000);
    const mm = `${Math.floor(total / 60)}`.padStart(2, '0');
    const ss = `${total % 60}`.padStart(2, '0');
    return `${mm}:${ss}`;
  }

  private failPage(user: string, cause: string, next: string, code: string): void {
    this.pageState = YoPageState.ERROR;
    this.errorUser = user;
    this.errorCause = cause;
    this.errorNext = next;
    this.errorCode = code;
  }

  private applyNative(error: ResultError | undefined, action: string): void {
    if (error === undefined) {
      return;
    }
    const sentence = WifiFieldLabels.errorSentence(error.nativeCode, error.message);
    this.scanFailure = sentence;
    this.scanFailureCode = error.nativeCode;
    this.appendLog(action, sentence, error.nativeCode);
  }

  gapLabel(): string {
    return WifiNetworkConstants.NOT_PROVIDED;
  }

  selectRow(id: string): void {
    this.selectedApId = id;
    const row = this.selectedRow();
    this.selectedTitle = row === undefined ? '隐藏网络' : (row.ssid.length > 0 ? row.ssid : '空 SSID');
  }

  selectedRow(): WifiAccessPointSnapshot | undefined {
    for (let i = 0; i < this.scanRows.length; i++) {
      if (this.scanRows[i].id === this.selectedApId) {
        return this.scanRows[i];
      }
    }
    return undefined;
  }

  ssidGroups(): string[] {
    const rows = this.visibleRows();
    const names: string[] = [];
    for (let i = 0; i < rows.length; i++) {
      const name = rows[i].ssid.length > 0 ? rows[i].ssid : '空 SSID';
      let seen = false;
      for (let j = 0; j < names.length; j++) {
        if (names[j] === name) {
          seen = true;
        }
      }
      if (!seen) {
        names.push(name);
      }
    }
    return names;
  }

  rowsForSsid(ssid: string): WifiAccessPointSnapshot[] {
    const rows = this.visibleRows();
    const matched: WifiAccessPointSnapshot[] = [];
    for (let i = 0; i < rows.length; i++) {
      const name = rows[i].ssid.length > 0 ? rows[i].ssid : '空 SSID';
      if (name === ssid) {
        matched.push(rows[i]);
      }
    }
    return matched;
  }

  isGroupOpen(ssid: string): boolean {
    for (let i = 0; i < this.openGroups.length; i++) {
      if (this.openGroups[i] === ssid) {
        return true;
      }
    }
    return false;
  }

  toggleGroupRow(ssid: string): void {
    const next: string[] = [];
    let removed = false;
    for (let i = 0; i < this.openGroups.length; i++) {
      if (this.openGroups[i] === ssid) {
        removed = true;
      } else {
        next.push(this.openGroups[i]);
      }
    }
    if (!removed) {
      next.push(ssid);
    }
    this.openGroups = next;
  }

  async loadProperties(): Promise<void> {
    const props = await this.repository.readConnectionProperties();
    if (!props.success || props.value === undefined) {
      this.propertyLines = [props.error !== undefined ? props.error.message : '失败'];
      this.appendLog('readProperties', this.propertyLines[0], props.error !== undefined ? props.error.nativeCode : '');
      return;
    }
    const value = props.value;
    const lines: string[] = [
      `网卡 ${value.interfaceName}`,
      `MTU ${value.mtu}`,
      `地址 ${value.linkAddressState}`,
      `DNS ${value.dnsState}`,
      `路由 ${value.routeState}`,
      `地址族 ${value.familyLine}`
    ];
    for (let i = 0; i < value.routes.length; i++) {
      const route = value.routes[i];
      lines.push(`${route.destination} 网关 ${route.gateway} 默认 ${route.isDefault ? '是' : '否'}`);
    }
    this.propertyLines = lines;
    this.appendLog('readProperties', 'listed', '');
  }

  loadProxy(): void {
    const proxy = this.repository.readHttpProxy();
    if (!proxy.success || proxy.value === undefined) {
      this.proxyLine = proxy.error !== undefined ? proxy.error.message : '失败';
      return;
    }
    this.proxyLine = `主机 ${proxy.value.host} 端口 ${proxy.value.port} 排除 ${proxy.value.exclusionList}`;
    this.appendLog('readProxy', this.proxyLine, '');
  }

  async resolveHost(): Promise<void> {
    const result = await this.repository.resolveHost(this.hostInput, this.dnsFamily);
    if (!result.success || result.value === undefined) {
      const message = result.error !== undefined ? result.error.message : '解析失败';
      this.addressLines = [`Unicode ${this.hostInput}`, message];
      this.appendLog('dns', message, result.error !== undefined ? result.error.nativeCode : '');
      return;
    }
    const lines: string[] = [
      `Unicode ${result.value.unicodeHost}`,
      `ASCII ${result.value.asciiHost}`,
      `地址族 ${result.value.familyLabel}`,
      '默认网络'
    ];
    for (let i = 0; i < result.value.addresses.length; i++) {
      lines.push(result.value.addresses[i]);
    }
    this.addressLines = lines;
    this.appendLog('dns', result.value.familyLabel, '');
  }

  async runProbe(): Promise<void> {
    const result = await this.repository.queryProbe(this.hostInput);
    if (!result.success || result.value === undefined) {
      this.addressLines = [result.error !== undefined ? result.error.message : '探测失败'];
      this.appendLog('probe', this.addressLines[0], '');
      return;
    }
    this.addressLines = [
      result.value.methodLabel,
      `丢包率 ${result.value.lossRate}`,
      `RTT ${result.value.rttText}`
    ];
    this.appendLog('probe', result.value.methodLabel, '');
  }

  async readTraffic(olderThan31Days: boolean): Promise<void> {
    const end = Date.now();
    const start = olderThan31Days ? end - (32 * 24 * 60 * 60 * 1000) : end - (24 * 60 * 60 * 1000);
    const result = await this.repository.readSelfWifiTraffic(start, end);
    if (!result.success || result.value === undefined) {
      this.trafficLine = result.error !== undefined ? `${result.error.message} ${result.error.nativeCode}` : '失败';
      this.appendLog('selfTraffic', this.trafficLine, result.error !== undefined ? result.error.nativeCode : '');
      return;
    }
    this.trafficLine = result.value;
    this.appendLog('selfTraffic', result.value, '');
  }

  refuseOtherUidTraffic(): void {
    this.trafficLine = '拒绝。没有 GET_NETWORK_STATS，不出现其他应用的字节数。';
    this.appendLog('uidTraffic', 'denied', '201');
  }

  refuseStaDisconnect(): void {
    this.connectMessage = '需要系统应用或企业权限。系统连接保持到用户在系统设置中断开。';
    this.appendLog('disconnectSta', 'refused', '');
  }

  refuseSavedPsk(): void {
    this.connectMessage = '企业权限。不显示 PSK。';
    this.appendLog('readSavedPsk', 'denied', '');
  }

  private noteNetEvent(name: string, detail: string): void {
    this.appendLog(name, detail, '');
    const next: string[] = [];
    for (let i = 0; i < this.netEventLines.length; i++) {
      next.push(this.netEventLines[i]);
    }
    next.push(`${name} ${detail}`);
    this.netEventLines = next;
    if (detail === '网络阻塞') {
      this.capabilityLabel = '网络阻塞';
    } else if (name === 'netCapabilitiesChange') {
      this.capabilityLabel = detail;
    }
  }

  private bandwidthFromStatus(status: string): string {
    const token = '系统估计';
    const at = status.indexOf(token);
    if (at < 0) {
      return '未读取';
    }
    const rest = status.substring(at + token.length).trim();
    if (rest.indexOf('无法评估') >= 0) {
      return '无法评估';
    }
    return rest;
  }

  private mbps(bytes: number, latencyMs: number): string {
    if (latencyMs <= 0) {
      return '';
    }
    const value = (bytes * 8) / latencyMs / 1000;
    return `${Math.round(value * 10) / 10} Mbps`;
  }

  private static buildWalls(emulator: boolean): WifiWallLine[] {
    const passTone = emulator ? '未通过' : '受限权限';
    return [
      new WifiWallLine('WN-118', '网络报文分析', '开发者选项中的网络报文分析。抓包在 PC 的 Wireshark。与 USB 调试互斥。没有开始抓包按钮。', '系统设置', 'warning'),
      new WifiWallLine('WN-119', 'USB 未连接', 'USB 未连接时，该开关不可用。', '系统设置', 'warning'),
      new WifiWallLine('WN-120', '其他应用流量', '没有捕获其他应用流量或导出整机 pcap 的动作。', '未提供', 'neutral'),
      new WifiWallLine('WN-121', 'PF_PACKET', '仅限带 kernel.NET_RAW 且 sudo 的二进制。本应用不提供 PF_PACKET。', '未提供', 'neutral'),
      new WifiWallLine('WN-122', '弱网模拟', '弱网场景在网络领航员。本页没有带宽滑杆。', '系统设置', 'warning'),
      new WifiWallLine('WN-123', '多网并发', '多网并发需要 LINKTURBO。本页不发起多网激活。', '受限权限', 'warning'),
      new WifiWallLine('WN-124', 'P2P / VPN / 加速', '模拟器不支持 P2P、VPN、网络加速。不把失败记成真机缺陷。验收保持未通过。', emulator ? '未通过' : passTone, 'warning'),
      new WifiWallLine('WN-125', 'P2P 连接', '没有 GET_WIFI_PEERS_MAC 时 P2P 失败可见。模拟器不支持 P2P。', '受限权限', 'warning'),
      new WifiWallLine('WN-126', '以太网 MAC', 'Phone 上读取以太网 MAC 被拒绝。', '拒绝', 'warning'),
      new WifiWallLine('WN-127', '防火墙', '没有防火墙规则编辑。面向企业或系统应用，当前仅 2in1 可申请。', '企业或系统', 'warning'),
      new WifiWallLine('WN-132', '禁止入口', '没有洪泛、其他应用阻断、密码破解。', '未提供', 'neutral')
    ];
  }
}
