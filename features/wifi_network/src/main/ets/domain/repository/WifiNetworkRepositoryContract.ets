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
import { DnsLookupFacts, HttpProxyFacts, NetworkPropertyFacts, ProbeFacts } from '../model/NetworkInspectFacts';
import { NetworkStateSnapshot } from '../model/NetworkStateSnapshot';
import {
  WifiCandidateDraft,
  WifiFeatureFact,
  WifiIpv4Facts,
  WifiIpv6Facts,
  WifiScanBatch
} from '../model/WifiDebugFacts';
import { Result } from 'common_core';

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
  foregroundSlotsLeft(): number;
  getScanCooldownRemainingMs(): number;
  getLastScanResults(): WifiAccessPointSnapshot[];
  getLastScanAtMs(): number;
  isEmulatorRuntime(): boolean;
  sdkApiVersion(): number;
  readFeatureSupport(): Promise<Result<WifiFeatureFact[]>>;
  isStaConnected(): Promise<Result<boolean>>;
  isHotspotActive(): Promise<Result<boolean>>;
  readIpv4(): Promise<Result<WifiIpv4Facts>>;
  readIpv6(): Promise<Result<WifiIpv6Facts>>;
  onWifiPowerState(listener: (state: number) => void): Result<void>;
  offWifiPowerState(): void;
  onWifiConnectionState(listener: (state: number) => void): Result<void>;
  offWifiConnectionState(): void;
  onWifiRssi(listener: (rssi: number) => void): Result<void>;
  offWifiRssi(): void;
  runForegroundScan(bssidVisible: boolean, foreground: boolean): Promise<Result<WifiScanBatch>>;
  refreshScanCache(bssidVisible: boolean): Promise<Result<WifiScanBatch>>;
  addCandidate(draft: WifiCandidateDraft): Promise<Result<number>>;
  connectCandidate(networkId: number): Result<void>;
  connectCandidateWithUserAction(networkId: number): Promise<Result<void>>;
  removeCandidate(networkId: number): Promise<Result<void>>;
  listCandidateSsids(): Promise<Result<string[]>>;
  readDefaultNet(): Promise<Result<NetworkStateSnapshot>>;
  readOnlineStatus(): Promise<Result<string>>;
  readConnectionProperties(): Promise<Result<NetworkPropertyFacts>>;
  readHttpProxy(): Result<HttpProxyFacts>;
  resolveHost(host: string, family: number): Promise<Result<DnsLookupFacts>>;
  queryProbe(destination: string): Promise<Result<ProbeFacts>>;
  readSelfWifiTraffic(startMs: number, endMs: number): Promise<Result<string>>;
  abortHttp(): void;
  startNetObservation(
    listener: (snapshot: NetworkStateSnapshot) => void,
    events: (name: string, detail: string) => void
  ): void;
  stopNetObservation(): void;
}
