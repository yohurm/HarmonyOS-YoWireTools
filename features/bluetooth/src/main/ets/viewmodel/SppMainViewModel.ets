import { Subscription } from 'common_core';
import {
  AbilityContextRegistry,
  BluetoothSettingsNavigator,
  LifecycleCoordinator
} from 'common_platform';
import {
  BluetoothConstants,
  BluetoothDevice,
  BluetoothRepository,
  BluetoothTransportType,
  ClassicDeviceMajorFilter,
  ClassicProfileCapability,
  ClassicScanFilter,
  ClassicScanPhase,
  DisconnectSppUseCase,
  ListSppSessionsUseCase,
  LoadBluetoothOverviewSnapshotUseCase,
  LoadPairedClassicDevicesUseCase,
  ObserveClassicDevicesUseCase,
  ObserveSppSessionsUseCase,
  SppSessionDescriptor,
  SppSessionKey,
  SppSessionLedger,
  SppLedgerPhase,
  StartClassicScanUseCase,
  StopClassicScanUseCase
} from 'yobluetooth';

export enum SppSegmentTab {
  /** 经典蓝牙 Inquiry 扫描轨（CLASSIC_SCAN），非 SPP 协议扫描。 */
  SCAN = 0,
  /** SPP 活动连接轨。 */
  ACTIVE = 1
}

/**
 * 经典扫描列表设备投影（architecture bluetooth/01 §6.1）。
 */
export class ClassicDeviceListItem {
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
  readonly profileCapabilitiesText: string;
  /** UI 徽章：本应用 SPP 已连，或系统 Profile 已连。 */
  readonly alreadyConnected: boolean;
  /** Ledger RESERVED / CONNECTING / RECONNECTING（正在连接 SPP）。 */
  readonly isConnecting: boolean;

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
    majorMinorClass: number = 0,
    profileCapabilitiesText: string = '',
    alreadyConnected: boolean = false,
    isConnecting: boolean = false
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
    this.profileCapabilitiesText = profileCapabilitiesText;
    this.alreadyConnected = alreadyConnected;
    this.isConnecting = isConnecting;
  }
}

/** SPP RFCOMM 活动会话投影（含 UUID / MAC / socket）。 */
export class SppActiveSessionItem {
  readonly sessionId: string;
  readonly displayName: string;
  readonly classicAddress: string;
  readonly uuidShortLabel: string;
  readonly stateLabel: string;
  readonly clientSocket: number;

  constructor(
    sessionId: string,
    displayName: string,
    classicAddress: string,
    uuidShortLabel: string,
    stateLabel: string,
    clientSocket: number = -1
  ) {
    this.sessionId = sessionId;
    this.displayName = displayName;
    this.classicAddress = classicAddress;
    this.uuidShortLabel = uuidShortLabel;
    this.stateLabel = stateLabel;
    this.clientSocket = clientSocket;
  }

  static fromDescriptor(descriptor: SppSessionDescriptor): SppActiveSessionItem {
    return new SppActiveSessionItem(
      descriptor.sessionId,
      descriptor.displayName,
      descriptor.classicAddress,
      descriptor.uuidShortLabel,
      descriptor.stateLabel,
      descriptor.clientSocket
    );
  }
}

/**
 * SPP 主页 ViewModel：经典扫描轨 + 多路 SPP 活动连接轨。
 */
@ObservedV2
export class SppMainViewModel {
  @Trace isLoading: boolean = true;
  @Trace ready: boolean = false;
  @Trace selectedSegment: SppSegmentTab = SppSegmentTab.SCAN;
  @Trace selectedIndex: number = 0;
  @Trace classicScanDevices: ClassicDeviceListItem[] = [];
  @Trace activeSessions: SppActiveSessionItem[] = [];
  @Trace isScanning: boolean = false;
  @Trace emptyTitle: ResourceStr = $r('app.string.bt_spp_empty_scan_title');
  @Trace emptyMessage: ResourceStr = $r('app.string.bt_spp_empty_scan_message');
  @Trace filterPanelExpanded: boolean = false;
  @Trace filterName: string = '';
  @Trace filterAddress: string = '';
  @Trace filterMinRssi: number = ClassicScanFilter.RSSI_DEFAULT;
  @Trace filterMajor: ClassicDeviceMajorFilter = ClassicDeviceMajorFilter.ALL;
  /** Default true: keep connected paired targets in scan list (not silent bonded-only). */
  @Trace filterIncludeConnectedPaired: boolean = true;
  @Trace filterActive: boolean = false;

  private readonly loadOverview: LoadBluetoothOverviewSnapshotUseCase;
  private readonly loadPaired: LoadPairedClassicDevicesUseCase;
  private readonly observeClassic: ObserveClassicDevicesUseCase;
  private readonly observeSessions: ObserveSppSessionsUseCase;
  private readonly startScan: StartClassicScanUseCase;
  private readonly stopScan: StopClassicScanUseCase;
  private readonly listSessions: ListSppSessionsUseCase;
  private readonly disconnectSpp: DisconnectSppUseCase;
  private readonly repository: BluetoothRepository;
  private classicSubscription: Subscription | undefined;
  private sessionsSubscription: Subscription | undefined;
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
    listSessions: ListSppSessionsUseCase = new ListSppSessionsUseCase(),
    observeSessions: ObserveSppSessionsUseCase = new ObserveSppSessionsUseCase(),
    disconnectSpp: DisconnectSppUseCase = new DisconnectSppUseCase(),
    repository: BluetoothRepository = BluetoothRepository.getInstance()
  ) {
    this.loadOverview = loadOverview;
    this.loadPaired = loadPaired;
    this.observeClassic = observeClassic;
    this.startScan = startScan;
    this.stopScan = stopScan;
    this.listSessions = listSessions;
    this.observeSessions = observeSessions;
    this.disconnectSpp = disconnectSpp;
    this.repository = repository;
  }

  async onPageAppear(): Promise<void> {
    this.classicSubscription = this.observeClassic.execute((devices: BluetoothDevice[]) => {
      this.applyScanDevices(devices);
    });
    this.sessionsSubscription = this.observeSessions.execute((descriptors: SppSessionDescriptor[]) => {
      this.applyActiveSessions(descriptors);
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
    if (this.sessionsSubscription !== undefined) {
      this.sessionsSubscription.dispose();
      this.sessionsSubscription = undefined;
    }
    if (this.scanRemainingSubscription !== undefined) {
      this.scanRemainingSubscription.dispose();
      this.scanRemainingSubscription = undefined;
    }
    this.filterPanelExpanded = false;
    this.repository.setClassicDeviceFilter(ClassicScanFilter.empty());
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
    if (segment === SppSegmentTab.ACTIVE) {
      this.filterPanelExpanded = false;
      this.refreshActiveSessions();
    }
    this.updateEmptyState();
  }

  toggleFilterPanel(): void {
    if (this.selectedSegment !== SppSegmentTab.SCAN) {
      this.filterPanelExpanded = false;
      return;
    }
    this.filterPanelExpanded = !this.filterPanelExpanded;
  }

  setFilterName(name: string): void {
    this.filterName = name;
    this.commitScanFilter();
  }

  setFilterAddress(address: string): void {
    this.filterAddress = address;
    this.commitScanFilter();
  }

  setFilterMinRssi(minRssi: number): void {
    this.filterMinRssi = minRssi;
    this.commitScanFilter();
  }

  setFilterMajor(major: ClassicDeviceMajorFilter): void {
    this.filterMajor = major;
    this.commitScanFilter();
  }

  setFilterIncludeConnectedPaired(include: boolean): void {
    this.filterIncludeConnectedPaired = include;
    this.commitScanFilter();
  }

  resetScanFilter(): void {
    this.filterName = '';
    this.filterAddress = '';
    this.filterMinRssi = ClassicScanFilter.RSSI_DEFAULT;
    this.filterMajor = ClassicDeviceMajorFilter.ALL;
    this.filterIncludeConnectedPaired = true;
    this.commitScanFilter();
  }

  async disconnectSession(sessionId: string): Promise<void> {
    await this.disconnectSpp.execute(sessionId);
    this.refreshActiveSessions();
    this.applyScanDevices(this.repository.listClassicDevices());
    this.updateEmptyState();
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
      this.classicScanDevices = [];
      return;
    }
    await this.stopScanIfNeeded();
    // Arch 01: preload paired classic candidates before Inquiry so list is not empty-only-scan.
    await this.loadPaired.execute();
    this.classicScanDevices = [];
    const started = await this.startScan.execute();
    if (started.success && started.value !== undefined) {
      this.scanSessionId = started.value;
      this.isScanning = true;
    } else {
      this.scanSessionId = '';
      this.isScanning = false;
    }
  }

  private refreshActiveSessions(): void {
    this.applyActiveSessions(this.listSessions.execute());
  }

  private applyActiveSessions(descriptors: SppSessionDescriptor[]): void {
    const items: SppActiveSessionItem[] = [];
    for (let i = 0; i < descriptors.length; i++) {
      items.push(SppActiveSessionItem.fromDescriptor(descriptors[i]));
    }
    this.activeSessions = items;
    // Refresh alreadyConnected flags on scan rows without restarting Inquiry.
    if (this.classicScanDevices.length > 0 || this.selectedSegment === SppSegmentTab.SCAN) {
      this.applyScanDevices(this.repository.listClassicDevices());
    }
    this.updateEmptyState();
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
    const items: ClassicDeviceListItem[] = [];
    for (let i = 0; i < devices.length; i++) {
      const device = devices[i];
      const resolved = this.repository.resolveClassicIdForSpp(device);
      const classicId = resolved.success && resolved.value !== undefined
        ? resolved.value
        : (device.classicDeviceId.length > 0 ? device.classicDeviceId : device.primaryDeviceId);
      const needsBridge = !resolved.success &&
        device.bleDeviceId.length > 0 &&
        device.classicDeviceId.length === 0;
      const sppLink = this.resolveSppSessionLink(classicId);
      const platformConnected = this.repository.isPlatformClassicConnected(classicId);
      // 徽章：系统 Profile 已连或本应用 SPP 已连均可标「已连接」
      const alreadyConnected = sppLink === 'connected' || platformConnected;
      const isConnecting = sppLink === 'connecting';
      const atSessionCap = this.isSessionCapReached();
      // 仅本应用 SPP 已连/连接中时禁用「连接」；系统 Profile 已连仍可发起 SPP
      const sppConnectable = resolved.success && sppLink === 'idle' && !atSessionCap;
      items.push(new ClassicDeviceListItem(
        device.primaryDeviceId,
        classicId,
        device.effectiveName.length > 0 ? device.effectiveName : '',
        classicId,
        this.formatRssi(device.rssi),
        device.paired,
        device.transport,
        this.formatTransportLabel(device.transport),
        sppConnectable,
        needsBridge,
        device.majorClass,
        device.majorMinorClass,
        ClassicProfileCapability.formatDisplayText(device.profileUuids),
        alreadyConnected,
        isConnecting
      ));
    }
    this.classicScanDevices = items;
    this.syncScanPhase();
  }

  /**
   * 仅本应用 SPP ledger 会话态（用于能否再点「连接」）。
   * 系统 Profile 已连不在此列为 connected，避免误禁 SPP。
   */
  private resolveSppSessionLink(classicDeviceId: string): 'idle' | 'connecting' | 'connected' {
    const phase = SppSessionLedger.getInstance().findPhaseByClassicId(classicDeviceId);
    if (phase === SppLedgerPhase.CONNECTED) {
      return 'connected';
    }
    if (phase === SppLedgerPhase.RESERVED ||
      phase === SppLedgerPhase.CONNECTING ||
      phase === SppLedgerPhase.RECONNECTING) {
      return 'connecting';
    }
    return 'idle';
  }

  /**
   * Scan-row "busy" for ledger keys (SPP connected/connecting only).
   */
  private hasAnyActiveLedgerKey(classicDeviceId: string): boolean {
    return this.resolveSppSessionLink(classicDeviceId) !== 'idle';
  }

  /** Cap ≥ SPP_MAX_SESSIONS disables new connects from the scan list. */
  private isSessionCapReached(): boolean {
    return SppSessionLedger.getInstance().getActiveCount() >= BluetoothConstants.SPP_MAX_SESSIONS;
  }

  private syncScanPhase(): void {
    this.isScanning = this.repository.getClassicScanPhase() === ClassicScanPhase.SCANNING;
    this.scanSessionId = this.repository.getActiveClassicScanSessionId();
    this.updateEmptyState();
  }

  private formatRssi(rssi: number): string {
    if (rssi === 0) {
      return '--';
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
    if (this.isScanning && this.classicScanDevices.length === 0) {
      this.emptyTitle = $r('app.string.bt_spp_empty_scanning_title');
      this.emptyMessage = $r('app.string.bt_spp_empty_scanning_message');
      return;
    }
    if (this.filterActive && this.classicScanDevices.length === 0) {
      this.emptyTitle = $r('app.string.bt_spp_empty_filter_title');
      this.emptyMessage = $r('app.string.bt_spp_empty_filter_message');
      return;
    }
    this.emptyTitle = $r('app.string.bt_spp_empty_scan_title');
    this.emptyMessage = $r('app.string.bt_spp_empty_scan_message');
  }

  private commitScanFilter(): void {
    const filter = new ClassicScanFilter(
      this.filterName,
      this.filterAddress,
      this.filterMinRssi,
      this.filterMajor,
      false,
      false,
      this.filterIncludeConnectedPaired
    );
    this.filterActive = filter.hasActiveConstraints();
    this.repository.setClassicDeviceFilter(filter);
  }
}
