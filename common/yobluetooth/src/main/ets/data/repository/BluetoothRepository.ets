import { DeviceFavoriteRecord } from 'common_storage';
import { Observable, Result, ResultError } from 'common_core';
import { ModuleType, ProtocolType, SessionRuntimeStore } from 'debug_core';
import { ClassicBluetoothDataSource, PlatformDiscoveryPayload } from '../datasource/platform/ClassicBluetoothDataSource';
import { PlatformConnectedClassicSource } from '../datasource/platform/PlatformConnectedClassicSource';
import { BleDiscoveryPayload, BleScannerDataSource } from '../datasource/platform/BleScannerDataSource';
import { BluetoothIdentityDataSource } from '../datasource/platform/BluetoothIdentityDataSource';
import { GattClientDataSource } from '../datasource/platform/GattClientDataSource';
import { BluetoothDeviceMapper, PlatformPairedSnapshot } from '../mapper/BluetoothDeviceMapper';
import {
  BluetoothAdapterSnapshot,
  BluetoothDevice,
  BluetoothDeviceDraft,
  BluetoothOverviewSnapshot
} from '../../domain/model/BluetoothDevice';
import {
  BluetoothTransportPolicy,
  BluetoothListRail,
  BluetoothTransportType
} from '../../domain/model/BluetoothTransportType';
import { ClassicScanPhase } from '../../domain/model/ClassicScanPhase';
import { BleScanPhase } from '../../domain/model/BleScanPhase';
import { BleScanFilter } from '../../domain/model/BleScanFilter';
import { ClassicScanFilter } from '../../domain/model/ClassicScanFilter';
import { DiscoverySource } from '../../domain/model/DiscoverySource';
import { ScanResultMerger } from '../../domain/service/ScanResultMerger';
import { ClassicScanVisibilityPolicy, ActiveSppSessionRef, ConnectedSppLedgerRef } from '../../domain/service/ClassicScanVisibilityPolicy';
import { ClassicScanKeepAliveCollector } from '../../domain/service/ClassicScanKeepAliveCollector';
import { ClassicKeepAliveSnapshot, ClassicConnectedSnapshot } from '../../domain/model/ClassicConnectedSnapshot';
import { SppSessionLedger } from '../../domain/service/spp/SppSessionLedger';
import { PairingEvent, PairingState } from '../../domain/model/PairingState';
import { ClassicScanTimer } from '../../domain/service/ClassicScanTimer';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';
import { ClassicDiscoveryAdmission } from '../../domain/service/ClassicDiscoveryAdmission';
import { GattServiceTreeSnapshot, GattClientState } from '../../domain/model/GattServiceTree';
import { GattPlatformMapper } from '../mapper/GattPlatformMapper';
import { GattCharacteristicChangeEvent, GattCharacteristicRef, GattDescriptorRef } from '../../domain/model/GattCharacteristicRef';
import { BleAdvertisingPacket, BleManufacturerDataEntry } from '../../domain/model/BleAdvertisingPacket';
import { BluetoothRecentConnection } from '../../domain/model/BluetoothRecentConnection';
import { BleManufacturerMaskMatcher } from '../../domain/service/BleManufacturerMaskMatcher';
import { BluetoothRepositoryContract } from '../../domain/repository/BluetoothRepositoryContract';
import { SppConnectParams } from '../../domain/model/SppConnectParams';
import { SppTransportSession } from '../transport/SppTransportSession';
import { DeviceIdentity } from '../../domain/model/DeviceIdentity';
import { DeviceRegistry } from '../../domain/service/registry/DeviceRegistry';
import { BluetoothConstants } from '../../constants/BluetoothConstants';
import { YoLog, YoLogger } from 'yolog';
import { BtLogTag } from '../../observability/BtLogTag';
import { SppSessionKey } from '../../domain/model/SppSessionKey';

const scanLogger: YoLogger = YoLog.tag(BtLogTag.SCAN);

/**
 * Bluetooth repository facade per architecture 02-搂6.1.
 */
export class BluetoothRepository implements BluetoothRepositoryContract {
  private static instance: BluetoothRepository | undefined;
  private readonly classicDataSource: ClassicBluetoothDataSource;
  private readonly bleDataSource: BleScannerDataSource;
  private readonly identityDataSource: BluetoothIdentityDataSource;
  private readonly platformConnected: PlatformConnectedClassicSource;
  private readonly classicMerger: ScanResultMerger = new ScanResultMerger();
  private readonly bleMerger: ScanResultMerger = new ScanResultMerger();
  /** 已配对经典候选缓存：供 SPP 解析 / 连接态补全，不直接 seed 扫描列表。 */
  private readonly pairedClassicCache: Map<string, BluetoothDevice> = new Map();
  private readonly bleAdvertisingMap: Map<string, BleAdvertisingPacket> = new Map();
  private readonly gattClients: Map<string, GattClientDataSource> = new Map();
  /** Application-layer BLE connection slots (GATT browser / UART / GATT serial). */
  private bleConnectionCount: number = 0;
  private readonly gattTrees: Map<string, GattServiceTreeSnapshot> = new Map();
  private readonly classicDevicesObservable: Observable<BluetoothDevice[]>;
  private readonly bleDevicesObservable: Observable<BluetoothDevice[]>;
  private readonly scanRemainingObservable: Observable<number>;
  private readonly gattTreeObservable: Observable<GattServiceTreeSnapshot>;
  private classicScanPhase: ClassicScanPhase = ClassicScanPhase.IDLE;
  private bleScanPhase: BleScanPhase = BleScanPhase.IDLE;
  private activeClassicScanSessionId: string = '';
  private activeBleScanSessionId: string = '';
  private favoritesCache: DeviceFavoriteRecord[] = [];
  private readonly scanTimer: ClassicScanTimer = new ClassicScanTimer();
  private scanTimeoutHandler: (() => void) | undefined;
  private classicFilter: ClassicScanFilter = ClassicScanFilter.empty();
  private activeBleScanFilter: BleScanFilter = new BleScanFilter();
  private serviceStopped: boolean = false;
  private readonly serviceStoppedObservable: Observable<boolean>;

  private constructor(
    classicDataSource: ClassicBluetoothDataSource = ClassicBluetoothDataSource.getInstance(),
    bleDataSource: BleScannerDataSource = BleScannerDataSource.getInstance(),
    identityDataSource: BluetoothIdentityDataSource = BluetoothIdentityDataSource.getInstance(),
    platformConnected: PlatformConnectedClassicSource = PlatformConnectedClassicSource.getInstance()
  ) {
    this.classicDataSource = classicDataSource;
    this.bleDataSource = bleDataSource;
    this.identityDataSource = identityDataSource;
    this.platformConnected = platformConnected;
    this.classicDevicesObservable = new Observable<BluetoothDevice[]>([]);
    this.bleDevicesObservable = new Observable<BluetoothDevice[]>([]);
    this.scanRemainingObservable = new Observable<number>(0);
    this.serviceStoppedObservable = new Observable<boolean>(false);
    this.gattTreeObservable = new Observable<GattServiceTreeSnapshot>(
      new GattServiceTreeSnapshot('', '', 23, [], GattClientState.IDLE)
    );
    void this.identityDataSource.loadRecentFromStore();
    this.platformConnected.setOnChanged(() => {
      this.publishClassicDevices();
    });
    this.platformConnected.watch();
  }

  getAdapterState(): Promise<Result<BluetoothAdapterSnapshot>> {
    return this.loadAdapterState();
  }

  startClassicScan(sessionId: string): Promise<Result<void>> {
    return this.startClassicDiscovery(sessionId);
  }

  stopClassicScan(scanId: string): Promise<Result<void>> {
    return this.stopClassicDiscovery();
  }

  createSppTransport(sessionId: string, _params: SppConnectParams): SppTransportSession {
    return new SppTransportSession(sessionId);
  }

  getActiveSppSessionCount(): number {
    return SppSessionLedger.getInstance().getActiveCount();
  }

  canOpenSppSession(): boolean {
    return SppSessionLedger.getInstance().getActiveCount() < BluetoothConstants.SPP_MAX_SESSIONS;
  }

  /**
   * 刷新已配对经典缓存（BR_EDR | DUAL），不写入扫描 merger。
   * LE-only 仍排除（architecture bluetooth/00）。
   */
  async refreshPairedClassicCache(): Promise<Result<BluetoothDevice[]>> {
    const paired = await this.classicDataSource.getPairedDeviceSnapshots();
    if (!paired.success || paired.value === undefined) {
      return Result.fail(paired.error ?? new ResultError(BluetoothErrorCodes.CLASSIC_UNAVAILABLE, 'paired failed'));
    }
    await this.refreshFavorites();
    this.reconcileDualModeFromSnapshots(paired.value);
    this.pairedClassicCache.clear();
    const devices: BluetoothDevice[] = [];
    for (let i = 0; i < paired.value.length; i++) {
      const snapshot: PlatformPairedSnapshot = paired.value[i];
      const admitted = await this.admitPairedClassicSnapshot(snapshot);
      if (!admitted.admit) {
        continue;
      }
      let mapped = snapshot;
      if (admitted.resolvedTransport !== snapshot.transport) {
        mapped = new PlatformPairedSnapshot(
          snapshot.address,
          snapshot.deviceName,
          admitted.resolvedTransport,
          snapshot.deviceClassCod,
          snapshot.majorClass,
          snapshot.majorMinorClass
        );
      }
      let device = BluetoothDeviceMapper.fromPairedSnapshot(mapped, BluetoothListRail.CLASSIC_SCAN);
      device = this.applyFavoriteMeta(device);
      device = await this.attachProfileUuids(device, admitted.profileUuids);
      devices.push(device);
      this.pairedClassicCache.set(device.primaryDeviceId, device);
    }
    const pairedNames: string[] = [];
    for (let i = 0; i < devices.length; i++) {
      pairedNames.push(BluetoothRepository.maskDeviceLabel(devices[i]));
    }
    scanLogger.info(`paired_classic_cache size=${devices.length} names=[${pairedNames.join(',')}]`);
    return Result.ok(devices);
  }

  /** 兼容旧调用方：仅刷新配对缓存，不 seed 扫描列表。 */
  async loadPairedClassicCandidates(): Promise<Result<BluetoothDevice[]>> {
    return this.refreshPairedClassicCache();
  }

  /** 新一轮 Inquiry 前清空实时发现列表（不预置静默配对项）。 */
  prepareClassicScanList(): void {
    this.classicMerger.clear();
    this.publishClassicDevices();
  }

  async loadPairedBleCandidates(): Promise<Result<BluetoothDevice[]>> {
    const paired = await this.classicDataSource.getPairedDeviceSnapshots();
    if (!paired.success || paired.value === undefined) {
      return Result.fail(paired.error ?? new ResultError(BluetoothErrorCodes.CLASSIC_UNAVAILABLE, 'paired failed'));
    }
    await this.refreshFavorites();
    this.reconcileDualModeFromSnapshots(paired.value);
    const devices: BluetoothDevice[] = [];
    for (let i = 0; i < paired.value.length; i++) {
      const snapshot = paired.value[i];
      if (snapshot.transport === BluetoothTransportType.BR_EDR) {
        continue;
      }
      if (!BluetoothTransportPolicy.isBleCandidate(snapshot.transport) &&
        snapshot.transport !== BluetoothTransportType.UNKNOWN) {
        continue;
      }
      let device = BluetoothDeviceMapper.fromPairedSnapshot(snapshot, BluetoothListRail.BLE_SCAN);
      device = this.applyFavoriteMeta(device);
      devices.push(device);
    }
    this.bleMerger.upsertAll(devices);
    this.publishBleDevices();
    return Result.ok(this.listBleDevices());
  }

  getRemoteDeviceTransport(deviceId: string): Result<BluetoothTransportType> {
    return this.classicDataSource.getRemoteDeviceTransport(deviceId);
  }

  linkDualModeIdentity(classicDeviceId: string, bleDeviceId: string, displayNameHint: string = ''): DeviceIdentity {
    return this.identityDataSource.linkDualModeIdentity(classicDeviceId, bleDeviceId, displayNameHint);
  }

  resolveClassicIdForSpp(device: BluetoothDevice): Result<string> {
    if (device.classicDeviceId.length > 0 &&
      BluetoothTransportPolicy.isClassicCandidate(device.transport)) {
      return Result.ok(device.classicDeviceId);
    }
    if (device.transport === BluetoothTransportType.LE) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.SPP_TARGET_LE_ONLY,
        'LE-only device cannot use SPP'
      ));
    }
    if (device.bleDeviceId.length > 0 && device.classicDeviceId.length === 0) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.SPP_BLE_ADDRESS_REJECTED,
        'BLE address cannot be used for sppConnect; bridge dual-mode first'
      ));
    }
    if (device.primaryDeviceId.length > 0 &&
      device.listRail === BluetoothListRail.CLASSIC_SCAN) {
      return Result.ok(device.primaryDeviceId);
    }
    return Result.fail(new ResultError(
      BluetoothErrorCodes.SPP_BLE_ADDRESS_REJECTED,
      'No classic address resolved for SPP'
    ));
  }

  static getInstance(): BluetoothRepository {
    if (BluetoothRepository.instance === undefined) {
      BluetoothRepository.instance = new BluetoothRepository();
    }
    return BluetoothRepository.instance;
  }

  getClassicScanPhase(): ClassicScanPhase {
    return this.classicScanPhase;
  }

  getBleScanPhase(): BleScanPhase {
    return this.bleScanPhase;
  }

  getActiveClassicScanSessionId(): string {
    return this.activeClassicScanSessionId;
  }

  observeClassicDevices(): Observable<BluetoothDevice[]> {
    return this.classicDevicesObservable;
  }

  observeBleDevices(): Observable<BluetoothDevice[]> {
    return this.bleDevicesObservable;
  }

  observeScanRemainingMs(): Observable<number> {
    return this.scanRemainingObservable;
  }

  observeGattTree(): Observable<GattServiceTreeSnapshot> {
    return this.gattTreeObservable;
  }

  observeAdapterState(): Observable<BluetoothAdapterSnapshot> {
    return this.classicDataSource.observeAdapterState();
  }

  onAdapterStateChange(listener: (snapshot: BluetoothAdapterSnapshot) => void): void {
    this.classicDataSource.onAdapterStateChange(listener);
  }

  offAdapterStateChange(): void {
    this.classicDataSource.offAdapterStateChange();
  }

  async loadAdapterState() {
    return this.classicDataSource.getAdapterState();
  }

  async loadOverview(permissionGranted: boolean): Promise<BluetoothOverviewSnapshot> {
    await this.refreshFavorites();
    const adapter = await this.loadAdapterState();
    const adapterSnapshot = adapter.success && adapter.value !== undefined
      ? adapter.value
      : new BluetoothAdapterSnapshot(false, 0, 'Unknown');
    const warnings: string[] = [];
    if (!adapterSnapshot.enabled) {
      warnings.push('Bluetooth adapter is off');
    }
    if (!permissionGranted) {
      warnings.push('Bluetooth permission denied');
    }
    const activeSessions = SessionRuntimeStore.getInstance().listActiveSummaries()
      .filter((item) => item.module === ModuleType.BLUETOOTH).length;
    return new BluetoothOverviewSnapshot(
      adapterSnapshot,
      permissionGranted,
      true,
      true,
      this.pairedClassicCache.size > 0 ?
        this.pairedClassicCache.size :
        this.classicMerger.listSorted().filter((d: BluetoothDevice) =>
          d.paired && BluetoothTransportPolicy.admitClassicPaired(d.transport)).length,
      this.favoritesCache.length,
      this.classicScanPhase,
      this.bleScanPhase,
      this.classicMerger.listSorted().length,
      this.bleMerger.listSorted().length,
      activeSessions,
      warnings
    );
  }

  listRecentConnections(): BluetoothRecentConnection[] {
    return DeviceRegistry.getInstance().listRecentConnections();
  }

  recordRecentConnection(deviceId: string, displayName: string, protocol: string): void {
    DeviceRegistry.getInstance().recordRecentConnection(deviceId, displayName, protocol);
  }

  getActiveGattSessionCount(): number {
    return this.bleConnectionCount;
  }

  canOpenGattSession(): boolean {
    return this.bleConnectionCount < BluetoothConstants.GATT_MAX_SESSIONS;
  }

  tryReserveBleConnection(): boolean {
    if (this.bleConnectionCount >= BluetoothConstants.GATT_MAX_SESSIONS) {
      return false;
    }
    this.bleConnectionCount++;
    return true;
  }

  releaseBleConnection(): void {
    if (this.bleConnectionCount > 0) {
      this.bleConnectionCount--;
    }
  }

  async refreshFavorites(): Promise<Result<DeviceFavoriteRecord[]>> {
    const listed = await this.identityDataSource.listFavorites();
    if (listed.success && listed.value !== undefined) {
      this.favoritesCache = listed.value;
    }
    return listed;
  }

  setClassicDeviceFilter(filter: ClassicScanFilter): void {
    this.classicFilter = filter;
    this.publishClassicDevices();
  }

  getClassicDeviceFilter(): ClassicScanFilter {
    return this.classicFilter;
  }

  async enableBluetooth(): Promise<Result<void>> {
    const result = await this.classicDataSource.enableBluetooth();
    this.absorbPlatformFailure(result);
    return result;
  }

  async disableBluetooth(): Promise<Result<void>> {
    const result = await this.classicDataSource.disableBluetooth();
    this.absorbPlatformFailure(result);
    return result;
  }

  async startClassicDiscovery(sessionId: string, onTimeout?: () => void): Promise<Result<void>> {
    const discovering = await this.classicDataSource.isBluetoothDiscovering();
    const platformDiscovering = discovering.success && discovering.value === true;
    const admission = ClassicDiscoveryAdmission.admit(this.classicScanPhase, platformDiscovering);
    if (!admission.success) {
      return admission;
    }
    await this.refreshPairedClassicCache();
    this.prepareClassicScanList();
    this.classicScanPhase = ClassicScanPhase.SCANNING;
    this.activeClassicScanSessionId = sessionId;
    this.classicDataSource.onDiscoveryResult((payload: PlatformDiscoveryPayload) => {
      this.onClassicDiscovered(payload);
    });
    const started = await this.classicDataSource.startBluetoothDiscovery();
    if (!started.success) {
      this.classicScanPhase = ClassicScanPhase.FAILED;
      this.classicDataSource.offDiscoveryResult();
      this.absorbPlatformFailure(started);
      return Result.fail(started.error ?? new ResultError(BluetoothErrorCodes.SCAN_RESOURCE_FAILED, 'start failed'));
    }
    this.scanTimeoutHandler = onTimeout;
    this.scanTimer.start(() => {
      void this.handleClassicScanTimeout();
    }, (remainingMs: number) => {
      this.scanRemainingObservable.next(remainingMs);
    });
    return Result.ok(undefined);
  }

  private async handleClassicScanTimeout(): Promise<void> {
    if (this.classicScanPhase !== ClassicScanPhase.SCANNING) {
      return;
    }
    await this.stopClassicDiscovery();
    this.classicScanPhase = ClassicScanPhase.COMPLETED;
    if (this.scanTimeoutHandler !== undefined) {
      this.scanTimeoutHandler();
    }
  }

  async stopClassicDiscovery(): Promise<Result<void>> {
    this.scanTimer.stop();
    this.scanRemainingObservable.next(0);
    if (this.classicScanPhase !== ClassicScanPhase.SCANNING &&
      this.classicScanPhase !== ClassicScanPhase.STOPPING) {
      return Result.ok(undefined);
    }
    this.classicScanPhase = ClassicScanPhase.STOPPING;
    const stopped = await this.classicDataSource.stopBluetoothDiscovery();
    this.classicDataSource.offDiscoveryResult();
    this.classicScanPhase = ClassicScanPhase.COMPLETED;
    this.activeClassicScanSessionId = '';
    if (!stopped.success) {
      return Result.fail(stopped.error ?? new ResultError(BluetoothErrorCodes.CLASSIC_UNAVAILABLE, 'stop failed'));
    }
    return Result.ok(undefined);
  }

  async ensureClassicDiscoveryStopped(): Promise<Result<void>> {
    return this.stopClassicDiscovery();
  }

  async pairDevice(deviceId: string): Promise<Result<void>> {
    return this.classicDataSource.pairDevice(deviceId);
  }

  async getPairState(deviceId: string): Promise<Result<PairingState>> {
    return this.classicDataSource.getPairState(deviceId);
  }

  async getRemoteProfileUuids(deviceId: string): Promise<Result<string[]>> {
    return this.classicDataSource.getRemoteProfileUuids(deviceId);
  }

  onBondStateChange(listener: (event: PairingEvent) => void): void {
    this.classicDataSource.onBondStateChange(listener);
  }

  offBondStateChange(): void {
    this.classicDataSource.offBondStateChange();
  }

  applyPairingEvent(event: PairingEvent): void {
    const devices = this.classicMerger.listSorted();
    for (let i = 0; i < devices.length; i++) {
      const device = devices[i];
      if (device.primaryDeviceId === event.address ||
        device.classicDeviceId === event.address ||
        device.bleDeviceId === event.address) {
        this.classicMerger.merge(device.withPairState(event.state, event.state === PairingState.PAIRED));
      }
    }
    const bleDevices = this.bleMerger.listSorted();
    for (let i = 0; i < bleDevices.length; i++) {
      const device = bleDevices[i];
      if (device.primaryDeviceId === event.address ||
        device.classicDeviceId === event.address ||
        device.bleDeviceId === event.address) {
        this.bleMerger.merge(device.withPairState(event.state, event.state === PairingState.PAIRED));
      }
    }
    this.publishClassicDevices();
    this.publishBleDevices();
  }

  startBleScan(sessionId: string, filter: BleScanFilter = new BleScanFilter()): Result<void> {
    if (this.bleScanPhase === BleScanPhase.SCANNING) {
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_SCAN_FAILED, 'BLE scan already running'));
    }
    this.bleScanPhase = this.bleDataSource.usesScannerApi()
      ? BleScanPhase.SCANNING
      : BleScanPhase.SCANNING;
    this.activeBleScanSessionId = sessionId;
    this.activeBleScanFilter = filter;
    this.bleDataSource.onDeviceFind((payload: BleDiscoveryPayload) => {
      void this.onBleDiscovered(payload, filter);
    });
    const started = this.bleDataSource.startScan(filter);
    if (!started.success) {
      this.bleScanPhase = BleScanPhase.FAILED;
      this.bleDataSource.offDeviceFind();
      return started;
    }
    return Result.ok(undefined);
  }

  bleRssiThresholdAvailable(): boolean {
    return this.bleDataSource.rssiThresholdAvailable();
  }

  bleParallelScanAvailable(): boolean {
    return this.bleDataSource.parallelScanAvailable();
  }

  startExtraBleScan(filter: BleScanFilter): Result<void> {
    return this.bleDataSource.startExtraScan(filter);
  }

  stopExtraBleScan(): Result<void> {
    return this.bleDataSource.stopExtraScan();
  }

  gattCurrentMtu(sessionId: string): number {
    const client = this.gattClients.get(sessionId);
    if (client === undefined) {
      return BluetoothConstants.BLE_DEFAULT_MTU;
    }
    return client.currentMtu();
  }

  gattMtuPending(sessionId: string): boolean {
    const client = this.gattClients.get(sessionId);
    return client !== undefined && client.isMtuPending();
  }

  stopBleScan(): Result<void> {
    if (this.bleScanPhase !== BleScanPhase.SCANNING) {
      return Result.ok(undefined);
    }
    this.bleScanPhase = BleScanPhase.STOPPING;
    const stopped = this.bleDataSource.stopScan();
    this.bleScanPhase = BleScanPhase.COMPLETED;
    this.activeBleScanSessionId = '';
    return stopped;
  }

  getBleAdvertising(bleDeviceId: string): BleAdvertisingPacket | undefined {
    return this.bleAdvertisingMap.get(bleDeviceId);
  }

  createGattClient(sessionId: string, bleDeviceId: string): GattClientDataSource {
    const existing = this.gattClients.get(sessionId);
    if (existing !== undefined) {
      existing.release();
    }
    const client = new GattClientDataSource();
    client.createClient(bleDeviceId);
    this.gattClients.set(sessionId, client);
    return client;
  }

  getGattClient(sessionId: string): GattClientDataSource | undefined {
    return this.gattClients.get(sessionId);
  }

  async discoverGattServices(sessionId: string, bleDeviceId: string, mtu: number = 23): Promise<Result<GattServiceTreeSnapshot>> {
    const client = this.gattClients.get(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'GATT client missing'));
    }
    const services = await client.discoverServices();
    if (!services.success || services.value === undefined) {
      return Result.fail(services.error ?? new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'discover failed'));
    }
    const tree = GattPlatformMapper.fromPlatformServices(services.value);
    const snapshot = new GattServiceTreeSnapshot(sessionId, bleDeviceId, mtu, tree, GattClientState.READY);
    this.gattTrees.set(sessionId, snapshot);
    this.gattTreeObservable.next(snapshot);
    return Result.ok(snapshot);
  }

  getGattTree(sessionId: string): GattServiceTreeSnapshot | undefined {
    return this.gattTrees.get(sessionId);
  }

  releaseGattClient(sessionId: string): void {
    const client = this.gattClients.get(sessionId);
    if (client !== undefined) {
      client.release();
      this.gattClients.delete(sessionId);
    }
    this.gattTrees.delete(sessionId);
  }

  async connectGattBrowser(sessionId: string, bleDeviceId: string, timeoutMs: number = 15000): Promise<Result<void>> {
    this.createGattClient(sessionId, bleDeviceId);
    const client = this.gattClients.get(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_CONNECT_FAILED, 'GATT client missing'));
    }
    return client.waitForConnected(timeoutMs);
  }

  findGattCharacteristicRef(
    sessionId: string,
    serviceUuid: string,
    characteristicUuid: string
  ): GattCharacteristicRef | undefined {
    const client = this.gattClients.get(sessionId);
    if (client === undefined) {
      return undefined;
    }
    const characteristic = client.findCharacteristic(serviceUuid, characteristicUuid);
    if (characteristic === undefined) {
      return undefined;
    }
    return GattPlatformMapper.toCharacteristicRef(characteristic);
  }

  findGattDescriptorRef(
    sessionId: string,
    serviceUuid: string,
    characteristicUuid: string,
    descriptorUuid: string
  ): GattDescriptorRef | undefined {
    const client = this.gattClients.get(sessionId);
    if (client === undefined) {
      return undefined;
    }
    const descriptor = client.findDescriptor(serviceUuid, characteristicUuid, descriptorUuid);
    if (descriptor === undefined) {
      return undefined;
    }
    return GattPlatformMapper.toDescriptorRef(descriptor);
  }

  subscribeGattCharacteristicChanges(
    sessionId: string,
    listener: (event: GattCharacteristicChangeEvent) => void
  ): Result<void> {
    const client = this.gattClients.get(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.NOT_CONNECTED, 'GATT not connected'));
    }
    return client.onCharacteristicChange((characteristic) => {
      if (characteristic.characteristicValue === undefined) {
        return;
      }
      listener(new GattCharacteristicChangeEvent(
        characteristic.serviceUuid,
        characteristic.characteristicUuid,
        GattPlatformMapper.valueToHex(characteristic.characteristicValue)
      ));
    });
  }

  async saveFavorite(device: BluetoothDevice, alias: string, protocol: string, uuid: string = ''): Promise<Result<void>> {
    const address = protocol === 'ble_gatt' || protocol === 'ble'
      ? (device.bleDeviceId.length > 0 ? device.bleDeviceId : device.primaryDeviceId)
      : (device.classicDeviceId.length > 0 ? device.classicDeviceId : device.primaryDeviceId);
    const saved = await this.identityDataSource.saveFavorite(
      address,
      device.displayName,
      alias,
      protocol,
      uuid
    );
    if (saved.success) {
      await this.refreshFavorites();
      this.classicMerger.merge(device.withFavorite(true, alias));
      this.bleMerger.merge(device.withFavorite(true, alias));
      this.publishClassicDevices();
      this.publishBleDevices();
    }
    return saved;
  }

  listClassicDevices(): BluetoothDevice[] {
    const keepAlive = this.collectScanKeepAlive();
    const keepAliveAddresses = keepAlive.addresses;
    const filtered = this.classicMerger.filter(this.classicFilter, keepAliveAddresses);
    const visible = ClassicScanVisibilityPolicy.filterVisible(filtered, keepAliveAddresses);
    const fallbackByAddress = this.buildKeepAliveFallbackDevices(keepAliveAddresses);
    const listed = ClassicScanVisibilityPolicy.augmentMissingActiveSessions(
      visible,
      keepAliveAddresses,
      this.pairedClassicCache,
      fallbackByAddress
    );
    const sorted = ClassicScanVisibilityPolicy.sortScanList(listed, keepAliveAddresses);
    this.logClassicScanSnapshot(keepAlive, sorted);
    return sorted;
  }

  /** 平台 Profile 已连接（非仅已配对；不含纯 ACL/SPP 系统连接）。 */
  isPlatformClassicConnected(classicDeviceId: string): boolean {
    return this.platformConnected.isConnected(classicDeviceId);
  }

  listBleDevices(): BluetoothDevice[] {
    return this.bleMerger.listSorted();
  }

  listFavorites(): DeviceFavoriteRecord[] {
    return this.favoritesCache;
  }

  resetClassicScanPhase(): void {
    this.classicScanPhase = ClassicScanPhase.IDLE;
  }

  isServiceStopped(): boolean {
    return this.serviceStopped;
  }

  observeServiceStopped(): Observable<boolean> {
    return this.serviceStoppedObservable;
  }

  haltForServiceStop(): void {
    this.serviceStopped = true;
    this.serviceStoppedObservable.next(true);
    void this.stopClassicDiscovery();
    this.stopBleScan();
    const clients = Array.from(this.gattClients.values());
    for (let i = 0; i < clients.length; i++) {
      clients[i].release();
    }
    this.gattClients.clear();
    SppSessionLedger.getInstance().closeAll();
  }

  private absorbPlatformFailure(result: Result<void>): void {
    const code = result.error?.code ?? '';
    const nativeCode = result.error?.nativeCode ?? '';
    if (code === BluetoothErrorCodes.SERVICE_STOPPED || nativeCode === '2900001') {
      this.haltForServiceStop();
    }
  }

  /** 会话态变化后刷新扫描列表可见性（注入正在连接的 SPP 目标）。 */
  republishClassicDevices(): void {
    this.publishClassicDevices();
  }

  resetBleScanPhase(): void {
    this.bleScanPhase = BleScanPhase.IDLE;
  }

  private async onBleDiscovered(payload: BleDiscoveryPayload, filter: BleScanFilter): Promise<void> {
    await this.refreshFavorites();
    const favorite = this.identityDataSource.isFavorite(payload.bleDeviceId, this.favoritesCache);
    const alias = this.identityDataSource.findAlias(payload.bleDeviceId, this.favoritesCache);
    if (filter.favoritesOnly && !favorite) {
      return;
    }
    const existing = this.bleAdvertisingMap.get(payload.bleDeviceId);
    let advertising = existing !== undefined
      ? payload.advertising.withUpdate(payload.rssi, Date.now(), existing.discoveryCount + 1)
      : payload.advertising;
    advertising = BluetoothRepository.applyManufacturerMask(advertising, filter);
    this.bleAdvertisingMap.set(payload.bleDeviceId, advertising);
    let device = BluetoothDeviceMapper.fromBleAdvertising(advertising, favorite, alias);
    device = this.applyFavoriteMeta(device);
    this.bleMerger.merge(device);
    this.publishBleDevices();
  }

  private onClassicDiscovered(payload: PlatformDiscoveryPayload): void {
    let transport = BluetoothTransportType.UNKNOWN;
    const transportResult = this.classicDataSource.getRemoteDeviceTransport(payload.classicDeviceId);
    if (transportResult.success && transportResult.value !== undefined) {
      transport = transportResult.value;
    }
    if (!BluetoothTransportPolicy.admitClassicDiscovery(transport, true)) {
      return;
    }
    let device = BluetoothDeviceMapper.fromDiscovery(payload, transport, false);
    device = this.applyFavoriteMeta(device);
    device = this.enrichFromPairedCache(device);
    this.classicMerger.merge(device);
    this.publishClassicDevices();
  }

  private enrichFromPairedCache(device: BluetoothDevice): BluetoothDevice {
    const cached = this.findPairedCacheDevice(device);
    if (cached === undefined) {
      return device;
    }
    return device.mergeFrom(cached);
  }

  private findPairedCacheDevice(device: BluetoothDevice): BluetoothDevice | undefined {
    const byPrimary = this.pairedClassicCache.get(device.primaryDeviceId);
    if (byPrimary !== undefined) {
      return byPrimary;
    }
    if (device.classicDeviceId.length > 0) {
      return this.pairedClassicCache.get(device.classicDeviceId);
    }
    return undefined;
  }

  private collectScanKeepAlive(): ClassicKeepAliveSnapshot {
    const store = SessionRuntimeStore.getInstance();
    const rawSummaries = store.listActiveSummaries();
    const summaries: ActiveSppSessionRef[] = [];
    for (let i = 0; i < rawSummaries.length; i++) {
      const item = rawSummaries[i];
      summaries.push(new ActiveSppSessionRef(item.module, item.protocol, item.state, item.id));
    }
    const ledgerEntries = SppSessionLedger.getInstance().listActive();
    const ledgerRefs: ConnectedSppLedgerRef[] = [];
    for (let i = 0; i < ledgerEntries.length; i++) {
      const entry = ledgerEntries[i];
      ledgerRefs.push(new ConnectedSppLedgerRef(entry.sessionKey.classicDeviceId, entry.phase));
    }
    const platformSnapshot = this.classicFilter.includeConnectedPaired
      ? this.platformConnected.listConnectedClassicAddresses()
      : ClassicConnectedSnapshot.empty();
    return ClassicScanKeepAliveCollector.collect(
      this.classicFilter.includeConnectedPaired,
      platformSnapshot,
      ledgerRefs,
      summaries,
      (sessionId: string) => {
        const session = store.getSession(sessionId);
        return session?.target?.address ?? '';
      }
    );
  }

  private logClassicScanSnapshot(keepAlive: ClassicKeepAliveSnapshot, listed: BluetoothDevice[]): void {
    const keepAliveNames: string[] = [];
    keepAlive.addresses.forEach((address: string) => {
      const cached = this.pairedClassicCache.get(address);
      if (cached !== undefined) {
        keepAliveNames.push(BluetoothRepository.maskDeviceLabel(cached));
      } else {
        keepAliveNames.push(BluetoothRepository.maskAddress(address));
      }
    });
    const listedNames: string[] = [];
    for (let i = 0; i < listed.length; i++) {
      listedNames.push(BluetoothRepository.maskDeviceLabel(listed[i]));
    }
    scanLogger.info(
      `classic_scan_list includeConnected=${this.classicFilter.includeConnectedPaired}` +
      ` pairedCache=${this.pairedClassicCache.size}` +
      ` profile=${keepAlive.profileCount}` +
      ` sppConnected=${keepAlive.sppConnectedCount}` +
      ` sppConnecting=${keepAlive.sppConnectingCount}` +
      ` keepAlive=[${keepAliveNames.join(',')}]` +
      ` listed=[${listedNames.join(',')}]`
    );
  }

  private buildKeepAliveFallbackDevices(activeAddresses: Set<string>): Map<string, BluetoothDevice> {
    const fallbacks = new Map<string, BluetoothDevice>();
    if (activeAddresses.size === 0) {
      return fallbacks;
    }
    const store = SessionRuntimeStore.getInstance();
    const summaries = store.listActiveSummaries();
    for (let i = 0; i < summaries.length; i++) {
      const summary = summaries[i];
      if (summary.module !== ModuleType.BLUETOOTH || summary.protocol !== ProtocolType.SPP) {
        continue;
      }
      if (!ClassicScanKeepAliveCollector.isConnectedSessionState(summary.state) &&
        !ClassicScanKeepAliveCollector.isConnectingSessionState(summary.state)) {
        continue;
      }
      const session = store.getSession(summary.id);
      const address = session?.target?.address ?? '';
      const normalized = SppSessionKey.normalizeClassicId(address);
      if (normalized.length === 0 || !activeAddresses.has(normalized) || fallbacks.has(normalized)) {
        continue;
      }
      if (this.pairedClassicCache.has(normalized)) {
        continue;
      }
      fallbacks.set(normalized, this.buildSessionFallbackDevice(
        normalized,
        session?.displayName ?? summary.displayName
      ));
    }
    activeAddresses.forEach((address: string) => {
      if (fallbacks.has(address) || this.pairedClassicCache.has(address)) {
        return;
      }
      const name = this.classicDataSource.getRemoteDeviceNameSafe(address);
      fallbacks.set(address, this.buildSessionFallbackDevice(
        address,
        name.length > 0 ? name : address
      ));
    });
    return fallbacks;
  }

  private static maskDeviceLabel(device: BluetoothDevice): string {
    const name = device.effectiveName.length > 0 ? device.effectiveName : '?';
    return `${name}@${BluetoothRepository.maskAddress(device.primaryDeviceId)}`;
  }

  private static maskAddress(address: string): string {
    const normalized = SppSessionKey.normalizeClassicId(address);
    if (normalized.length < 5) {
      return '**';
    }
    return `**${normalized.substring(normalized.length - 5)}`;
  }

  private buildSessionFallbackDevice(address: string, displayName: string): BluetoothDevice {
    const draft = new BluetoothDeviceDraft();
    draft.primaryDeviceId = address;
    draft.classicDeviceId = address;
    draft.displayName = displayName.length > 0 ? displayName : address;
    draft.paired = true;
    draft.transport = BluetoothTransportType.BR_EDR;
    draft.listRail = BluetoothListRail.CLASSIC_SCAN;
    draft.discoverySource = DiscoverySource.MANUAL;
    return new BluetoothDevice(draft);
  }

  private applyFavoriteMeta(device: BluetoothDevice): BluetoothDevice {
    const ids: string[] = [device.primaryDeviceId, device.classicDeviceId, device.bleDeviceId];
    let favorite = false;
    let alias = '';
    for (let i = 0; i < ids.length; i++) {
      if (ids[i].length === 0) {
        continue;
      }
      if (this.identityDataSource.isFavorite(ids[i], this.favoritesCache)) {
        favorite = true;
      }
      const foundAlias = this.identityDataSource.findAlias(ids[i], this.favoritesCache);
      if (foundAlias.length > 0 && alias.length === 0) {
        alias = foundAlias;
      }
    }
    if (!favorite && alias.length === 0) {
      return device;
    }
    return device.withFavorite(favorite, alias);
  }

  /**
   * Link classic + BLE virtual MACs that share the same remote name after dual-mode pairing.
   */
  private reconcileDualModeFromSnapshots(snapshots: PlatformPairedSnapshot[]): void {
    const classicSide: PlatformPairedSnapshot[] = [];
    const bleSide: PlatformPairedSnapshot[] = [];
    for (let i = 0; i < snapshots.length; i++) {
      const item = snapshots[i];
      if (item.transport === BluetoothTransportType.BR_EDR ||
        item.transport === BluetoothTransportType.DUAL ||
        item.transport === BluetoothTransportType.UNKNOWN) {
        classicSide.push(item);
      }
      if (item.transport === BluetoothTransportType.LE ||
        item.transport === BluetoothTransportType.DUAL) {
        bleSide.push(item);
      }
    }
    for (let c = 0; c < classicSide.length; c++) {
      const classic = classicSide[c];
      const classicName = classic.deviceName.trim().toLowerCase();
      if (classicName.length === 0) {
        continue;
      }
      for (let b = 0; b < bleSide.length; b++) {
        const ble = bleSide[b];
        if (classic.address === ble.address) {
          continue;
        }
        const bleName = ble.deviceName.trim().toLowerCase();
        if (bleName.length === 0 || bleName !== classicName) {
          continue;
        }
        this.identityDataSource.linkDualModeIdentity(
          classic.address,
          ble.address,
          classic.deviceName
        );
      }
    }
  }

  private async admitPairedClassicSnapshot(
    snapshot: PlatformPairedSnapshot
  ): Promise<PairedClassicAdmitResult> {
    if (BluetoothTransportPolicy.admitClassicPaired(snapshot.transport)) {
      return new PairedClassicAdmitResult(true, snapshot.transport);
    }
    if (snapshot.transport === BluetoothTransportType.LE) {
      return new PairedClassicAdmitResult(false, snapshot.transport);
    }
    if (snapshot.transport !== BluetoothTransportType.UNKNOWN) {
      return new PairedClassicAdmitResult(false, snapshot.transport);
    }
    const retry = this.classicDataSource.getRemoteDeviceTransport(snapshot.address);
    if (retry.success && retry.value !== undefined) {
      if (BluetoothTransportPolicy.admitClassicPaired(retry.value)) {
        return new PairedClassicAdmitResult(true, retry.value);
      }
      if (retry.value === BluetoothTransportType.LE) {
        return new PairedClassicAdmitResult(false, retry.value);
      }
    }
    const uuids = await this.classicDataSource.getRemoteProfileUuids(snapshot.address);
    if (uuids.success &&
      uuids.value !== undefined &&
      BluetoothTransportPolicy.hasClassicProfileHint(uuids.value)) {
      return new PairedClassicAdmitResult(true, BluetoothTransportType.BR_EDR, uuids.value);
    }
    return new PairedClassicAdmitResult(false, BluetoothTransportType.UNKNOWN);
  }

  /**
   * 已配对设备写入 profileUuids（展示用）。
   * 失败不阻断列表（architecture bluetooth/01 · YW-BT-1202）。
   */
  private async attachProfileUuids(
    device: BluetoothDevice,
    knownUuids: string[]
  ): Promise<BluetoothDevice> {
    if (knownUuids.length > 0) {
      return device.withProfileUuids(knownUuids);
    }
    const address = device.classicDeviceId.length > 0 ? device.classicDeviceId : device.primaryDeviceId;
    if (address.length === 0) {
      return device;
    }
    const uuids = await this.classicDataSource.getRemoteProfileUuids(address);
    if (uuids.success && uuids.value !== undefined && uuids.value.length > 0) {
      return device.withProfileUuids(uuids.value);
    }
    return device;
  }

  private publishClassicDevices(): void {
    this.classicDevicesObservable.next(this.listClassicDevices());
  }

  private publishBleDevices(): void {
    this.bleDevicesObservable.next(this.bleMerger.listSorted());
  }

  private static applyManufacturerMask(
    packet: BleAdvertisingPacket,
    filter: BleScanFilter
  ): BleAdvertisingPacket {
    if (filter.manufacturerData.length === 0 || filter.manufacturerMask.length === 0) {
      return packet;
    }
    const manufacturerData: BleManufacturerDataEntry[] = [];
    for (let i = 0; i < packet.manufacturerData.length; i++) {
      const entry = packet.manufacturerData[i];
      manufacturerData.push(new BleManufacturerDataEntry(
        entry.manufacturerId,
        entry.hexPayload,
        BleManufacturerMaskMatcher.matches(entry.hexPayload, filter.manufacturerData, filter.manufacturerMask)
      ));
    }
    return new BleAdvertisingPacket(
      packet.bleDeviceId,
      packet.rssi,
      packet.connectable,
      packet.rawHex,
      packet.localName,
      packet.nameSource,
      packet.serviceUuids,
      packet.serviceData,
      manufacturerData,
      packet.txPower,
      packet.flags,
      packet.parseWarnings,
      packet.discoveredAtMs,
      packet.discoveryCount
    );
  }
}

class PairedClassicAdmitResult {
  readonly admit: boolean;
  readonly resolvedTransport: BluetoothTransportType;
  /** UNKNOWN 降级路径已查询到的 UUID，避免 refresh 时重复 SDP。 */
  readonly profileUuids: string[];

  constructor(
    admit: boolean,
    resolvedTransport: BluetoothTransportType,
    profileUuids: string[] = []
  ) {
    this.admit = admit;
    this.resolvedTransport = resolvedTransport;
    this.profileUuids = profileUuids;
  }
}
