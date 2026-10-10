import { ssap } from '@kit.NearLinkKit';
import { DeviceFavoriteRecord } from 'common_storage';
import { Observable, Result, ResultError, Subscription, TimeUtil } from 'common_core';
import { ITransportSession, IncomingPayload, ModuleType, SessionRuntimeStore } from 'debug_core';
import {
  NearLinkManagerDataSource,
  NearLinkRadioCode,
  NearLinkRadioSnapshot
} from '../datasource/platform/NearLinkManagerDataSource';
import { NearLinkScanDataSource, NearLinkDiscoveryPayload } from '../datasource/platform/NearLinkScanDataSource';
import { SsapClientDataSource } from '../datasource/platform/SsapClientDataSource';
import { DataTransferDataSource } from '../datasource/platform/DataTransferDataSource';
import { NearLinkIdentityDataSource } from '../datasource/platform/NearLinkIdentityDataSource';
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
import {
  SsapClientState,
  SsapNotifyState,
  SsapPropertyNode,
  SsapServiceNode,
  SsapServiceTreeSnapshot
} from '../../domain/model/SsapServiceTree';
import { NearLinkConstants } from '../../constants/NearLinkConstants';
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
    const tree = NearLinkRepository.buildTree(sessionId, address, servicesResult.value, mtu, SsapClientState.READY);
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
  }

  releaseDataTransferSource(sessionId: string, uuid: string): void {
    this.detachDataTransferIncoming(sessionId);
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

  private static buildTree(
    sessionId: string,
    address: string,
    services: ssap.Service[],
    mtu: number,
    state: SsapClientState
  ): SsapServiceTreeSnapshot {
    const nodes: SsapServiceNode[] = [];
    for (let i = 0; i < services.length; i++) {
      const service = services[i];
      const properties: SsapPropertyNode[] = [];
      const props = service.properties ?? [];
      for (let j = 0; j < props.length; j++) {
        const operation = props[j].operation ?? 0;
        let hasClientConfig = false;
        const descriptors = props[j].descriptors ?? [];
        for (let k = 0; k < descriptors.length; k++) {
          if (descriptors[k].descriptorType === ssap.PropertyDescriptorType.CLIENT_PROPERTY_CONFIG) {
            hasClientConfig = true;
          }
        }
        const valueBytes = props[j].value === undefined ? new Uint8Array(0) : new Uint8Array(props[j].value);
        properties.push(new SsapPropertyNode(
          service.serviceUuid,
          props[j].propertyUuid,
          SsapNotifyState.DISABLED,
          NearLinkAdvParser.toHex(valueBytes),
          operation,
          hasClientConfig
        ));
      }
      nodes.push(new SsapServiceNode(service.serviceUuid, properties));
    }
    return new SsapServiceTreeSnapshot(sessionId, address, mtu, nodes, state);
  }

  markInvalidRssiWarning(rssi: number): string {
    if (!NearLinkAdvParser.isRssiValid(rssi)) {
      return NearLinkErrorCodes.RSSI_INVALID;
    }
    return '';
  }
}
