import { CancellationTokenSource, ResultError } from 'common_core';
import { Observable, Result } from 'common_core';
import { WifiInfoDataSource } from '../datasource/WifiInfoDataSource';
import { NetworkConnectionDataSource, NetworkStateSnapshot } from '../datasource/NetworkConnectionDataSource';
import { TcpSocketDataSource } from '../datasource/TcpSocketDataSource';
import { UdpSocketDataSource } from '../datasource/UdpSocketDataSource';
import { MqttClientDataSource } from '../datasource/MqttClientDataSource';
import { HttpDataSource } from '../datasource/HttpDataSource';
import { WebSocketDataSource } from '../datasource/WebSocketDataSource';
import { socket } from '@kit.NetworkKit';
import { WifiAccessPointSnapshot } from '../../domain/model/WifiAccessPointSnapshot';
import { WifiLinkedInfoSnapshot } from '../../domain/model/WifiLinkedInfoSnapshot';
import { WifiOverviewSnapshot } from '../../domain/model/WifiOverviewSnapshot';
import { WifiScanSource } from '../../domain/model/WifiScanState';
import {
  DiagnosticStepKind,
  DiagnosticStepResult,
  DiagnosticStepState,
  NetworkDiagnosticPlan
} from '../../domain/model/NetworkDiagnosticModels';
import { SocketConnectionParams, UdpSessionConfig } from '../../domain/model/SocketModels';
import { HttpRequestDraft, HttpResponseRecord } from '../../domain/model/HttpModels';
import { WebSocketConfig } from '../../domain/model/WebSocketModels';
import { MqttConnectConfig } from '../../domain/model/MqttModels';
import {
  LanDiscoveryConfig,
  LanHostAliveState,
  LanHostResult,
  PortProbeResult,
  PortProbeState,
  PortScanConfig
} from '../../domain/model/LanDiscoveryModels';
import { WifiNetworkRepositoryContract } from '../../domain/repository/WifiNetworkRepositoryContract';
import { WifiScanCooldownTracker } from '../../domain/service/WifiScanCooldownTracker';
import { CidrAddressGenerator } from '../../domain/service/CidrAddressGenerator';
import { PortScanQueue } from '../../domain/service/PortScanQueue';
import { PrivateNetworkGuard } from '../../domain/service/PrivateNetworkGuard';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';

/**
 * WiFi/Network repository facade per architecture 03-§13.1.
 */
export class WifiNetworkRepository implements WifiNetworkRepositoryContract {
  private static instance: WifiNetworkRepository | undefined;
  private readonly wifiDataSource: WifiInfoDataSource;
  private readonly networkDataSource: NetworkConnectionDataSource;
  private readonly tcpDataSource: TcpSocketDataSource;
  private readonly udpDataSource: UdpSocketDataSource;
  private readonly mqttDataSource: MqttClientDataSource;
  private readonly httpDataSource: HttpDataSource;
  private readonly webSocketDataSource: WebSocketDataSource;
  private readonly scanCooldown: WifiScanCooldownTracker = new WifiScanCooldownTracker();
  private lastScanResults: WifiAccessPointSnapshot[] = [];
  private lastScanAtMs: number = 0;
  private lastScanFromCache: boolean = true;
  private lanQueue: PortScanQueue | undefined;
  private portScanQueue: PortScanQueue | undefined;
  private lanCancelSource: CancellationTokenSource | undefined;
  private portScanCancelSource: CancellationTokenSource | undefined;

  private constructor(
    wifiDataSource: WifiInfoDataSource = WifiInfoDataSource.getInstance(),
    networkDataSource: NetworkConnectionDataSource = NetworkConnectionDataSource.getInstance(),
    tcpDataSource: TcpSocketDataSource = TcpSocketDataSource.getInstance(),
    udpDataSource: UdpSocketDataSource = UdpSocketDataSource.getInstance(),
    mqttDataSource: MqttClientDataSource = MqttClientDataSource.getInstance(),
    httpDataSource: HttpDataSource = HttpDataSource.getInstance(),
    webSocketDataSource: WebSocketDataSource = WebSocketDataSource.getInstance()
  ) {
    this.wifiDataSource = wifiDataSource;
    this.networkDataSource = networkDataSource;
    this.tcpDataSource = tcpDataSource;
    this.udpDataSource = udpDataSource;
    this.mqttDataSource = mqttDataSource;
    this.httpDataSource = httpDataSource;
    this.webSocketDataSource = webSocketDataSource;
  }

  static getInstance(): WifiNetworkRepository {
    if (WifiNetworkRepository.instance === undefined) {
      WifiNetworkRepository.instance = new WifiNetworkRepository();
    }
    return WifiNetworkRepository.instance;
  }

  getWifiState(): Promise<Result<boolean>> {
    return this.wifiDataSource.isWifiActive();
  }

  getLinkedInfo(bssidVisible: boolean): Promise<Result<WifiLinkedInfoSnapshot>> {
    return this.wifiDataSource.getLinkedInfo(bssidVisible);
  }

  async startWifiScan(): Promise<Result<void>> {
    if (!this.scanCooldown.canScanNow()) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.SCAN_COOLDOWN, 'Scan cooldown active'));
    }
    const started = await this.wifiDataSource.startScan();
    if (started.success) {
      this.scanCooldown.recordScan();
      this.lastScanFromCache = false;
    }
    return started;
  }

  getScanResults(bssidVisible: boolean, fromCache: boolean): Promise<Result<WifiAccessPointSnapshot[]>> {
    const source = fromCache ? WifiScanSource.CACHE : WifiScanSource.ACTIVE_SCAN;
    return this.wifiDataSource.getScanResults(bssidVisible, source).then((result) => {
      if (result.success && result.value !== undefined) {
        this.lastScanResults = result.value;
        this.lastScanAtMs = Date.now();
      }
      return result;
    });
  }

  observeNetworkState(): Observable<NetworkStateSnapshot> {
    return this.networkDataSource.observeNetworkState();
  }

  async loadOverview(wifiInfoGranted: boolean, peersMacGranted: boolean): Promise<WifiOverviewSnapshot> {
    const warnings: string[] = [];
    let wifiActive = false;
    let linked: WifiLinkedInfoSnapshot | undefined;
    if (wifiInfoGranted) {
      const activeResult = await this.wifiDataSource.isWifiActive();
      wifiActive = activeResult.success && activeResult.value === true;
      const linkedResult = await this.wifiDataSource.getLinkedInfo(peersMacGranted);
      if (linkedResult.success) {
        linked = linkedResult.value;
      }
      if (!peersMacGranted) {
        warnings.push('BSSID masked: GET_WIFI_PEERS_MAC not granted');
      }
      const scanResult = await this.getScanResults(peersMacGranted, true);
      if (!scanResult.success) {
        warnings.push('Scan cache unavailable');
      }
    } else {
      warnings.push('GET_WIFI_INFO permission required');
    }
    return new WifiOverviewSnapshot(
      wifiActive,
      linked,
      this.lastScanResults.length,
      this.lastScanAtMs,
      this.lastScanFromCache,
      warnings
    );
  }

  onWifiStateChange(listener: (active: boolean) => void): void {
    this.wifiDataSource.onWifiStateChange(listener);
  }

  offWifiStateChange(): void {
    this.wifiDataSource.offWifiStateChange();
  }

  onWifiConnectionChange(listener: () => void): void {
    this.wifiDataSource.onWifiConnectionChange(listener);
  }

  offWifiConnectionChange(): void {
    this.wifiDataSource.offWifiConnectionChange();
  }

  getScanCooldownRemainingMs(): number {
    return this.scanCooldown.remainingCooldownMs();
  }

  getLastScanResults(): WifiAccessPointSnapshot[] {
    return this.lastScanResults;
  }

  async runDiagnostics(plan: NetworkDiagnosticPlan): Promise<DiagnosticStepResult[]> {
    const results: DiagnosticStepResult[] = [];
    for (let i = 0; i < plan.steps.length; i++) {
      const step = plan.steps[i];
      const start = Date.now();
      if (step === DiagnosticStepKind.NETWORK_STATE) {
        const net = await this.networkDataSource.getDefaultNet();
        results.push(new DiagnosticStepResult(
          step,
          net.success ? DiagnosticStepState.SUCCESS : DiagnosticStepState.FAILED,
          start,
          Date.now(),
          Date.now() - start,
          0,
          net.success ? '' : WifiNetworkErrorCodes.NO_INTERNET,
          net.success ? 'Default network available' : 'No default network'
        ));
      } else if (step === DiagnosticStepKind.DNS_LOOKUP) {
        results.push(new DiagnosticStepResult(
          step,
          DiagnosticStepState.SUCCESS,
          start,
          Date.now(),
          Date.now() - start,
          0,
          '',
          `DNS lookup delegated to TCP/HTTP for ${plan.targetHost}`
        ));
      } else if (step === DiagnosticStepKind.TCP_CONNECT) {
        const probe = await this.tcpDataSource.probeConnect(plan.targetHost, plan.targetPort, plan.timeoutMs);
        results.push(new DiagnosticStepResult(
          step,
          probe.state === PortProbeState.OPEN ? DiagnosticStepState.SUCCESS : DiagnosticStepState.FAILED,
          start,
          Date.now(),
          probe.latencyMs,
          0,
          probe.state === PortProbeState.OPEN ? '' : WifiNetworkErrorCodes.CONNECT_TIMEOUT,
          probe.error.length > 0 ? probe.error : `TCP ${plan.targetPort} ${probe.state}`
        ));
      } else if (step === DiagnosticStepKind.HTTP_PROBE) {
        const draft = new HttpRequestDraft(
          'diag',
          'HEAD',
          `http://${plan.targetHost}:${plan.targetPort}`,
          [],
          [],
          '',
          plan.timeoutMs,
          plan.timeoutMs
        );
        const httpResult = await this.httpDataSource.execute(draft);
        results.push(new DiagnosticStepResult(
          step,
          httpResult.success ? DiagnosticStepState.SUCCESS : DiagnosticStepState.FAILED,
          start,
          Date.now(),
          Date.now() - start,
          0,
          httpResult.success ? '' : (httpResult.error?.code ?? WifiNetworkErrorCodes.CONNECT_TIMEOUT),
          httpResult.success ?
            `HTTP ${httpResult.value?.responseCode ?? 0}` :
            (httpResult.error?.message ?? 'HTTP probe failed')
        ));
      } else if (step === DiagnosticStepKind.PING_LIKE) {
        const probe = await this.tcpDataSource.probeConnect(plan.targetHost, plan.targetPort, plan.timeoutMs);
        results.push(new DiagnosticStepResult(
          step,
          probe.state === PortProbeState.OPEN ? DiagnosticStepState.SUCCESS : DiagnosticStepState.FAILED,
          start,
          Date.now(),
          probe.latencyMs,
          0,
          '',
          'TCP connect used as ping-like probe (non-ICMP)'
        ));
      }
    }
    return results;
  }

  probeTcpPort(host: string, port: number, timeoutMs: number): Promise<PortProbeResult> {
    return this.tcpDataSource.probeConnect(host, port, timeoutMs);
  }

  executeHttp(request: HttpRequestDraft): Promise<Result<HttpResponseRecord>> {
    return this.httpDataSource.execute(request);
  }

  connectWebSocket(config: WebSocketConfig): Promise<Result<void>> {
    return this.webSocketDataSource.connect(config);
  }

  disconnectWebSocket(): Promise<void> {
    return this.webSocketDataSource.disconnect();
  }

  getWebSocketDataSource(): WebSocketDataSource {
    return this.webSocketDataSource;
  }

  async startLanDiscovery(
    config: LanDiscoveryConfig,
    onHost: (host: LanHostResult) => void
  ): Promise<Result<void>> {
    if (!PrivateNetworkGuard.isPrivateCidr(config.cidr)) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.SCAN_RANGE_TOO_LARGE, 'Only private network ranges allowed'));
    }
    this.cancelLanDiscovery();
    this.lanCancelSource = new CancellationTokenSource();
    this.lanQueue = new PortScanQueue(config.concurrency);
    this.lanQueue.bindToken(this.lanCancelSource.token);
    const hosts = CidrAddressGenerator.listHosts(config.cidr);
    const now = Date.now();
    for (let i = 0; i < hosts.length; i++) {
      const ip = hosts[i];
      this.lanQueue.enqueue(async () => {
        if (this.lanQueue !== undefined && this.lanQueue.isCancelled()) {
          return;
        }
        let alive = false;
        let latency = 0;
        const openPorts: PortProbeResult[] = [];
        for (let p = 0; p < config.probePorts.length; p++) {
          const port = config.probePorts[p];
          const probe = await this.tcpDataSource.probeConnect(ip, port, config.timeoutMs);
          if (probe.state === PortProbeState.OPEN) {
            alive = true;
            latency = probe.latencyMs;
            openPorts.push(probe);
            break;
          }
        }
        if (alive) {
          onHost(new LanHostResult(
            ip,
            '',
            LanHostAliveState.ALIVE,
            latency,
            openPorts,
            now,
            Date.now()
          ));
        }
      });
    }
    void this.lanQueue.drain();
    return Result.ok(undefined);
  }

  cancelLanDiscovery(): void {
    if (this.lanQueue !== undefined) {
      this.lanQueue.cancel();
    }
    if (this.lanCancelSource !== undefined) {
      this.lanCancelSource.cancel();
    }
  }

  async startPortScan(
    config: PortScanConfig,
    onResult: (result: PortProbeResult) => void
  ): Promise<Result<void>> {
    if (!PrivateNetworkGuard.isPrivateIpv4(config.host) &&
      PrivateNetworkGuard.isLargeRange(config.startPort, config.endPort)) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.SCAN_RANGE_TOO_LARGE, 'Large public range scan requires confirmation'));
    }
    this.cancelPortScan();
    this.portScanCancelSource = new CancellationTokenSource();
    this.portScanQueue = new PortScanQueue(config.concurrency);
    this.portScanQueue.bindToken(this.portScanCancelSource.token);
    for (let port = config.startPort; port <= config.endPort; port++) {
      const targetPort = port;
      this.portScanQueue.enqueue(async () => {
        if (this.portScanQueue !== undefined && this.portScanQueue.isCancelled()) {
          return;
        }
        const probe = await this.tcpDataSource.probeConnect(config.host, targetPort, config.timeoutMs);
        onResult(probe);
      });
    }
    void this.portScanQueue.drain();
    return Result.ok(undefined);
  }

  cancelPortScan(): void {
    if (this.portScanQueue !== undefined) {
      this.portScanQueue.cancel();
    }
    if (this.portScanCancelSource !== undefined) {
      this.portScanCancelSource.cancel();
    }
  }

  createTcpClientParams(params: SocketConnectionParams): SocketConnectionParams {
    return params;
  }

  async createMqttSession(config: MqttConnectConfig): Promise<Result<void>> {
    return this.mqttDataSource.connect(config);
  }
}
