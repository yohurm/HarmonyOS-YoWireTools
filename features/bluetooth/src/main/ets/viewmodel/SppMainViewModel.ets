import { Subscription } from 'common_core';
import {
  AbilityContextRegistry,
  BluetoothSettingsNavigator,
  LifecycleCoordinator
} from 'common_platform';
import { DebugSessionSummary } from 'feature_debug_core';
import { BluetoothDevice } from '../domain/model/BluetoothDevice';
import { ClassicScanPhase } from '../domain/model/ClassicScanPhase';
import {
  BluetoothTransportType
} from '../domain/model/BluetoothTransportType';
import { BluetoothRepository } from '../data/repository/BluetoothRepository';
import { LoadBluetoothOverviewSnapshotUseCase } from '../domain/usecase/overview/OverviewUseCases';
import {
  ListActiveSppSessionsUseCase,
  LoadPairedClassicDevicesUseCase,
  ObserveClassicDevicesUseCase,
  StartClassicScanUseCase,
  StopClassicScanUseCase
} from '../domain/usecase/classic/ClassicScanUseCases';

export enum SppSegmentTab {
  SCAN = 0,
  ACTIVE = 1
}

export class SppDeviceListItem {
  readonly primaryDeviceId: string;
  readonly classicDeviceId: string;
  readonly displayName: string;
  readonly address: string;
  readonly rssiText: string;
  readonly paired: boolean;
  readonly transport: BluetoothTransportType;
  readonly transportLabel: ResourceStr;
  readonly sppConnectable: boolean;
  readonly needsBridge: boolean;
  readonly majorClass: number;
  readonly majorMinorClass: number;

  constructor(
    primaryDeviceId: string,
    classicDeviceId: string,
    displayName: string,
    address: string,
    rssiText: string,
    paired: boolean,
    transport: BluetoothTransportType,
    transportLabel: ResourceStr,
    sppConnectable: boolean,
    needsBridge: boolean,
    majorClass: number = 0,
    majorMinorClass: number = 0
  ) {
    this.primaryDeviceId = primaryDeviceId;
    this.classicDeviceId = classicDeviceId;
    this.displayName = displayName;
    this.address = address;
    this.rssiText = rssiText;
    this.paired = paired;
    this.transport = transport;
    this.transportLabel = transportLabel;
    this.sppConnectable = sppConnectable;
    this.needsBridge = needsBridge;
    this.majorClass = majorClass;
    this.majorMinorClass = majorMinorClass;
  }
}

export class SppActiveSessionItem {
  readonly sessionId: string;
  readonly displayName: string;
  readonly stateLabel: string;

  constructor(sessionId: string, displayName: string, stateLabel: string) {
    this.sessionId = sessionId;
    this.displayName = displayName;
    this.stateLabel = stateLabel;
  }
}

@ObservedV2
export class SppMainViewModel {
  @Trace isLoading: boolean = true;
  @Trace ready: boolean = false;
  @Trace selectedSegment: SppSegmentTab = SppSegmentTab.SCAN;
  /** Bound to SegmentButton tab index (0=scan, 1=active). */
  @Trace selectedIndex: number = 0;
  @Trace scanDevices: SppDeviceListItem[] = [];
  @Trace activeSessions: SppActiveSessionItem[] = [];
  @Trace isScanning: boolean = false;
  @Trace emptyTitle: ResourceStr = $r('app.string.bt_spp_empty_scan_title');
  @Trace emptyMessage: ResourceStr = $r('app.string.bt_spp_empty_scan_message');

  private readonly loadOverview: LoadBluetoothOverviewSnapshotUseCase;
  private readonly loadPaired: LoadPairedClassicDevicesUseCase;
  private readonly observeClassic: ObserveClassicDevicesUseCase;
  private readonly startScan: StartClassicScanUseCase;
  private readonly stopScan: StopClassicScanUseCase;
  private readonly listActiveSessions: ListActiveSppSessionsUseCase;
  private readonly repository: BluetoothRepository;
  private classicSubscription: Subscription | undefined;
  private scanRemainingSubscription: Subscription | undefined;
  private lifecycleUnsubscribe: (() => void) | undefined;
  private scanSessionId: string = '';
  private hasLoadedOnce: boolean = false;

  constructor(
    loadOverview: LoadBluetoothOverviewSnapshotUseCase = new LoadBluetoothOverviewSnapshotUseCase(),
    loadPaired: LoadPairedClassicDevicesUseCase = new LoadPairedClassicDevicesUseCase(),
    observeClassic: ObserveClassicDevicesUseCase = new ObserveClassicDevicesUseCase(),
    startScan: StartClassicScanUseCase = new StartClassicScanUseCase(),
    stopScan: StopClassicScanUseCase = new StopClassicScanUseCase(),
    listActiveSessions: ListActiveSppSessionsUseCase = new ListActiveSppSessionsUseCase(),
    repository: BluetoothRepository = BluetoothRepository.getInstance()
  ) {
    this.loadOverview = loadOverview;
    this.loadPaired = loadPaired;
    this.observeClassic = observeClassic;
    this.startScan = startScan;
    this.stopScan = stopScan;
    this.listActiveSessions = listActiveSessions;
    this.repository = repository;
  }

  async onPageAppear(): Promise<void> {
    this.classicSubscription = this.observeClassic.execute((devices: BluetoothDevice[]) => {
      this.applyScanDevices(devices);
    });
    this.scanRemainingSubscription = this.repository.observeScanRemainingMs().subscribe((_remainingMs: number) => {
      this.syncScanPhase();
    });
    this.lifecycleUnsubscribe = LifecycleCoordinator.getInstance().addReconcileCallback(async () => {
      await this.refresh(false);
    });
    await this.refresh(true);
  }

  async onPageDisappear(): Promise<void> {
    if (this.lifecycleUnsubscribe !== undefined) {
      this.lifecycleUnsubscribe();
      this.lifecycleUnsubscribe = undefined;
    }
    if (this.classicSubscription !== undefined) {
      this.classicSubscription.dispose();
      this.classicSubscription = undefined;
    }
    if (this.scanRemainingSubscription !== undefined) {
      this.scanRemainingSubscription.dispose();
      this.scanRemainingSubscription = undefined;
    }
    await this.stopScanIfNeeded();
  }

  selectSegmentByIndex(index: number): void {
    const normalized: number = index === 1 ? 1 : 0;
    const segment: SppSegmentTab =
      normalized === 1 ? SppSegmentTab.ACTIVE : SppSegmentTab.SCAN;
    if (this.selectedIndex === normalized && this.selectedSegment === segment) {
      return;
    }
    this.selectedIndex = normalized;
    this.selectSegment(segment);
  }

  selectSegment(segment: SppSegmentTab): void {
    if (this.selectedSegment === segment) {
      this.selectedIndex = segment === SppSegmentTab.ACTIVE ? 1 : 0;
      return;
    }
    this.selectedSegment = segment;
    this.selectedIndex = segment === SppSegmentTab.ACTIVE ? 1 : 0;
    this.updateEmptyState();
    if (segment === SppSegmentTab.ACTIVE) {
      this.refreshActiveSessions();
    }
  }

  async refresh(showLoading: boolean = false): Promise<void> {
    if (showLoading || !this.hasLoadedOnce) {
      this.isLoading = true;
    }
    const overview = await this.loadOverview.execute();
    if (overview.success && overview.value !== undefined) {
      const snapshot = overview.value;
      this.ready = snapshot.permissionGranted && snapshot.adapter.enabled && snapshot.classicSupported;
      this.isScanning = snapshot.classicScanPhase === ClassicScanPhase.SCANNING;
      this.scanSessionId = this.repository.getActiveClassicScanSessionId();
    }
    if (this.selectedSegment === SppSegmentTab.SCAN) {
      await this.refreshScanSegment();
    } else {
      this.refreshActiveSessions();
    }
    this.updateEmptyState();
    this.hasLoadedOnce = true;
    this.isLoading = false;
  }

  async openBluetoothSettings(): Promise<void> {
    const context = AbilityContextRegistry.getInstance().get();
    if (context !== undefined) {
      await BluetoothSettingsNavigator.openBluetoothSettings(context);
    }
  }

  private async refreshScanSegment(): Promise<void> {
    if (!this.ready) {
      this.scanDevices = [];
      return;
    }
    const paired = await this.loadPaired.execute();
    if (paired.success && paired.value !== undefined) {
      this.applyScanDevices(paired.value);
    }
    await this.restartClassicScan();
  }

  private async restartClassicScan(): Promise<void> {
    if (this.isScanning || this.scanSessionId.length > 0) {
      await this.stopScan.execute(this.scanSessionId);
      this.scanSessionId = '';
      this.isScanning = false;
    }
    const started = await this.startScan.execute();
    if (started.success && started.value !== undefined) {
      this.scanSessionId = started.value;
      this.isScanning = true;
    }
  }

  private refreshActiveSessions(): void {
    const summaries: DebugSessionSummary[] = this.listActiveSessions.execute();
    const items: SppActiveSessionItem[] = [];
    for (let i = 0; i < summaries.length; i++) {
      const summary = summaries[i];
      items.push(new SppActiveSessionItem(summary.id, summary.displayName, `${summary.state}`));
    }
    this.activeSessions = items;
  }

  private async stopScanIfNeeded(): Promise<void> {
    if (!this.isScanning && this.scanSessionId.length === 0) {
      return;
    }
    await this.stopScan.execute(this.scanSessionId);
    this.scanSessionId = '';
    this.isScanning = false;
  }

  private applyScanDevices(devices: BluetoothDevice[]): void {
    const items: SppDeviceListItem[] = [];
    for (let i = 0; i < devices.length; i++) {
      const device = devices[i];
      const resolved = this.repository.resolveClassicIdForSpp(device);
      const classicId = resolved.success && resolved.value !== undefined
        ? resolved.value
        : (device.classicDeviceId.length > 0 ? device.classicDeviceId : device.primaryDeviceId);
      const needsBridge = !resolved.success &&
        device.bleDeviceId.length > 0 &&
        device.classicDeviceId.length === 0;
      items.push(new SppDeviceListItem(
        device.primaryDeviceId,
        classicId,
        device.effectiveName.length > 0 ? device.effectiveName : '',
        classicId,
        this.formatRssi(device.rssi),
        device.paired,
        device.transport,
        this.formatTransportLabel(device.transport),
        resolved.success,
        needsBridge,
        device.majorClass,
        device.majorMinorClass
      ));
    }
    this.scanDevices = items;
    this.syncScanPhase();
  }

  private syncScanPhase(): void {
    this.isScanning = this.repository.getClassicScanPhase() === ClassicScanPhase.SCANNING;
    this.scanSessionId = this.repository.getActiveClassicScanSessionId();
    this.updateEmptyState();
  }

  private formatRssi(rssi: number): string {
    if (rssi === 0) {
      return '';
    }
    return `${rssi} dBm`;
  }

  private formatTransportLabel(transport: BluetoothTransportType): ResourceStr {
    if (transport === BluetoothTransportType.BR_EDR) {
      return $r('app.string.bt_transport_classic');
    }
    if (transport === BluetoothTransportType.DUAL) {
      return $r('app.string.bt_transport_dual');
    }
    if (transport === BluetoothTransportType.LE) {
      return $r('app.string.bt_transport_ble');
    }
    return $r('app.string.bt_transport_unknown');
  }

  private updateEmptyState(): void {
    if (!this.ready) {
      this.emptyTitle = $r('app.string.bt_spp_empty_not_ready_title');
      this.emptyMessage = $r('app.string.bt_spp_empty_not_ready_message');
      return;
    }
    if (this.selectedSegment === SppSegmentTab.ACTIVE) {
      this.emptyTitle = $r('app.string.bt_spp_empty_active_title');
      this.emptyMessage = $r('app.string.bt_spp_empty_active_message');
      return;
    }
    if (this.isScanning && this.scanDevices.length === 0) {
      this.emptyTitle = $r('app.string.bt_spp_empty_scanning_title');
      this.emptyMessage = $r('app.string.bt_spp_empty_scanning_message');
      return;
    }
    this.emptyTitle = $r('app.string.bt_spp_empty_scan_title');
    this.emptyMessage = $r('app.string.bt_spp_empty_scan_message');
  }
}
