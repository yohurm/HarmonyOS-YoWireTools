import { Result, ResultError } from 'common_core';
import { EnsurePermissionUseCase, PermissionScenario } from 'debug_core';
import { WifiNetworkConstants } from '../../constants/WifiNetworkConstants';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { WifiCandidateDraft, WifiFeatureFact, WifiIpv4Facts, WifiIpv6Facts, WifiScanBatch } from '../model/WifiDebugFacts';
import { WifiLinkedInfoSnapshot } from '../model/WifiLinkedInfoSnapshot';
import { DnsLookupFacts, HttpProxyFacts, NetworkPropertyFacts, ProbeFacts, TraceHopFact } from '../model/NetworkInspectFacts';
import { NetworkStateSnapshot } from '../model/NetworkStateSnapshot';
import { WifiNetworkRepositoryContract } from '../repository/WifiNetworkRepositoryContract';
import { WifiCandidateRejection, WifiCandidateRules } from '../service/WifiCandidateRules';
import { WifiScanLogger } from '../service/WifiScanLogger';

export class WifiDebugUseCases {
  private readonly repository: WifiNetworkRepositoryContract;
  private readonly ensurePermission: EnsurePermissionUseCase;

  constructor(
    repository: WifiNetworkRepositoryContract,
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.repository = repository;
    this.ensurePermission = ensurePermission;
  }

  isEmulatorRuntime(): boolean {
    return this.repository.isEmulatorRuntime();
  }

  sdkApiVersion(): number {
    return this.repository.sdkApiVersion();
  }

  startNetObservation(
    listener: (snapshot: NetworkStateSnapshot) => void,
    events: (name: string, detail: string) => void
  ): void {
    this.repository.startNetObservation(listener, events);
  }

  stopNetObservation(): void {
    this.repository.stopNetObservation();
  }

  onWifiPowerState(listener: (state: number) => void): Result<void> {
    return this.repository.onWifiPowerState(listener);
  }

  offWifiPowerState(): void {
    this.repository.offWifiPowerState();
  }

  onWifiConnectionState(listener: (state: number) => void): Result<void> {
    return this.repository.onWifiConnectionState(listener);
  }

  offWifiConnectionState(): void {
    this.repository.offWifiConnectionState();
  }

  onWifiRssi(listener: (rssi: number) => void): Result<void> {
    return this.repository.onWifiRssi(listener);
  }

  offWifiRssi(): void {
    this.repository.offWifiRssi();
  }

  getWifiState(): Promise<Result<boolean>> {
    return this.repository.getWifiState();
  }

  isStaConnected(): Promise<Result<boolean>> {
    return this.repository.isStaConnected();
  }

  isHotspotActive(): Promise<Result<boolean>> {
    return this.repository.isHotspotActive();
  }

  readFeatureSupport(): Promise<Result<WifiFeatureFact[]>> {
    return this.repository.readFeatureSupport();
  }

  getScanCooldownRemainingMs(): number {
    return this.repository.getScanCooldownRemainingMs();
  }

  foregroundSlotsLeft(): number {
    return this.repository.foregroundSlotsLeft();
  }

  getLinkedInfo(bssidVisible: boolean): Promise<Result<WifiLinkedInfoSnapshot>> {
    return this.repository.getLinkedInfo(bssidVisible);
  }

  readIpv4(): Promise<Result<WifiIpv4Facts>> {
    return this.repository.readIpv4();
  }

  readIpv6(): Promise<Result<WifiIpv6Facts>> {
    return this.repository.readIpv6();
  }

  listCandidateSsids(): Promise<Result<string[]>> {
    return this.repository.listCandidateSsids();
  }

  readDefaultNet(): Promise<Result<NetworkStateSnapshot>> {
    return this.repository.readDefaultNet();
  }

  readOnlineStatus(): Promise<Result<string>> {
    return this.repository.readOnlineStatus();
  }

  cancelPortScan(): void {
    this.repository.cancelPortScan();
  }

  queryTraceRoute(destination: string): Promise<Result<TraceHopFact[]>> {
    return this.repository.queryTraceRoute(destination);
  }

  abortHttp(): void {
    this.repository.abortHttp();
  }

  readConnectionProperties(): Promise<Result<NetworkPropertyFacts>> {
    return this.repository.readConnectionProperties();
  }

  readHttpProxy(): Promise<Result<HttpProxyFacts>> {
    return this.repository.readHttpProxy();
  }

  resolveHost(host: string, family: number): Promise<Result<DnsLookupFacts>> {
    return this.repository.resolveHost(host, family);
  }

  queryProbe(destination: string): Promise<Result<ProbeFacts>> {
    return this.repository.queryProbe(destination);
  }

  readSelfWifiTraffic(startMs: number, endMs: number): Promise<Result<string>> {
    return this.repository.readSelfWifiTraffic(startMs, endMs);
  }

  async openPage(): Promise<Result<void>> {
    const info = await this.ensurePermission.execute(PermissionScenario.WIFI_INFO);
    const control = await this.ensurePermission.execute(PermissionScenario.WIFI_CONTROL);
    const network = await this.ensurePermission.execute(PermissionScenario.NETWORK_INFO);
    const access = await this.ensurePermission.execute(PermissionScenario.NETWORK_ACCESS);
    if (!info.granted || !control.granted || !network.granted || !access.granted) {
      await WifiScanLogger.log('', 'action=openWifiDebug result=declarationMismatch');
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.NO_WIFI_INFO,
        '权限被拒绝',
        undefined,
        {},
        WifiNetworkConstants.NATIVE_PERMISSION_DENIED
      ));
    }
    await WifiScanLogger.log('', 'action=openWifiDebug result=noRuntimeDialog');
    return Result.ok(undefined);
  }

  async startScan(peersMacGranted: boolean, foreground: boolean, paused: boolean): Promise<Result<WifiScanBatch>> {
    if (paused) {
      await WifiScanLogger.log('', 'action=pauseScan result=paused');
      return Result.fail(new ResultError(WifiNetworkErrorCodes.SCAN_COOLDOWN, '已暂停'));
    }
    const control = await this.ensurePermission.execute(PermissionScenario.WIFI_CONTROL);
    if (!control.granted) {
      await WifiScanLogger.log('', 'action=startScan result=permissionDenied');
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.NO_WIFI_INFO,
        '权限被拒绝',
        undefined,
        {},
        WifiNetworkConstants.NATIVE_PERMISSION_DENIED
      ));
    }
    const scan = await this.repository.runForegroundScan(peersMacGranted, foreground);
    const resultName = scan.success ? 'success' : (scan.error !== undefined ? scan.error.message : 'failed');
    await WifiScanLogger.log('', `action=startScan result=${resultName}`, scan.error !== undefined ? scan.error.nativeCode : '');
    return scan;
  }

  async refreshCache(peersMacGranted: boolean): Promise<Result<WifiScanBatch>> {
    const info = await this.ensurePermission.execute(PermissionScenario.WIFI_INFO);
    if (!info.granted) {
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.NO_WIFI_INFO,
        '权限被拒绝',
        undefined,
        {},
        WifiNetworkConstants.NATIVE_PERMISSION_DENIED
      ));
    }
    const cache = await this.repository.refreshScanCache(peersMacGranted);
    await WifiScanLogger.log('', 'action=refreshCache result=cache');
    return cache;
  }

  async connectCandidate(draft: WifiCandidateDraft): Promise<Result<string>> {
    const rejected: WifiCandidateRejection | undefined = WifiCandidateRules.validate(draft);
    if (rejected !== undefined) {
      await WifiScanLogger.log('', `action=connectCandidate result=rejected`, rejected.nativeCode);
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.SCAN_LIMITED,
        rejected.message,
        undefined,
        {},
        rejected.nativeCode
      ));
    }
    const control = await this.ensurePermission.execute(PermissionScenario.WIFI_CONTROL);
    if (!control.granted) {
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.NO_WIFI_INFO,
        '权限被拒绝',
        undefined,
        {},
        WifiNetworkConstants.NATIVE_PERMISSION_DENIED
      ));
    }
    let networkId = draft.networkId;
    if (networkId < 0) {
      const added = await this.repository.addCandidate(draft);
      if (!added.success || added.value === undefined) {
        return Result.fail(added.error ?? new ResultError(WifiNetworkErrorCodes.SCAN_LIMITED, '添加失败'));
      }
      networkId = added.value;
    }
    if (draft.useUserAction) {
      const connected = await this.repository.connectCandidateWithUserAction(networkId);
      if (!connected.success) {
        return Result.fail(connected.error ?? new ResultError(WifiNetworkErrorCodes.SCAN_LIMITED, '连接失败'));
      }
      await WifiScanLogger.log('', 'action=connectCandidate result=userActionStarted');
      return Result.ok(`${networkId}`);
    }
    const connected = this.repository.connectCandidate(networkId);
    if (!connected.success) {
      return Result.fail(connected.error ?? new ResultError(WifiNetworkErrorCodes.SCAN_LIMITED, '连接失败'));
    }
    await WifiScanLogger.log('', 'action=connectCandidate result=started');
    return Result.ok(`${networkId}`);
  }

  async removeCandidate(networkId: number): Promise<Result<void>> {
    return this.repository.removeCandidate(networkId);
  }
}
