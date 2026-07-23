import { DeviceFavoriteRecord } from 'common_storage';
import { Observable, Result, ResultError } from 'common_core';
import { ModuleType, SessionRuntimeStore } from 'feature_debug_core';
import { ClassicBluetoothDataSource, PlatformDiscoveryPayload } from '../datasource/platform/ClassicBluetoothDataSource';
import { BleDiscoveryPayload, BleScannerDataSource } from '../datasource/platform/BleScannerDataSource';
import { BluetoothIdentityDataSource } from '../datasource/platform/BluetoothIdentityDataSource';
import { GattClientDataSource } from '../datasource/platform/GattClientDataSource';
import { BluetoothDeviceMapper, PlatformPairedSnapshot } from '../mapper/BluetoothDeviceMapper';
import {
  BluetoothAdapterSnapshot,
  BluetoothDevice,
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
import { ScanResultMerger } from '../../domain/service/ScanResultMerger';
import { PairingEvent, PairingState } from '../../domain/model/PairingState';
import { ClassicScanTimer } from '../../domain/service/ClassicScanTimer';
import { BluetoothErrorCodes } from '../../constants/BluetoothErrorCodes';
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

/**
 * Bluetooth repository facade per architecture 02-§6.1.
 */
export class BluetoothRepository implements BluetoothRepositoryContract {
  private static instance: BluetoothRepository | undefined;
  private readonly classicDataSource: ClassicBluetoothDataSource;
  private readonly bleDataSource: BleScannerDataSource;
  private readonly identityDataSource: BluetoothIdentityDataSource;
  private readonly classicMerger: ScanResultMerger = new ScanResultMerger();
  private readonly bleMerger: ScanResultMerger = new ScanResultMerger();
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
  private classicFilterName: string = '';
  private classicFilterAddress: string = '';
  private classicFilterPairedOnly: boolean = false;
  private classicFilterFavoritesOnly: boolean = false;
  private activeBleScanFilter: BleScanFilter = new BleScanFilter();

  private constructor(
    classicDataSource: ClassicBluetoothDataSource = ClassicBluetoothDataSource.getInstance(),
    bleDataSource: BleScannerDataSource = BleScannerDataSource.getInstance(),
    identityDataSource: BluetoothIdentityDataSource = BluetoothIdentityDataSource.getInstance()
  ) {
    this.classicDataSource = classicDataSource;
    this.bleDataSource = bleDataSource;
    this.identityDataSource = identityDataSource;
    this.classicDevicesObservable = new Observable<BluetoothDevice[]>([]);
    this.bleDevicesObservable = new Observable<BluetoothDevice[]>([]);
    this.scanRemainingObservable = new Observable<number>(0);
    this.gattTreeObservable = new Observable<GattServiceTreeSnapshot>(
      new GattServiceTreeSnapshot('', '', 23, [], GattClientState.IDLE)
    );
    void this.identityDataSource.loadRecentFromStore();
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

  /**
   * Load paired devices eligible for classic / SPP rail (BR_EDR | DUAL).
   * LE-only entries are excluded per architecture bluetooth/00.
   */
  async loadPairedClassicCandidates(): Promise<Result<BluetoothDevice[]>> {
    const paired = await this.classicDataSource.getPairedDeviceSnapshots();
    if (!paired.success || paired.value === undefined) {
      return Result.fail(paired.error ?? new ResultError(BluetoothErrorCodes.CLASSIC_UNAVAILABLE, 'paired failed'));
    }
    await this.refreshFavorites();
    this.reconcileDualModeFromSnapshots(paired.value);
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
      devices.push(device);
    }
    this.classicMerger.upsertAll(devices);
    this.publishClassicDevices();
    return Result.ok(this.listClassicDevices());
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

  setClassicDeviceFilter(name: string, address: string, pairedOnly: boolean, favoritesOnly: boolean): void {
    this.classicFilterName = name;
    this.classicFilterAddress = address;
    this.classicFilterPairedOnly = pairedOnly;
    this.classicFilterFavoritesOnly = favoritesOnly;
    this.publishClassicDevices();
  }

  async startClassicDiscovery(sessionId: string, onTimeout?: () => void): Promise<Result<void>> {
    if (this.classicScanPhase === ClassicScanPhase.SCANNING) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SCAN_ALREADY_RUNNING, 'Scan already running'));
    }
    const discovering = await this.classicDataSource.isBluetoothDiscovering();
    if (discovering.success && discovering.value === true) {
      await this.classicDataSource.stopBluetoothDiscovery();
    }
    this.classicScanPhase = ClassicScanPhase.SCANNING;
    this.activeClassicScanSessionId = sessionId;
    this.classicDataSource.onDiscoveryResult((payload: PlatformDiscoveryPayload) => {
      this.onClassicDiscovered(payload);
    });
    const started = await this.classicDataSource.startBluetoothDiscovery();
    if (!started.success) {
      this.classicScanPhase = ClassicScanPhase.FAILED;
      this.classicDataSource.offDiscoveryResult();
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
    return this.classicMerger.filter(
      this.classicFilterName,
      this.classicFilterAddress,
      this.classicFilterPairedOnly,
      this.classicFilterFavoritesOnly
    );
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
    this.classicMerger.merge(device);
    this.publishClassicDevices();
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
      return new PairedClassicAdmitResult(true, BluetoothTransportType.BR_EDR);
    }
    return new PairedClassicAdmitResult(false, BluetoothTransportType.UNKNOWN);
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

  constructor(admit: boolean, resolvedTransport: BluetoothTransportType) {
    this.admit = admit;
    this.resolvedTransport = resolvedTransport;
  }
}
