import { Result, ResultError } from 'common_core';
import { NearLinkConstants } from '../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';
import { NearLinkAdvertisingDataSource } from '../../data/datasource/platform/NearLinkAdvertisingDataSource';
import { DataTransferDataSource } from '../../data/datasource/platform/DataTransferDataSource';
import { NearLinkLogExportDataSource } from '../../data/datasource/platform/NearLinkLogExportDataSource';
import {
  NearLinkManagerDataSource,
  NearLinkRadioSnapshot,
  NearLinkSupportQuery
} from '../../data/datasource/platform/NearLinkManagerDataSource';
import { RemoteDeviceDataSource } from '../../data/datasource/platform/RemoteDeviceDataSource';
import { SsapClientDataSource } from '../../data/datasource/platform/SsapClientDataSource';
import { SsapServerDataSource, SsapServerWriteRecord } from '../../data/datasource/platform/SsapServerDataSource';
import { NearLinkRepository } from '../../data/repository/NearLinkRepository';
import { NearLinkSecurityState } from '../model/NearLinkSecurityState';
import { NearLinkSlicePlan } from '../service/NearLinkDebugRules';
import { NearLinkPayloadRules } from '../service/NearLinkScanPolicy';

export class NearLinkPairedLookup {
  readonly versionUnavailable: boolean;
  readonly since: string;
  readonly addresses: string[];

  constructor(versionUnavailable: boolean, since: string, addresses: string[]) {
    this.versionUnavailable = versionUnavailable;
    this.since = since;
    this.addresses = addresses;
  }
}

export class NearLinkSessionUseCases {
  private readonly repository: NearLinkRepository;
  private readonly manager: NearLinkManagerDataSource;
  private readonly advertising: NearLinkAdvertisingDataSource;
  private readonly server: SsapServerDataSource;
  private readonly port: DataTransferDataSource;
  private readonly remote: RemoteDeviceDataSource;
  private ssapAddress: string = '';
  private ssapConnected: boolean = false;
  private notifyEnabled: boolean = false;
  private portUuid: string = '';
  private portAddress: string = '';
  private security: NearLinkSecurityState = NearLinkSecurityState.UNKNOWN;
  private txCount: number = 0;
  private rxCount: number = 0;

  constructor(repository: NearLinkRepository = NearLinkRepository.getInstance()) {
    this.repository = repository;
    this.manager = NearLinkManagerDataSource.getInstance();
    this.advertising = new NearLinkAdvertisingDataSource();
    this.server = new SsapServerDataSource();
    this.port = new DataTransferDataSource();
    this.remote = new RemoteDeviceDataSource();
  }

  currentApi(): number {
    return this.manager.currentApiVersion();
  }

  isEmulator(): boolean {
    return this.manager.isEmulator();
  }

  querySupport(): Result<NearLinkSupportQuery> {
    return this.manager.querySupported();
  }

  readRadio(): Result<NearLinkRadioSnapshot> {
    return this.manager.readRadio();
  }

  onRadio(listener: (code: number) => void): Result<void> {
    return this.manager.onStateChange((snapshot: NearLinkRadioSnapshot) => {
      listener(snapshot.code);
    });
  }

  offRadio(): void {
    this.manager.offStateChange();
  }

  onPairing(listener: (address: string, stateToken: string, reasonToken: string, reasonMsg: string) => void): Result<void> {
    return this.manager.onPairingChange((notice) => {
      listener(notice.address, notice.stateToken, notice.reasonToken, notice.reasonMsg);
    });
  }

  offPairing(): void {
    this.manager.offPairingChange();
  }

  onConnection(listener: (address: string, reasonMsg: string) => void): Result<void> {
    return this.manager.onConnectionChange((notice) => {
      listener(notice.address, notice.reasonMsg);
    });
  }

  offConnection(): void {
    this.manager.offConnectionChange();
  }

  systemRssiAvailable(): boolean {
    return this.currentApi() >= NearLinkConstants.API_RSSI_FILTER;
  }

  readPaired(): Result<NearLinkPairedLookup> {
    const listed = this.manager.readPairedDevices();
    if (!listed.success) {
      if (listed.error?.code === NearLinkErrorCodes.VERSION_UNAVAILABLE) {
        return Result.ok(new NearLinkPairedLookup(true, NearLinkConstants.SINCE_PAIRED_DEVICES, []));
      }
      return Result.fail(listed.error ?? new ResultError(NearLinkErrorCodes.UNSUPPORTED, 'api=getPairedDevices'));
    }
    return Result.ok(new NearLinkPairedLookup(false, '', listed.value ?? []));
  }

  readLocalName(): Result<string> {
    return this.manager.readLocalName();
  }

  async startAdvertising(
    interval: number,
    connectable: boolean,
    includeDeviceName: boolean,
    serviceUuids: string[]
  ): Promise<Result<number>> {
    return this.advertising.start(interval, connectable, includeDeviceName, serviceUuids);
  }

  async stopAdvertising(): Promise<Result<void>> {
    return this.advertising.stop(this.advertising.getAdvertisingId());
  }

  async connectSsap(address: string): Promise<Result<string>> {
    const reused = this.repository.hasSsapClient(address);
    const created = this.repository.getOrCreateSsapClient(address, address);
    if (!created.success || created.value === undefined) {
      return Result.fail(created.error ?? new ResultError(NearLinkErrorCodes.SSAP_CREATE_FAILED, 'api=createClient'));
    }
    const connected = await created.value.connect();
    if (!connected.success) {
      return Result.fail(connected.error ?? new ResultError(NearLinkErrorCodes.SSAP_CONNECT_FAILED, 'api=connect'));
    }
    this.ssapAddress = address;
    this.ssapConnected = true;
    this.repository.wireSsapClientSession(address, address);
    return Result.ok(reused ? 'reused' : 'created');
  }

  async disconnectSsap(): Promise<Result<void>> {
    const client = this.client();
    this.ssapConnected = false;
    this.notifyEnabled = false;
    if (client === undefined) {
      return Result.ok(undefined);
    }
    return client.disconnect();
  }

  async discoverSsap(): Promise<Result<void>> {
    if (!this.ssapConnected) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=getServices'));
    }
    const tree = await this.repository.discoverSsapServices(
      this.ssapAddress,
      this.ssapAddress,
      this.mtu()
    );
    if (!tree.success) {
      return Result.fail(tree.error ?? new ResultError(NearLinkErrorCodes.SSAP_DISCOVER_FAILED, 'api=getServices'));
    }
    return Result.ok(undefined);
  }

  async readProperty(serviceUuid: string, propertyUuid: string, operation: number): Promise<Result<string>> {
    if (!NearLinkPayloadRules.readable(operation)) {
      return Result.fail(new ResultError(NearLinkErrorCodes.SSAP_READ_FAILED, 'api=readProperty'));
    }
    const client = this.client();
    if (client === undefined || !this.ssapConnected) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=readProperty'));
    }
    return client.readProperty(serviceUuid, propertyUuid);
  }

  async writeProperty(
    serviceUuid: string,
    propertyUuid: string,
    hex: string,
    operation: number,
    withResponse: boolean,
    sliceConfirmed: boolean
  ): Promise<Result<number>> {
    if (!NearLinkPayloadRules.isEvenHex(hex)) {
      return Result.fail(new ResultError(NearLinkErrorCodes.HEX_INVALID, 'api=writeProperty'));
    }
    const client = this.client();
    if (client === undefined || !this.ssapConnected) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=writeProperty'));
    }
    const bytes = NearLinkPayloadRules.hexToBytes(hex);
    const plan = NearLinkSlicePlan.plan(bytes, this.mtu(), sliceConfirmed);
    if (!plan.success || plan.value === undefined) {
      return Result.fail(plan.error ?? new ResultError(NearLinkErrorCodes.VALIDATION, 'api=writeProperty'));
    }
    for (let i = 0; i < plan.value.length; i++) {
      const chunk = plan.value[i];
      const buffer = chunk.buffer.slice(chunk.byteOffset, chunk.byteOffset + chunk.byteLength);
      const written = await client.writeByOperation(serviceUuid, propertyUuid, buffer, operation, withResponse);
      if (!written.success) {
        return Result.fail(written.error ?? new ResultError(NearLinkErrorCodes.SSAP_WRITE_FAILED, 'api=writeProperty'));
      }
    }
    return Result.ok(plan.value.length);
  }

  async setNotify(
    serviceUuid: string,
    propertyUuid: string,
    enable: boolean,
    operation: number,
    hasClientConfig: boolean
  ): Promise<Result<void>> {
    if (!this.ssapConnected) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=setPropertyNotification'));
    }
    const client = this.client();
    if (client === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=setPropertyNotification'));
    }
    const result = await client.notifyByOperation(serviceUuid, propertyUuid, enable, operation, hasClientConfig);
    if (result.success) {
      this.notifyEnabled = enable;
    }
    return result;
  }

  async requestMtu(mtu: number): Promise<Result<number>> {
    if (!this.ssapConnected) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=requestMtuSize'));
    }
    const range = NearLinkPayloadRules.validateSsapMtu(mtu);
    if (!range.success) {
      return Result.fail(range.error ?? new ResultError(NearLinkErrorCodes.SSAP_MTU_RANGE, 'api=requestMtuSize'));
    }
    const client = this.client();
    if (client === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=requestMtuSize'));
    }
    return client.requestMtuSize(mtu);
  }

  notifyArmed(): boolean {
    return this.notifyEnabled && this.ssapConnected;
  }

  mtu(): number {
    const client = this.client();
    return client === undefined ? NearLinkConstants.DEFAULT_MTU : client.getMtu();
  }

  openServer(): Result<void> {
    return this.server.open();
  }

  addServerService(serviceUuid: string, propertyUuid: string, operation: number): Result<void> {
    return this.server.addPlainService(serviceUuid, propertyUuid, operation);
  }

  closeServer(): Result<void> {
    return this.server.close();
  }

  removeServerService(serviceUuid: string): Result<void> {
    return this.server.removeService(serviceUuid);
  }

  serverServices(): string[] {
    return this.server.listServices();
  }

  watchServer(
    onWrite: (record: SsapServerWriteRecord) => void,
    onRead: (requestId: number, address: string, propertyUuid: string) => void
  ): void {
    this.server.onWrite(onWrite);
    this.server.onRead(onRead);
  }

  createPort(uuid: string): Result<void> {
    const created = this.port.createPort(uuid);
    if (created.success) {
      this.portUuid = uuid;
    }
    return created;
  }

  async connectPort(address: string, mtuText: string, reliable: boolean): Promise<Result<void>> {
    if (this.currentApi() < NearLinkConstants.API_DATA_TRANSFER) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.VERSION_UNAVAILABLE,
        `api=connect;since=${NearLinkConstants.SINCE_DATA_TRANSFER}`
      ));
    }
    const provided = mtuText.trim().length > 0;
    const parsed = provided ? parseInt(mtuText.trim(), 10) : NearLinkConstants.PORT_MTU_DEFAULT;
    const mtu = NearLinkPayloadRules.validatePortMtu(Number.isNaN(parsed) ? -1 : parsed, provided);
    if (!mtu.success || mtu.value === undefined) {
      return Result.fail(mtu.error ?? new ResultError(NearLinkErrorCodes.DT_INVALID_PARAMS, 'api=connect'));
    }
    const connected = await this.port.connect(address, this.portUuid, mtu.value, reliable);
    if (connected.success) {
      this.portAddress = address;
      this.security = NearLinkSecurityState.UNKNOWN;
    }
    return connected;
  }

  async writePort(hex: string, blockUnlessEncrypted: boolean): Promise<Result<void>> {
    if (!NearLinkPayloadRules.isEvenHex(hex)) {
      return Result.fail(new ResultError(NearLinkErrorCodes.HEX_INVALID, 'api=writeData'));
    }
    if (blockUnlessEncrypted && this.security !== NearLinkSecurityState.ENCRYPTED) {
      return Result.fail(new ResultError(NearLinkErrorCodes.BLOCKED_UNENCRYPTED, 'api=writeData'));
    }
    const bytes = NearLinkPayloadRules.hexToBytes(hex);
    const buffer = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
    const written = await this.port.writeData(this.portAddress, this.portUuid, buffer);
    if (written.success) {
      this.txCount += bytes.length;
    }
    return written;
  }

  notePortRead(byteLength: number): void {
    this.rxCount += byteLength;
  }

  appTx(): number {
    return this.txCount;
  }

  appRx(): number {
    return this.rxCount;
  }

  async disconnectPort(): Promise<Result<void>> {
    return this.port.disconnect(this.portAddress, this.portUuid);
  }

  destroyPort(): Result<void> {
    const destroyed = this.port.destroyPort(this.portUuid);
    if (destroyed.success) {
      this.portUuid = '';
    }
    return destroyed;
  }

  async refreshEncryption(address: string): Promise<Result<NearLinkSecurityState>> {
    if (this.currentApi() < NearLinkConstants.API_PAIRING) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.VERSION_UNAVAILABLE,
        `api=getAcbState;since=${NearLinkConstants.SINCE_PAIRING}`
      ));
    }
    const created = this.remote.createRemoteDevice(address);
    if (!created.success) {
      return Result.fail(created.error ?? new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'api=createRemoteDevice'));
    }
    const state = this.remote.getAcbState();
    if (!state.success || state.value === undefined) {
      return Result.fail(state.error ?? new ResultError(NearLinkErrorCodes.VERSION_UNAVAILABLE, 'api=getAcbState'));
    }
    this.security = this.remote.resolveSecurityState(state.value);
    return Result.ok(this.security);
  }

  async startPairing(address: string): Promise<Result<string>> {
    if (this.currentApi() < NearLinkConstants.API_PAIRING) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.VERSION_UNAVAILABLE,
        `api=startPairing;since=${NearLinkConstants.SINCE_PAIRING}`
      ));
    }
    const created = this.remote.createRemoteDevice(address);
    if (!created.success) {
      return Result.fail(created.error ?? new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'api=createRemoteDevice'));
    }
    const paired = this.remote.isPaired();
    if (paired.success && paired.value === true) {
      return Result.ok('already_paired');
    }
    const started = await this.remote.startPairing();
    if (!started.success) {
      if (started.error?.code === NearLinkErrorCodes.ALREADY_PAIRED) {
        return Result.ok('already_paired');
      }
      return Result.fail(started.error ?? new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'api=startPairing'));
    }
    return Result.ok('requested');
  }

  securityState(): NearLinkSecurityState {
    return this.security;
  }

  async exportLog(text: string): Promise<Result<void>> {
    if (text.length === 0) {
      return Result.fail(new ResultError(NearLinkErrorCodes.VALIDATION, 'api=export'));
    }
    return NearLinkLogExportDataSource.copyText(text);
  }

  private client(): SsapClientDataSource | undefined {
    if (this.ssapAddress.length === 0) {
      return undefined;
    }
    return this.repository.getSsapClient(this.ssapAddress);
  }
}
