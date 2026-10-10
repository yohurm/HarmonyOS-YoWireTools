import { DeviceFavoriteRecord } from 'common_storage';
import { Observable, Result, ResultError, Subscription, TimeUtil } from 'common_core';
import {
  ITransportSession,
  IncomingPayload,
  ModuleType,
  SessionRuntimeStore,
  TransportSessionRegistry
} from 'debug_core';
import { NearLinkManagerDataSource } from '../datasource/platform/NearLinkManagerDataSource';
import { NearLinkScanDataSource, NearLinkDiscoveryPayload } from '../datasource/platform/NearLinkScanDataSource';
import { SsapClientDataSource } from '../datasource/platform/SsapClientDataSource';
import { DataTransferDataSource } from '../datasource/platform/DataTransferDataSource';
import { NearLinkIdentityDataSource } from '../datasource/platform/NearLinkIdentityDataSource';
import { NearLinkAdvertisingDataSource } from '../datasource/platform/NearLinkAdvertisingDataSource';
import { SsapServerDataSource } from '../datasource/platform/SsapServerDataSource';
import { RemoteDeviceDataSource } from '../datasource/platform/RemoteDeviceDataSource';
import { NearLinkLogExportDataSource } from '../datasource/platform/NearLinkLogExportDataSource';
import { NearLinkDeviceMapper } from '../mapper/NearLinkDeviceMapper';
import {
  NearLinkAdapterSnapshot,
  NearLinkDevice,
  NearLinkOverviewSnapshot
} from '../../domain/model/NearLinkDevice';
import { NearLinkScanPhase } from '../../domain/model/NearLinkScanPhase';
import { NearLinkScanFilter } from '../../domain/model/NearLinkScanFilter';
import { ScanResultMerger } from '../../domain/service/ScanResultMerger';
import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';
import { NearLinkAdvertisingPacket } from '../../domain/model/NearLinkAdvertisingPacket';
import { NearLinkRecentConnection } from '../../domain/model/NearLinkRecentConnection';
import { NearLinkRepositoryContract } from '../../domain/repository/NearLinkRepositoryContract';
import { SsapClientState, SsapServiceTreeSnapshot } from '../../domain/model/SsapServiceTree';
import { NearLinkConstants } from '../../constants/NearLinkConstants';
import {
  NearLinkPairingNotice,
  NearLinkRadioCode,
  NearLinkRadioSnapshot,
  NearLinkSupportQuery
} from '../../domain/model/NearLinkRadio';
import { NearLinkSecurityState } from '../../domain/model/NearLinkSecurityState';
import { SsapServerWriteRecord } from '../../domain/model/SsapServerWriteRecord';
import { NearLinkAdvParser } from '../../domain/service/NearLinkAdvParser';
import { NearLinkScanPolicy } from '../../domain/service/NearLinkScanPolicy';
import { NearLinkEventLogger } from '../../domain/service/NearLinkEventLogger';
import { SsapPropertyChangeDispatcher } from '../service/SsapPropertyChangeDispatcher';
import { SsapPlatformMapper } from '../mapper/SsapPlatformMapper';
import { SsapPropertyNotifyPayload } from '../../domain/model/SsapPropertyNotifyPayload';
import { DataTransferPacket } from '../../domain/model/DataTransferPortConfig';
import { NearLinkDataTransferSession } from '../transport/NearLinkDataTransferSession';
import { SsapTransportSession } from '../transport/SsapTransportSession';
import { CongestionPolicy } from '../../domain/model/DataTransferPortConfig';

export class NearLinkRepository implements NearLinkRepositoryContract {
  private static instance: NearLinkRepository | undefined;
  private readonly managerDataSource: NearLinkManagerDataSource;
  private readonly scanDataSource: NearLinkScanDataSource;
  private readonly identityDataSource: NearLinkIdentityDataSource;
  private readonly merger: ScanResultMerger = new ScanResultMerger();
  private readonly ssapClients: Map<string, SsapClientDataSource> = new Map();
  private readonly dataTransferSources: Map<string, DataTransferDataSource> = new Map();
  private readonly ssapDispatchers: Map<string, SsapPropertyChangeDispatcher> = new Map();
  private readonly advertisingMap: Map<string, NearLinkAdvertisingPacket> = new Map();
  private activeFilter: NearLinkScanFilter | undefined;
  private readonly devicesObservable: Observable<NearLinkDevice[]>;
  private readonly ssapTreeObservable: Observable<SsapServiceTreeSnapshot>;
  private readonly dataTransferPacketObservable: Observable<DataTransferPacket>;
  private readonly dataTransferIncomingSubscriptions: Map<string, Subscription> = new Map();
  private scanPhase: NearLinkScanPhase = NearLinkScanPhase.IDLE;
  private scanStarting: boolean = false;
  private readonly ssapClientAddress: Map<string, string> = new Map();
  private readonly ssapByAddress: Map<string, SsapClientDataSource> = new Map();
  private readonly advertisingSource: NearLinkAdvertisingDataSource;
  private readonly serverSource: SsapServerDataSource;
  private readonly portSource: DataTransferDataSource;
  private readonly remoteSource: RemoteDeviceDataSource;
  private readonly ssapTransports: Map<string, SsapTransportSession> = new Map();
  private readonly transferTransports: Map<string, NearLinkDataTransferSession> = new Map();
  private activeScanSessionId: string = '';
  private favoritesCache: DeviceFavoriteRecord[] = [];

  private constructor(
    managerDataSource: NearLinkManagerDataSource = NearLinkManagerDataSource.getInstance(),
    scanDataSource: NearLinkScanDataSource = NearLinkScanDataSource.getInstance(),
    identityDataSource: NearLinkIdentityDataSource = NearLinkIdentityDataSource.getInstance()
  ) {
    this.managerDataSource = managerDataSource;
    this.scanDataSource = scanDataSource;
    this.identityDataSource = identityDataSource;
    this.advertisingSource = new NearLinkAdvertisingDataSource();
    this.serverSource = new SsapServerDataSource();
    this.portSource = new DataTransferDataSource();
    this.remoteSource = new RemoteDeviceDataSource();
    this.devicesObservable = new Observable<NearLinkDevice[]>([]);
    this.ssapTreeObservable = new Observable<SsapServiceTreeSnapshot>(
      new SsapServiceTreeSnapshot('', '', NearLinkConstants.DEFAULT_MTU, [], SsapClientState.IDLE)
    );
    this.dataTransferPacketObservable = new Observable<DataTransferPacket>(
      new DataTransferPacket('in', '', TimeUtil.nowMs())
    );
  }

  static getInstance(): NearLinkRepository {
    if (NearLinkRepository.instance === undefined) {
      NearLinkRepository.instance = new NearLinkRepository();
    }
    return NearLinkRepository.instance;
  }

  observeDevices(): Observable<NearLinkDevice[]> {
    return this.devicesObservable;
  }

  observeAdapterState(): Observable<NearLinkAdapterSnapshot> {
    return this.managerDataSource.observeAdapterState();
  }

  observeSsapTree(): Observable<SsapServiceTreeSnapshot> {
    return this.ssapTreeObservable;
  }

  observeSsapPropertyNotify(sessionId: string): Observable<SsapPropertyNotifyPayload> {
    return this.getOrCreateSsapDispatcher(sessionId).observeNotify();
  }

  observeDataTransferPackets(): Observable<DataTransferPacket> {
    return this.dataTransferPacketObservable;
  }

  emitDataTransferPacket(packet: DataTransferPacket): void {
    this.dataTransferPacketObservable.next(packet);
  }

  attachDataTransferIncoming(sessionId: string, transport: ITransportSession): void {
    this.detachDataTransferIncoming(sessionId);
    const subscription = transport.observeIncoming().subscribe((payload: IncomingPayload) => {
      const hex = NearLinkAdvParser.toHex(payload.bytes);
      this.emitDataTransferPacket(new DataTransferPacket('in', hex, payload.timestampMs));
    }, false);
    this.dataTransferIncomingSubscriptions.set(sessionId, subscription);
  }

  detachDataTransferIncoming(sessionId: string): void {
    const subscription = this.dataTransferIncomingSubscriptions.get(sessionId);
    if (subscription !== undefined) {
      subscription.dispose();
      this.dataTransferIncomingSubscriptions.delete(sessionId);
    }
  }

  getScanPhase(): NearLinkScanPhase {
    return this.scanPhase;
  }

  getActiveScanSessionId(): string {
    return this.activeScanSessionId;
  }

  resetScanPhase(): void {
    this.scanPhase = NearLinkScanPhase.IDLE;
    this.activeScanSessionId = '';
  }

  onAdapterStateChange(listener: (snapshot: NearLinkAdapterSnapshot) => void): void {
    this.managerDataSource.onStateChange((radio: NearLinkRadioSnapshot) => {
      listener(new NearLinkAdapterSnapshot(
        true,
        radio.code === NearLinkRadioCode.ON,
        radio.code,
        `${radio.code}`
      ));
    });
  }

  offAdapterStateChange(): void {
    this.managerDataSource.offStateChange();
  }

  async loadAdapterState(): Promise<Result<NearLinkAdapterSnapshot>> {
    return this.managerDataSource.getAdapterState();
  }

  async refreshFavorites(): Promise<Result<DeviceFavoriteRecord[]>> {
    const listed = await this.identityDataSource.listFavorites();
    if (listed.success && listed.value !== undefined) {
      this.favoritesCache = listed.value;
    }
    return listed;
  }

  async loadOverview(permissionGranted: boolean): Promise<NearLinkOverviewSnapshot> {
    await this.refreshFavorites();
    const adapter = await this.loadAdapterState();
    const adapterSnapshot = adapter.success && adapter.value !== undefined
      ? adapter.value
      : new NearLinkAdapterSnapshot(false, false, 0, 'Unknown');
    const warnings: string[] = [];
    if (!adapterSnapshot.supported) {
      warnings.push('Device does not support NearLink');
    }
    if (adapterSnapshot.supported && !adapterSnapshot.enabled) {
      warnings.push('NearLink switch is off');
    }
    if (!permissionGranted) {
      warnings.push('ACCESS_NEARLINK permission denied');
    }
    const activeSessions = SessionRuntimeStore.getInstance().listActiveSummaries()
      .filter((item) => item.module === ModuleType.NEARLINK).length;
    return new NearLinkOverviewSnapshot(
      adapterSnapshot,
      permissionGranted,
      this.scanPhase,
      this.merger.listSorted().length,
      this.favoritesCache.length,
      activeSessions,
      warnings
    );
  }

  hasSsapClient(address: string): boolean {
    return this.findSsapClient(address) !== undefined;
  }

  async startScan(sessionId: string, filter: NearLinkScanFilter): Promise<Result<void>> {
    if (this.managerDataSource.isEmulator()) {
      return Result.fail(new ResultError(NearLinkErrorCodes.EMULATOR_UNAVAILABLE, 'api=startScan'));
    }
    if (this.scanPhase === NearLinkScanPhase.SCANNING || this.scanStarting) {
      return Result.ok(undefined);
    }
    this.scanStarting = true;
    this.activeFilter = filter;
    const started = await this.scanDataSource.startScan(filter);
    if (!started.success) {
      this.scanStarting = false;
      this.scanPhase = NearLinkScanPhase.FAILED;
      return Result.fail(started.error ?? new ResultError(NearLinkErrorCodes.SCAN_FAILED, 'api=startScan'));
    }
    const subscribed = this.scanDataSource.onDeviceFound((payload: NearLinkDiscoveryPayload) => {
      this.handleDiscovery(payload);
    });
    if (!subscribed.success) {
      await this.scanDataSource.stopScan();
      this.scanStarting = false;
      this.scanPhase = NearLinkScanPhase.FAILED;
      return subscribed;
    }
    this.scanPhase = NearLinkScanPhase.SCANNING;
    this.activeScanSessionId = sessionId;
    this.scanStarting = false;
    return Result.ok(undefined);
  }

  async stopScan(): Promise<Result<void>> {
    const stopped = await this.scanDataSource.stopScan();
    this.scanStarting = false;
    this.scanPhase = stopped.success ? NearLinkScanPhase.COMPLETED : NearLinkScanPhase.FAILED;
    return stopped;
  }

  listDevices(): NearLinkDevice[] {
    return this.merger.listSorted();
  }

  getAdvertising(address: string): NearLinkAdvertisingPacket | undefined {
    return this.advertisingMap.get(address);
  }

  listRecentConnections(): NearLinkRecentConnection[] {
    return this.identityDataSource.listRecentConnections();
  }

  listFavorites(): DeviceFavoriteRecord[] {
    return this.favoritesCache;
  }

  recordRecentConnection(deviceId: string, displayName: string, protocol: string): void {
    this.identityDataSource.recordRecentConnection(deviceId, displayName, protocol);
  }

  async saveFavorite(
    device: NearLinkDevice,
    alias: string,
    protocol: string,
    uuid: string = ''
  ): Promise<Result<void>> {
    const saved = await this.identityDataSource.saveFavorite(device, alias, protocol, uuid);
    if (saved.success) {
      await this.refreshFavorites();
    }
    return saved;
  }

  getSsapClient(sessionId: string): SsapClientDataSource | undefined {
    return this.ssapClients.get(sessionId);
  }

  getOrCreateDataTransferSource(sessionId: string): DataTransferDataSource {
    let source = this.dataTransferSources.get(sessionId);
    if (source === undefined) {
      source = new DataTransferDataSource();
      this.dataTransferSources.set(sessionId, source);
    }
    return source;
  }

  getDataTransferSource(sessionId: string): DataTransferDataSource | undefined {
    return this.dataTransferSources.get(sessionId);
  }

  createDataTransferTransport(
    sessionId: string,
    policy: CongestionPolicy = new CongestionPolicy()
  ): NearLinkDataTransferSession {
    const source = this.getOrCreateDataTransferSource(sessionId);
    return new NearLinkDataTransferSession(sessionId, source, policy);
  }

  createSsapTransport(sessionId: string): SsapTransportSession | undefined {
    const client = this.ssapClients.get(sessionId);
    if (client === undefined) {
      return undefined;
    }
    return new SsapTransportSession(sessionId, client);
  }

  getOrCreateSsapDispatcher(sessionId: string): SsapPropertyChangeDispatcher {
    let dispatcher = this.ssapDispatchers.get(sessionId);
    if (dispatcher === undefined) {
      dispatcher = new SsapPropertyChangeDispatcher();
      this.ssapDispatchers.set(sessionId, dispatcher);
    }
    return dispatcher;
  }

  getLatestSsapTree(): SsapServiceTreeSnapshot {
    return this.ssapTreeObservable.snapshot;
  }

  getOrCreateSsapClient(sessionId: string, address: string): Result<SsapClientDataSource> {
    const bound = this.findSsapClient(address);
    if (bound !== undefined) {
      this.ssapClients.set(sessionId, bound);
      this.ssapClientAddress.set(sessionId, address);
      this.ssapByAddress.set(address, bound);
      return Result.ok(bound);
    }
    let client = this.ssapClients.get(sessionId);
    if (client === undefined) {
      client = new SsapClientDataSource();
      const created = client.createClient(address);
      if (!created.success) {
        return Result.fail(created.error ?? new ResultError(NearLinkErrorCodes.SSAP_CREATE_FAILED, 'create failed'));
      }
      this.ssapClients.set(sessionId, client);
    }
    this.ssapClientAddress.set(sessionId, address);
    this.ssapByAddress.set(address, client);
    return Result.ok(client);
  }

  private findSsapClient(address: string): SsapClientDataSource | undefined {
    return this.ssapByAddress.get(address);
  }

  async discoverSsapServices(sessionId: string, address: string, mtu: number): Promise<Result<SsapServiceTreeSnapshot>> {
    const clientResult = this.getOrCreateSsapClient(sessionId, address);
    if (!clientResult.success || clientResult.value === undefined) {
      return Result.fail(clientResult.error ?? new ResultError(NearLinkErrorCodes.SSAP_DISCOVER_FAILED, 'no client'));
    }
    const client = clientResult.value;
    const servicesResult = await client.getServices();
    if (!servicesResult.success || servicesResult.value === undefined) {
      return Result.fail(servicesResult.error ?? new ResultError(NearLinkErrorCodes.SSAP_DISCOVER_FAILED, 'discover failed'));
    }
    const tree = SsapPlatformMapper.toServiceTree(
      sessionId,
      address,
      servicesResult.value,
      mtu,
      SsapClientState.READY
    );
    this.ssapTreeObservable.next(tree);
    return Result.ok(tree);
  }

  emitSsapTree(tree: SsapServiceTreeSnapshot): void {
    this.ssapTreeObservable.next(tree);
  }

  wireSsapClientSession(sessionId: string, deviceId: string): Result<void> {
    const client = this.ssapClients.get(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP client not created'));
    }
    const dispatcher = this.getOrCreateSsapDispatcher(sessionId);
    const connectionSubscribed = client.onConnectionStateChange((state) => {
      void NearLinkEventLogger.logSsapState(sessionId, `connectionState=${state.state}`);
      const mapped = SsapPlatformMapper.mapConnectionState(state.state);
      const tree = new SsapServiceTreeSnapshot(
        sessionId,
        deviceId,
        client.getMtu(),
        this.getLatestSsapTree().services,
        mapped
      );
      this.emitSsapTree(tree);
    });
    if (!connectionSubscribed.success) {
      return connectionSubscribed;
    }
    const mtuSubscribed = client.onMtuChange((mtu: number) => {
      void NearLinkEventLogger.logSsapMtu(sessionId, mtu);
      const tree = new SsapServiceTreeSnapshot(
        sessionId,
        deviceId,
        mtu,
        this.getLatestSsapTree().services,
        SsapClientState.CONNECTED
      );
      this.emitSsapTree(tree);
    });
    if (!mtuSubscribed.success) {
      return mtuSubscribed;
    }
    const propertySubscribed = client.onPropertyChange((property) => {
      const snapshot = SsapPlatformMapper.toPropertySnapshot(property);
      if (snapshot === undefined) {
        return;
      }
      dispatcher.handlePropertyChange(sessionId, snapshot, this.getLatestSsapTree());
      this.emitSsapTree(this.getLatestSsapTree());
    });
    return propertySubscribed;
  }

  releaseSsapClient(sessionId: string): void {
    const client = this.ssapClients.get(sessionId);
    if (client !== undefined) {
      client.release();
      this.ssapClients.delete(sessionId);
    }
    const boundAddress = this.ssapClientAddress.get(sessionId);
    if (boundAddress !== undefined) {
      this.ssapByAddress.delete(boundAddress);
    }
    this.ssapClientAddress.delete(sessionId);
    this.ssapDispatchers.delete(sessionId);
    this.ssapTransports.delete(sessionId);
  }

  releaseDataTransferSource(sessionId: string, uuid: string): void {
    this.detachDataTransferIncoming(sessionId);
    this.transferTransports.delete(sessionId);
    const source = this.dataTransferSources.get(sessionId);
    if (source !== undefined) {
      source.release(uuid);
      this.dataTransferSources.delete(sessionId);
    }
  }

  private handleDiscovery(payload: NearLinkDiscoveryPayload): void {
    const filter = this.activeFilter;
    let belowGate = false;
    if (filter !== undefined) {
      const systemRssi = this.scanDataSource.getRssiFilterMode() === 'system';
      const decision = NearLinkScanPolicy.applyLocal(
        payload.advertising.serviceUuids,
        payload.rssi,
        payload.rssiValid,
        filter.localServiceUuid,
        filter.localUuidFilterEnabled,
        filter.localRssiGate,
        filter.hasLocalRssiGate,
        systemRssi
      );
      if (!decision.visible) {
        return;
      }
      belowGate = decision.belowLocalRssiGate;
    }
    this.advertisingMap.set(payload.randomAddress, payload.advertising);
    const favorite = this.favoritesCache.some((f: DeviceFavoriteRecord) => f.address === payload.randomAddress);
    const aliasRecord = this.favoritesCache.find((f: DeviceFavoriteRecord) => f.address === payload.randomAddress);
    const device = NearLinkDeviceMapper.fromDiscovery(
      payload,
      favorite,
      aliasRecord?.alias ?? '',
      belowGate
    );
    this.merger.merge(device);
    this.devicesObservable.next(this.merger.listSorted());
    if (this.activeScanSessionId.length > 0) {
      const rawHex = payload.advertising.rawHex;
      const summary = `name=${device.displayName} rssi=${payload.rssi} services=${payload.advertising.serviceUuids.length}`;
      void NearLinkEventLogger.logAdvDiscovery(
        this.activeScanSessionId,
        NearLinkRepository.maskAddress(payload.randomAddress),
        rawHex,
        summary
      );
    }
  }

  private static maskAddress(address: string): string {
    const parts = address.split(':');
    if (parts.length < 2) {
      return '**';
    }
    return `${parts[0]}:${parts[1]}:**:**:**:**`;
  }

  currentApi(): number {
    return this.managerDataSource.currentApiVersion();
  }

  isEmulator(): boolean {
    return this.managerDataSource.isEmulator();
  }

  querySupport(): Result<NearLinkSupportQuery> {
    return this.managerDataSource.querySupported();
  }

  readRadio(): Result<NearLinkRadioSnapshot> {
    return this.managerDataSource.readRadio();
  }

  subscribeRadio(listener: (snapshot: NearLinkRadioSnapshot) => void): Result<void> {
    return this.managerDataSource.onStateChange(listener);
  }

  unsubscribeRadio(): void {
    this.managerDataSource.offStateChange();
  }

  subscribePairing(listener: (notice: NearLinkPairingNotice) => void): Result<void> {
    return this.managerDataSource.onPairingChange(listener);
  }

  unsubscribePairing(): void {
    this.managerDataSource.offPairingChange();
  }

  subscribeConnection(listener: (notice: NearLinkPairingNotice) => void): Result<void> {
    return this.managerDataSource.onConnectionChange(listener);
  }

  unsubscribeConnection(): void {
    this.managerDataSource.offConnectionChange();
  }

  readPairedDevices(): Result<string[]> {
    return this.managerDataSource.readPairedDevices();
  }

  readLocalName(): Result<string> {
    return this.managerDataSource.readLocalName();
  }

  startAdvertising(
    interval: number,
    connectable: boolean,
    includeDeviceName: boolean,
    serviceUuids: string[]
  ): Promise<Result<number>> {
    return this.advertisingSource.start(interval, connectable, includeDeviceName, serviceUuids);
  }

  stopAdvertising(): Promise<Result<void>> {
    return this.advertisingSource.stop(this.advertisingSource.getAdvertisingId());
  }

  hasSsapSession(sessionId: string): boolean {
    return this.ssapClients.has(sessionId);
  }

  ensureSsapClient(sessionId: string, address: string): Result<void> {
    const created = this.getOrCreateSsapClient(sessionId, address);
    if (!created.success) {
      return Result.fail(created.error ?? new ResultError(NearLinkErrorCodes.SSAP_CREATE_FAILED, 'create failed'));
    }
    return Result.ok(undefined);
  }

  connectSsapClient(sessionId: string): Promise<Result<void>> {
    const client = this.ssapClients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.SSAP_CONNECT_FAILED, 'api=connect')));
    }
    return client.connect();
  }

  disconnectSsapClient(sessionId: string): Promise<Result<void>> {
    const client = this.ssapClients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.ok(undefined));
    }
    return client.disconnect();
  }

  readSsapProperty(sessionId: string, serviceUuid: string, propertyUuid: string): Promise<Result<string>> {
    const client = this.ssapClients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP not connected')));
    }
    return client.readProperty(serviceUuid, propertyUuid);
  }

  writeSsapProperty(
    sessionId: string,
    serviceUuid: string,
    propertyUuid: string,
    data: ArrayBuffer
  ): Promise<Result<void>> {
    const client = this.ssapClients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP not connected')));
    }
    return client.writeProperty(serviceUuid, propertyUuid, data);
  }

  writeSsapByOperation(
    sessionId: string,
    serviceUuid: string,
    propertyUuid: string,
    data: ArrayBuffer,
    operation: number,
    withResponse: boolean
  ): Promise<Result<void>> {
    const client = this.ssapClients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=writeProperty')));
    }
    return client.writeByOperation(serviceUuid, propertyUuid, data, operation, withResponse);
  }

  notifySsap(
    sessionId: string,
    serviceUuid: string,
    propertyUuid: string,
    enable: boolean,
    operation: number,
    hasClientConfig: boolean
  ): Promise<Result<void>> {
    const client = this.ssapClients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=setPropertyNotification')));
    }
    return client.notifyByOperation(serviceUuid, propertyUuid, enable, operation, hasClientConfig);
  }

  setSsapNotification(
    sessionId: string,
    serviceUuid: string,
    propertyUuid: string,
    enable: boolean
  ): Promise<Result<void>> {
    const client = this.ssapClients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP not connected')));
    }
    return client.setPropertyNotification(serviceUuid, propertyUuid, enable);
  }

  requestSsapMtu(sessionId: string, mtu: number): Promise<Result<number>> {
    const client = this.ssapClients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=requestMtuSize')));
    }
    return client.requestMtuSize(mtu);
  }

  ssapMtu(sessionId: string): number {
    const client = this.ssapClients.get(sessionId);
    return client === undefined ? NearLinkConstants.DEFAULT_MTU : client.getMtu();
  }

  async attachSsapTransport(sessionId: string): Promise<Result<void>> {
    const transport = this.createSsapTransport(sessionId);
    if (transport === undefined) {
      return Result.ok(undefined);
    }
    const attachParams: Record<string, string | number | boolean> = {};
    await transport.connect(attachParams);
    this.ssapTransports.set(sessionId, transport);
    TransportSessionRegistry.getInstance().register(sessionId, transport);
    return Result.ok(undefined);
  }

  bindSsapEndpoints(sessionId: string, serviceUuid: string, propertyUuid: string): Result<void> {
    const transport = this.ssapTransports.get(sessionId);
    if (transport === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP transport not registered'));
    }
    return transport.bindEndpoints(serviceUuid, propertyUuid);
  }

  openServer(): Result<void> {
    return this.serverSource.open();
  }

  addServerService(serviceUuid: string, propertyUuid: string, operation: number): Result<void> {
    return this.serverSource.addPlainService(serviceUuid, propertyUuid, operation);
  }

  closeServer(): Result<void> {
    return this.serverSource.close();
  }

  removeServerService(serviceUuid: string): Result<void> {
    return this.serverSource.removeService(serviceUuid);
  }

  serverServices(): string[] {
    return this.serverSource.listServices();
  }

  watchServer(
    onWrite: (record: SsapServerWriteRecord) => void,
    onRead: (requestId: number, address: string, propertyUuid: string) => void
  ): void {
    this.serverSource.onWrite(onWrite);
    this.serverSource.onRead(onRead);
  }

  respondServerRead(requestId: number, address: string, value: ArrayBuffer): Result<void> {
    return this.serverSource.respondRead(requestId, address, value);
  }

  notifyServer(
    address: string,
    serviceUuid: string,
    propertyUuid: string,
    operation: number,
    value: ArrayBuffer
  ): Promise<Result<void>> {
    return this.serverSource.notifyPlain(address, serviceUuid, propertyUuid, operation, value);
  }

  createPort(uuid: string): Result<void> {
    return this.portSource.createPort(uuid);
  }

  connectPort(address: string, uuid: string, mtu: number, reliable: boolean): Promise<Result<void>> {
    return this.portSource.connect(address, uuid, mtu, reliable);
  }

  watchPortLink(onState: (address: string, uuid: string, mtu: number, state: number) => void): Result<void> {
    return this.portSource.watchLink(onState);
  }

  watchPortRead(onRead: (address: string, uuid: string, hex: string, byteLength: number) => void): Result<void> {
    return this.portSource.watchRead(onRead);
  }

  unwatchPortRead(): void {
    this.portSource.offReadData();
  }

  writePortData(address: string, uuid: string, data: ArrayBuffer): Promise<Result<void>> {
    return this.portSource.writeData(address, uuid, data);
  }

  disconnectPort(address: string, uuid: string): Promise<Result<void>> {
    return this.portSource.disconnect(address, uuid);
  }

  destroyPort(uuid: string): Result<void> {
    return this.portSource.destroyPort(uuid);
  }

  prepareRemote(address: string): Result<void> {
    return this.remoteSource.createRemoteDevice(address);
  }

  remoteIsPaired(): Result<boolean> {
    return this.remoteSource.isPaired();
  }

  remoteStartPairing(): Promise<Result<void>> {
    return this.remoteSource.startPairing();
  }

  remoteSecurity(): Result<NearLinkSecurityState> {
    const state = this.remoteSource.getAcbState();
    if (!state.success || state.value === undefined) {
      return Result.fail(state.error ?? new ResultError(NearLinkErrorCodes.VERSION_UNAVAILABLE, 'api=getAcbState'));
    }
    return Result.ok(this.remoteSource.resolveSecurityState(state.value));
  }

  exportText(text: string): Promise<Result<void>> {
    return NearLinkLogExportDataSource.copyText(text);
  }

  async connectDataTransfer(
    sessionId: string,
    address: string,
    uuid: string,
    mtu: number,
    policy: CongestionPolicy
  ): Promise<Result<void>> {
    const transport = this.createDataTransferTransport(sessionId, policy);
    const connectParams: Record<string, string | number | boolean> = {
      'address': address,
      'uuid': uuid,
      'mtu': mtu
    };
    try {
      await transport.connect(connectParams);
    } catch (error) {
      const err = error as Error;
      transport.destroy();
      return Result.fail(new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, err.message));
    }
    this.transferTransports.set(sessionId, transport);
    this.attachDataTransferIncoming(sessionId, transport);
    TransportSessionRegistry.getInstance().register(sessionId, transport);
    return Result.ok(undefined);
  }

  async writeDataTransfer(sessionId: string, bytes: Uint8Array): Promise<Result<string>> {
    const transport = this.transferTransports.get(sessionId);
    if (transport === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'dataTransfer not connected'));
    }
    const written = await transport.write(bytes);
    if (!written.success) {
      return Result.fail(new ResultError(written.appCode, written.message));
    }
    return Result.ok(written.appCode);
  }

  markInvalidRssiWarning(rssi: number): string {
    if (!NearLinkAdvParser.isRssiValid(rssi)) {
      return NearLinkErrorCodes.RSSI_INVALID;
    }
    return '';
  }
}
