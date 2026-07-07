import { DeviceFavoriteRecord } from 'common_storage';
import { Observable, Result, ResultError } from 'common_core';
import { ModuleType, SessionRuntimeStore } from 'feature_debug_core';
import { ClassicBluetoothDataSource, PlatformDiscoveryPayload } from '../datasource/platform/ClassicBluetoothDataSource';
import { BleDiscoveryPayload, BleScannerDataSource } from '../datasource/platform/BleScannerDataSource';
import { BluetoothIdentityDataSource } from '../datasource/platform/BluetoothIdentityDataSource';
import { GattClientDataSource } from '../datasource/platform/GattClientDataSource';
import { BluetoothDeviceMapper } from '../mapper/BluetoothDeviceMapper';
import {
  BluetoothAdapterSnapshot,
  BluetoothDevice,
  BluetoothOverviewSnapshot
} from '../../domain/model/BluetoothDevice';
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

  getPairedDevices(): Promise<Result<BluetoothDevice[]>> {
    return this.loadPairedDevices();
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
      this.classicMerger.listSorted().filter((d: BluetoothDevice) => d.paired).length,
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
    return this.identityDataSource.listRecentConnections();
  }

  recordRecentConnection(deviceId: string, displayName: string, protocol: string): void {
    this.identityDataSource.recordRecentConnection(deviceId, displayName, protocol);
  }

  async refreshFavorites(): Promise<Result<DeviceFavoriteRecord[]>> {
    const listed = await this.identityDataSource.listFavorites();
    if (listed.success && listed.value !== undefined) {
      this.favoritesCache = listed.value;
    }
    return listed;
  }

  async loadPairedDevices(): Promise<Result<BluetoothDevice[]>> {
    const paired = await this.classicDataSource.getPairedDevices();
    if (!paired.success || paired.value === undefined) {
      return Result.fail(paired.error ?? new ResultError(BluetoothErrorCodes.CLASSIC_UNAVAILABLE, 'paired failed'));
    }
    await this.refreshFavorites();
    const devices: BluetoothDevice[] = [];
    for (let i = 0; i < paired.value.length; i++) {
      let device = BluetoothDeviceMapper.fromPaired(paired.value[i]);
      device = this.applyFavoriteMeta(device);
      devices.push(device);
    }
    this.classicMerger.replaceAll(devices);
    this.publishClassicDevices();
    return Result.ok(this.classicMerger.listSorted());
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
      if (devices[i].deviceId === event.deviceId) {
        this.classicMerger.merge(devices[i].withPairState(event.state, event.state === PairingState.PAIRED));
      }
    }
    this.publishClassicDevices();
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

  getBleAdvertising(deviceId: string): BleAdvertisingPacket | undefined {
    return this.bleAdvertisingMap.get(deviceId);
  }

  createGattClient(sessionId: string, deviceId: string): GattClientDataSource {
    const existing = this.gattClients.get(sessionId);
    if (existing !== undefined) {
      existing.release();
    }
    const client = new GattClientDataSource();
    client.createClient(deviceId);
    this.gattClients.set(sessionId, client);
    return client;
  }

  getGattClient(sessionId: string): GattClientDataSource | undefined {
    return this.gattClients.get(sessionId);
  }

  async discoverGattServices(sessionId: string, deviceId: string, mtu: number = 23): Promise<Result<GattServiceTreeSnapshot>> {
    const client = this.gattClients.get(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'GATT client missing'));
    }
    const services = await client.discoverServices();
    if (!services.success || services.value === undefined) {
      return Result.fail(services.error ?? new ResultError(BluetoothErrorCodes.BLE_GATT_DISCOVER_FAILED, 'discover failed'));
    }
    const tree = GattPlatformMapper.fromPlatformServices(services.value);
    const snapshot = new GattServiceTreeSnapshot(sessionId, deviceId, mtu, tree, GattClientState.READY);
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

  async connectGattBrowser(sessionId: string, deviceId: string, timeoutMs: number = 15000): Promise<Result<void>> {
    this.createGattClient(sessionId, deviceId);
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
    const saved = await this.identityDataSource.saveFavorite(
      device.deviceId,
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
    const favorite = this.identityDataSource.isFavorite(payload.deviceId, this.favoritesCache);
    const alias = this.identityDataSource.findAlias(payload.deviceId, this.favoritesCache);
    if (filter.favoritesOnly && !favorite) {
      return;
    }
    const existing = this.bleAdvertisingMap.get(payload.deviceId);
    let advertising = existing !== undefined
      ? payload.advertising.withUpdate(payload.rssi, Date.now(), existing.discoveryCount + 1)
      : payload.advertising;
    advertising = BluetoothRepository.applyManufacturerMask(advertising, filter);
    this.bleAdvertisingMap.set(payload.deviceId, advertising);
    let device = BluetoothDeviceMapper.fromBleAdvertising(advertising, favorite, alias);
    device = this.applyFavoriteMeta(device);
    this.bleMerger.merge(device);
    this.publishBleDevices();
  }

  private onClassicDiscovered(payload: PlatformDiscoveryPayload): void {
    let device = BluetoothDeviceMapper.fromDiscovery(payload, false);
    device = this.applyFavoriteMeta(device);
    this.classicMerger.merge(device);
    this.publishClassicDevices();
  }

  private applyFavoriteMeta(device: BluetoothDevice): BluetoothDevice {
    const favorite = this.identityDataSource.isFavorite(device.deviceId, this.favoritesCache);
    const alias = this.identityDataSource.findAlias(device.deviceId, this.favoritesCache);
    if (!favorite && alias.length === 0) {
      return device;
    }
    return device.withFavorite(favorite, alias);
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
      packet.deviceId,
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
