import { LifecycleCoordinator, PermissionUiState } from 'common_platform';
import {
  EnsurePermissionUseCase,
  PermissionScenario,
  PermissionScenarioCoordinator
} from 'debug_core';
import { WifiNetworkErrorCodes } from '../constants/WifiNetworkErrorCodes';
import { WifiAccessPointSnapshot } from '../domain/model/WifiAccessPointSnapshot';
import { WifiLinkedInfoSnapshot } from '../domain/model/WifiLinkedInfoSnapshot';
import { LoadWifiOverviewUseCase } from '../domain/usecase/LoadWifiOverviewUseCase';
import { ObserveWifiStateUseCase, StartWifiScanUseCase } from '../domain/usecase/WifiNetworkUseCases';
import { WifiChannelCalculator } from '../domain/service/WifiChannelCalculator';

export class WifiAccessPointRowModel {
  readonly id: string;
  readonly ssid: string;
  readonly channel: number;
  readonly securityType: string;
  readonly rssi: number;

  constructor(id: string, ssid: string, channel: number, securityType: string, rssi: number) {
    this.id = id;
    this.ssid = ssid;
    this.channel = channel;
    this.securityType = securityType;
    this.rssi = rssi;
  }
}

@ObservedV2
export class WifiOverviewViewModel {
  @Trace hasLoaded: boolean = false;
  @Trace permissionGranted: boolean = false;
  @Trace peersMacGranted: boolean = false;
  @Trace permissionUiState: PermissionUiState | undefined = undefined;
  @Trace wifiActive: boolean = false;
  @Trace linkedConnected: boolean = false;
  @Trace linkedSsid: string = '';
  @Trace linkedBssid: string = '';
  @Trace linkedRssi: number = 0;
  @Trace linkedFrequency: number = 0;
  @Trace linkedLinkSpeed: number = 0;
  @Trace accessPoints: WifiAccessPointRowModel[] = [];
  @Trace scanInFlight: boolean = false;
  @Trace scanErrorCode: string = '';

  private readonly loadOverview: LoadWifiOverviewUseCase;
  private readonly startScan: StartWifiScanUseCase;
  private readonly observeWifi: ObserveWifiStateUseCase;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private lifecycleUnsubscribe: (() => void) | undefined;
  private refreshEpoch: number = 0;

  constructor(
    loadOverview: LoadWifiOverviewUseCase = new LoadWifiOverviewUseCase(),
    startScan: StartWifiScanUseCase = new StartWifiScanUseCase(),
    observeWifi: ObserveWifiStateUseCase = new ObserveWifiStateUseCase(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.loadOverview = loadOverview;
    this.startScan = startScan;
    this.observeWifi = observeWifi;
    this.ensurePermission = ensurePermission;
  }

  async onPageAppear(): Promise<void> {
    this.observeWifi.start(() => {
      void this.refresh();
    });
    this.lifecycleUnsubscribe = LifecycleCoordinator.getInstance().addReconcileCallback(async () => {
      await this.refresh();
    });
    await this.refresh();
  }

  onPageDisappear(): void {
    this.observeWifi.stop();
    if (this.lifecycleUnsubscribe !== undefined) {
      this.lifecycleUnsubscribe();
      this.lifecycleUnsubscribe = undefined;
    }
  }

  async refresh(): Promise<void> {
    const epoch = ++this.refreshEpoch;
    const loaded = await this.loadOverview.execute();
    if (epoch !== this.refreshEpoch) {
      return;
    }
    if (loaded.success && loaded.value !== undefined) {
      this.permissionGranted = loaded.value.wifiInfoGranted;
      this.peersMacGranted = loaded.value.peersMacGranted;
      this.wifiActive = loaded.value.snapshot.wifiActive;
      this.applyLinked(loaded.value.snapshot.linkedInfo);
      this.accessPoints = WifiOverviewViewModel.toRows(loaded.value.accessPoints);
    }
    await this.syncPermissionUiState();
    if (epoch === this.refreshEpoch) {
      this.hasLoaded = true;
    }
  }

  async requestPermission(): Promise<void> {
    await this.ensurePermission.execute(PermissionScenario.WIFI_INFO);
    await this.refresh();
  }

  async scan(): Promise<void> {
    if (!this.wifiActive || this.scanInFlight) {
      return;
    }
    this.scanInFlight = true;
    this.scanErrorCode = '';
    const scanned = await this.startScan.execute(true);
    if (!scanned.success) {
      const code = scanned.error !== undefined ? scanned.error.code : WifiNetworkErrorCodes.SCAN_LIMITED;
      if (code === WifiNetworkErrorCodes.NO_WIFI_INFO) {
        this.permissionGranted = false;
        await this.syncPermissionUiState();
      } else {
        this.scanErrorCode = code;
      }
    } else if (scanned.value !== undefined) {
      this.accessPoints = WifiOverviewViewModel.toRows(scanned.value);
    }
    await this.refresh();
    this.scanInFlight = false;
  }

  private applyLinked(linked: WifiLinkedInfoSnapshot | undefined): void {
    if (linked === undefined || !linked.connected) {
      this.linkedConnected = false;
      this.linkedSsid = '';
      this.linkedBssid = '';
      this.linkedRssi = 0;
      this.linkedFrequency = 0;
      this.linkedLinkSpeed = 0;
      return;
    }
    this.linkedConnected = true;
    this.linkedSsid = linked.ssid;
    this.linkedBssid = linked.bssid;
    this.linkedRssi = linked.rssi;
    this.linkedFrequency = linked.frequency;
    this.linkedLinkSpeed = linked.linkSpeed;
  }

  private static toRows(points: WifiAccessPointSnapshot[]): WifiAccessPointRowModel[] {
    const rows: WifiAccessPointRowModel[] = [];
    for (let i = 0; i < points.length; i++) {
      const point = points[i];
      const channel = point.channel > 0 ? point.channel : WifiChannelCalculator.fromFrequency(point.frequency);
      rows.push(new WifiAccessPointRowModel(point.id, point.ssid, channel, point.securityType, point.rssi));
    }
    return rows;
  }

  private async syncPermissionUiState(): Promise<void> {
    if (this.permissionGranted) {
      this.permissionUiState = undefined;
      return;
    }
    this.permissionUiState = await PermissionScenarioCoordinator.getInstance()
      .buildUiStateForScenario(PermissionScenario.WIFI_INFO);
  }
}
