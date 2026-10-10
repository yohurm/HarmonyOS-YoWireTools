import { Observable } from 'common_core';
import { WifiAccessPointSnapshot } from '../model/WifiAccessPointSnapshot';
import { WifiLinkedInfoSnapshot } from '../model/WifiLinkedInfoSnapshot';
import { WifiOverviewSnapshot } from '../model/WifiOverviewSnapshot';
import { NetworkDiagnosticPlan, DiagnosticStepResult } from '../model/NetworkDiagnosticModels';
import { SocketConnectionParams, UdpSessionConfig } from '../model/SocketModels';
import { HttpRequestDraft, HttpResponseRecord } from '../model/HttpModels';
import { WebSocketConfig } from '../model/WebSocketModels';
import { MqttConnectConfig } from '../model/MqttModels';
import { LanDiscoveryConfig, LanHostResult, PortScanConfig, PortProbeResult } from '../model/LanDiscoveryModels';
import { NetworkStateSnapshot } from '../model/NetworkStateSnapshot';
import { Subscription, Result } from 'common_core';
import { DiscoveredNetworkService } from '../model/MqttModels';
import { MulticastSessionConfig } from '../model/SocketModels';
import { WebSocketMessageRecord, WebSocketServerConfigModel } from '../model/WebSocketModels';

/**
 * Domain repository contract per architecture 03-§13.1.
 */
export interface WifiNetworkRepositoryContract {
  getWifiState(): Promise<Result<boolean>>;
  getLinkedInfo(bssidVisible: boolean): Promise<Result<WifiLinkedInfoSnapshot>>;
  startWifiScan(): Promise<Result<void>>;
  getScanResults(bssidVisible: boolean, fromCache: boolean): Promise<Result<WifiAccessPointSnapshot[]>>;
  observeNetworkState(): Observable<NetworkStateSnapshot>;
  loadOverview(wifiInfoGranted: boolean, peersMacGranted: boolean): Promise<WifiOverviewSnapshot>;
  runDiagnostics(plan: NetworkDiagnosticPlan): Promise<DiagnosticStepResult[]>;
  probeTcpPort(host: string, port: number, timeoutMs: number): Promise<PortProbeResult>;
  executeHttp(request: HttpRequestDraft): Promise<Result<HttpResponseRecord>>;
  connectWebSocket(config: WebSocketConfig): Promise<Result<void>>;
  disconnectWebSocket(): Promise<void>;
  startLanDiscovery(config: LanDiscoveryConfig, onHost: (host: LanHostResult) => void): Promise<Result<void>>;
  cancelLanDiscovery(): void;
  startPortScan(config: PortScanConfig, onResult: (result: PortProbeResult) => void): Promise<Result<void>>;
  cancelPortScan(): void;
  createMqttSession(config: MqttConnectConfig): Promise<Result<void>>;
  createTcpClientParams(params: SocketConnectionParams): SocketConnectionParams;
  openUdpSocket(sessionId: string, config: UdpSessionConfig): Promise<Result<void>>;
  joinMulticast(sessionId: string, config: MulticastSessionConfig): Promise<Result<void>>;
  leaveMulticast(): Promise<void>;
  startMdnsDiscovery(serviceType: string): Promise<Result<void>>;
  stopMdnsDiscovery(): Promise<void>;
  startSsdpDiscovery(): Promise<Result<void>>;
  stopSsdpDiscovery(): Promise<void>;
  startWebSocketServer(config: WebSocketServerConfigModel): Promise<Result<void>>;
  stopWebSocketServer(): Promise<void>;
  listDiscoveredServices(): DiscoveredNetworkService[];
  observeMdnsServices(onChange: (services: DiscoveredNetworkService[]) => void): Subscription;
  observeSsdpServices(onChange: () => void): Subscription;
  disconnectMqtt(): Promise<void>;
  onMqttMessage(listener: (payload: string) => void): Result<void>;
  publishMqtt(topic: string, payload: string): Promise<Result<void>>;
  startTcpServer(port: number): Promise<Result<void>>;
  stopTcpServer(): Promise<void>;
  connectTcpClient(sessionId: string, params: SocketConnectionParams): Promise<Result<void>>;
  sendWebSocketText(text: string): Promise<Result<void>>;
  observeWebSocketMessages(): Observable<WebSocketMessageRecord[]>;
}
