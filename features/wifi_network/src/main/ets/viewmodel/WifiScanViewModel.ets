import { AppPermission, PermissionOrchestrator, PermissionStatus } from 'common_platform';
import { WifiAccessPointSnapshot } from '../domain/model/WifiAccessPointSnapshot';
import { WifiScanPhase } from '../domain/model/WifiScanState';
import { WifiNetworkRepository } from '../data/repository/WifiNetworkRepository';
import { StartWifiScanUseCase } from '../domain/usecase/WifiNetworkUseCases';
import { WifiChannelCalculator } from '../domain/service/WifiChannelCalculator';

@ObservedV2
export class WifiScanViewModel {
  @Trace scanPhase: WifiScanPhase = WifiScanPhase.IDLE;
  @Trace accessPoints: WifiAccessPointSnapshot[] = [];
  @Trace filteredPoints: WifiAccessPointSnapshot[] = [];
  @Trace cooldownMs: number = 0;
  @Trace statusMessage: string = '';
  @Trace filterSsid: string = '';
  @Trace filterBand: string = 'all';
  @Trace fromCache: boolean = true;
  @Trace showLimitDialog: boolean = false;
  @Trace limitDialogMessage: string = '';

  private readonly repository: WifiNetworkRepository = WifiNetworkRepository.getInstance();
  private readonly startScan: StartWifiScanUseCase = new StartWifiScanUseCase();
  private cooldownTimer: number = -1;

  async initialize(): Promise<void> {
    this.accessPoints = this.repository.getLastScanResults();
    this.applyFilter();
  }

  dispose(): void {
    if (this.cooldownTimer >= 0) {
      clearTimeout(this.cooldownTimer);
    }
  }

  async refreshCache(): Promise<void> {
    this.scanPhase = WifiScanPhase.READING_CACHE;
    const macPerm = await this.resolveMacPermission();
    const result = await this.repository.getScanResults(macPerm, true);
    if (result.success && result.value !== undefined) {
      this.accessPoints = result.value;
      this.fromCache = true;
      this.statusMessage = 'Loaded scan cache';
    } else {
      this.statusMessage = result.error?.message ?? 'Cache read failed';
    }
    this.scanPhase = WifiScanPhase.COMPLETED;
    this.applyFilter();
  }

  async scanAction(): Promise<void> {
    this.cooldownMs = this.repository.getScanCooldownRemainingMs();
    if (this.cooldownMs > 0) {
      this.scanPhase = WifiScanPhase.COOLING_DOWN;
      this.statusMessage = `Cooldown ${Math.ceil(this.cooldownMs / 1000)}s`;
      this.startCooldownTicker();
      return;
    }
    this.scanPhase = WifiScanPhase.ACTIVE_SCANNING;
    const result = await this.startScan.execute(true);
    if (result.success && result.value !== undefined) {
      this.accessPoints = result.value;
      this.fromCache = false;
      this.scanPhase = WifiScanPhase.COMPLETED;
      this.statusMessage = `Found ${this.accessPoints.length} APs`;
    } else {
      const cache = await this.repository.getScanResults(false, true);
      if (cache.success && cache.value !== undefined) {
        this.accessPoints = cache.value;
        this.fromCache = true;
        this.scanPhase = WifiScanPhase.LIMITED;
        this.statusMessage = result.error?.message ?? 'Active scan limited, showing cache';
        this.limitDialogMessage = this.statusMessage;
        this.showLimitDialog = true;
      } else {
        this.scanPhase = WifiScanPhase.FAILED;
        this.statusMessage = result.error?.message ?? 'Scan failed';
      }
    }
    this.applyFilter();
    this.cooldownMs = this.repository.getScanCooldownRemainingMs();
    this.startCooldownTicker();
  }

  applyFilter(): void {
    const filtered: WifiAccessPointSnapshot[] = [];
    for (let i = 0; i < this.accessPoints.length; i++) {
      const ap = this.accessPoints[i];
      if (this.filterSsid.length > 0 && ap.ssid.indexOf(this.filterSsid) < 0) {
        continue;
      }
      if (this.filterBand !== 'all') {
        const bandLabel = WifiChannelCalculator.bandLabel(ap.band);
        if (bandLabel !== this.filterBand) {
          continue;
        }
      }
      filtered.push(ap);
    }
    this.filteredPoints = filtered;
  }

  getChannelCounts(): Record<number, number> {
    const counts: Record<number, number> = {};
    for (let i = 0; i < this.filteredPoints.length; i++) {
      const ch = this.filteredPoints[i].channel;
      counts[ch] = (counts[ch] ?? 0) + 1;
    }
    return counts;
  }

  private startCooldownTicker(): void {
    if (this.cooldownTimer >= 0) {
      clearTimeout(this.cooldownTimer);
    }
    this.scheduleCooldownTick();
  }

  private scheduleCooldownTick(): void {
    this.cooldownMs = this.repository.getScanCooldownRemainingMs();
    if (this.cooldownMs <= 0 && this.scanPhase === WifiScanPhase.COOLING_DOWN) {
      this.scanPhase = WifiScanPhase.IDLE;
      this.cooldownTimer = -1;
      return;
    }
    if (this.cooldownMs <= 0) {
      this.cooldownTimer = -1;
      return;
    }
    this.cooldownTimer = setTimeout(() => {
      this.scheduleCooldownTick();
    }, 1000);
  }

  private async resolveMacPermission(): Promise<boolean> {
    const orchestrator = PermissionOrchestrator.getInstance();
    const status = await orchestrator.checkPermission(AppPermission.GET_WIFI_PEERS_MAC);
    return status === PermissionStatus.GRANTED;
  }
}
