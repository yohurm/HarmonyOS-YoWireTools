import { Result, ResultError, Subscription } from 'common_core';
import { NearLinkConstants } from '../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../constants/NearLinkErrorCodes';
import { NearLinkRepositoryContract } from '../repository/NearLinkRepositoryContract';
import { NearLinkAdvertisingPacket } from '../model/NearLinkAdvertisingPacket';
import { NearLinkPairingNotice, NearLinkRadioSnapshot, NearLinkSupportQuery } from '../model/NearLinkRadio';
import { NearLinkSecurityState } from '../model/NearLinkSecurityState';
import { SsapServerWriteRecord } from '../model/SsapServerWriteRecord';
import { SsapServiceTreeSnapshot } from '../model/SsapServiceTree';
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
  private readonly repository: NearLinkRepositoryContract;
  private ssapAddress: string = '';
  private ssapConnected: boolean = false;
  private notifyEnabled: boolean = false;
  private portUuid: string = '';
  private portAddress: string = '';
  private security: NearLinkSecurityState = NearLinkSecurityState.UNKNOWN;
  private txCount: number = 0;
  private rxCount: number = 0;
  private txPackets: number = 0;
  private rxPackets: number = 0;
  private portMtuNegotiated: number = 0;
  private nextWriteAt: number = 0;

  constructor(repository: NearLinkRepositoryContract) {
    this.repository = repository;
  }

  currentApi(): number {
    return this.repository.currentApi();
  }

  isEmulator(): boolean {
    return this.repository.isEmulator();
  }

  querySupport(): Result<NearLinkSupportQuery> {
    return this.repository.querySupport();
  }

  readRadio(): Result<NearLinkRadioSnapshot> {
    return this.repository.readRadio();
  }

  onRadio(listener: (code: number) => void): Result<void> {
    return this.repository.subscribeRadio((snapshot: NearLinkRadioSnapshot) => {
      listener(snapshot.code);
    });
  }

  offRadio(): void {
    this.repository.unsubscribeRadio();
  }

  onPairing(listener: (address: string, stateToken: string, reasonToken: string, reasonMsg: string) => void): Result<void> {
    return this.repository.subscribePairing((notice: NearLinkPairingNotice) => {
      listener(notice.address, notice.stateToken, notice.reasonToken, notice.reasonMsg);
    });
  }

  offPairing(): void {
    this.repository.unsubscribePairing();
  }

  onConnection(listener: (address: string, reasonMsg: string) => void): Result<void> {
    return this.repository.subscribeConnection((notice: NearLinkPairingNotice) => {
      listener(notice.address, notice.reasonMsg);
    });
  }

  offConnection(): void {
    this.repository.unsubscribeConnection();
  }

  systemRssiAvailable(): boolean {
    return this.currentApi() >= NearLinkConstants.API_RSSI_FILTER;
  }

  readPaired(): Result<NearLinkPairedLookup> {
    const listed = this.repository.readPairedDevices();
    if (!listed.success) {
      if (listed.error?.code === NearLinkErrorCodes.VERSION_UNAVAILABLE) {
        return Result.ok(new NearLinkPairedLookup(true, NearLinkConstants.SINCE_PAIRED_DEVICES, []));
      }
      return Result.fail(listed.error ?? new ResultError(NearLinkErrorCodes.UNSUPPORTED, 'api=getPairedDevices'));
    }
    return Result.ok(new NearLinkPairedLookup(false, '', listed.value ?? []));
  }

  readLocalName(): Result<string> {
    return this.repository.readLocalName();
  }

  observeServices(listener: (tree: SsapServiceTreeSnapshot) => void): Subscription {
    return this.repository.observeSsapTree().subscribe(listener);
  }

  advertisingOf(address: string): NearLinkAdvertisingPacket | undefined {
    return this.repository.getAdvertising(address);
  }

  async startAdvertising(
    interval: number,
    connectable: boolean,
    includeDeviceName: boolean,
    serviceUuids: string[]
  ): Promise<Result<number>> {
    return this.repository.startAdvertising(interval, connectable, includeDeviceName, serviceUuids);
  }

  async stopAdvertising(): Promise<Result<void>> {
    return this.repository.stopAdvertising();
  }

  async connectSsap(address: string): Promise<Result<string>> {
    const reused = this.repository.hasSsapClient(address);
    const created = this.repository.ensureSsapClient(address, address);
    if (!created.success) {
      return Result.fail(created.error ?? new ResultError(NearLinkErrorCodes.SSAP_CREATE_FAILED, 'api=createClient'));
    }
    const connected = await this.repository.connectSsapClient(address);
    if (!connected.success) {
      return Result.fail(connected.error ?? new ResultError(NearLinkErrorCodes.SSAP_CONNECT_FAILED, 'api=connect'));
    }
    this.ssapAddress = address;
    this.ssapConnected = true;
    this.repository.wireSsapClientSession(address, address);
    return Result.ok(reused ? 'reused' : 'created');
  }

  async disconnectSsap(): Promise<Result<void>> {
    this.ssapConnected = false;
    this.notifyEnabled = false;
    if (this.ssapAddress.length === 0) {
      return Result.ok(undefined);
    }
    return this.repository.disconnectSsapClient(this.ssapAddress);
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
    if (!this.ssapConnected || !this.repository.hasSsapSession(this.ssapAddress)) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=readProperty'));
    }
    return this.repository.readSsapProperty(this.ssapAddress, serviceUuid, propertyUuid);
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
    if (!this.ssapConnected || !this.repository.hasSsapSession(this.ssapAddress)) {
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
      const written = await this.repository.writeSsapByOperation(
        this.ssapAddress,
        serviceUuid,
        propertyUuid,
        buffer,
        operation,
        withResponse
      );
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
    if (!this.ssapConnected || !this.repository.hasSsapSession(this.ssapAddress)) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=setPropertyNotification'));
    }
    const result = await this.repository.notifySsap(
      this.ssapAddress,
      serviceUuid,
      propertyUuid,
      enable,
      operation,
      hasClientConfig
    );
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
    if (!this.repository.hasSsapSession(this.ssapAddress)) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=requestMtuSize'));
    }
    return this.repository.requestSsapMtu(this.ssapAddress, mtu);
  }

  notifyArmed(): boolean {
    return this.notifyEnabled && this.ssapConnected;
  }

  mtu(): number {
    return this.repository.ssapMtu(this.ssapAddress);
  }

  openServer(): Result<void> {
    return this.repository.openServer();
  }

  addServerService(serviceUuid: string, propertyUuid: string, operation: number): Result<void> {
    return this.repository.addServerService(serviceUuid, propertyUuid, operation);
  }

  closeServer(): Result<void> {
    return this.repository.closeServer();
  }

  removeServerService(serviceUuid: string): Result<void> {
    return this.repository.removeServerService(serviceUuid);
  }

  serverServices(): string[] {
    return this.repository.serverServices();
  }

  watchServer(
    onWrite: (record: SsapServerWriteRecord) => void,
    onRead: (requestId: number, address: string, propertyUuid: string) => void
  ): void {
    this.repository.watchServer(onWrite, onRead);
  }

  createPort(uuid: string): Result<void> {
    const created = this.repository.createPort(uuid);
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
    const connected = await this.repository.connectPort(address, this.portUuid, mtu.value, reliable);
    if (connected.success) {
      this.portAddress = address;
      this.security = NearLinkSecurityState.UNKNOWN;
    }
    return connected;
  }

  async writePort(hex: string, blockUnlessEncrypted: boolean, sliceConfirmed: boolean = false): Promise<Result<void>> {
    if (!NearLinkPayloadRules.isEvenHex(hex)) {
      return Result.fail(new ResultError(NearLinkErrorCodes.HEX_INVALID, 'api=writeData'));
    }
    return this.writePortBytes(NearLinkPayloadRules.hexToBytes(hex), blockUnlessEncrypted, sliceConfirmed);
  }

  async writePortText(text: string, blockUnlessEncrypted: boolean, sliceConfirmed: boolean = false): Promise<Result<void>> {
    if (text.length === 0) {
      return Result.fail(new ResultError(NearLinkErrorCodes.VALIDATION, 'api=writeData;field=text'));
    }
    return this.writePortBytes(NearLinkPayloadRules.utf8Bytes(text), blockUnlessEncrypted, sliceConfirmed);
  }

  notePortLink(mtu: number, connected: boolean): void {
    if (connected && mtu > 0) {
      this.portMtuNegotiated = mtu;
    }
    if (!connected) {
      this.portMtuNegotiated = 0;
    }
  }

  portMtu(): number {
    return this.portMtuNegotiated;
  }

  watchPort(
    onState: (address: string, uuid: string, mtu: number, state: number) => void,
    onRead: (address: string, uuid: string, hex: string, byteLength: number) => void
  ): Result<void> {
    const linked = this.repository.watchPortLink(onState);
    if (!linked.success) {
      return linked;
    }
    return this.repository.watchPortRead(onRead);
  }

  unwatchPortRead(): void {
    this.repository.unwatchPortRead();
  }

  async respondServerRead(requestId: number, address: string, hex: string): Promise<Result<void>> {
    if (hex.length > 0 && !NearLinkPayloadRules.isEvenHex(hex)) {
      return Result.fail(new ResultError(NearLinkErrorCodes.HEX_INVALID, 'api=sendResponse'));
    }
    const bytes = hex.length === 0 ? new Uint8Array(0) : NearLinkPayloadRules.hexToBytes(hex);
    const buffer = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
    return this.repository.respondServerRead(requestId, address, buffer);
  }

  notifyServer(
    address: string,
    serviceUuid: string,
    propertyUuid: string,
    operation: number,
    hex: string
  ): Promise<Result<void>> {
    if (hex.length > 0 && !NearLinkPayloadRules.isEvenHex(hex)) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.HEX_INVALID, 'api=notifyPropertyChanged')));
    }
    const bytes = hex.length === 0 ? new Uint8Array(0) : NearLinkPayloadRules.hexToBytes(hex);
    const buffer = bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
    return this.repository.notifyServer(address, serviceUuid, propertyUuid, operation, buffer);
  }

  appTx(): number {
    return this.txCount;
  }

  appRx(): number {
    return this.rxCount;
  }

  appTxPackets(): number {
    return this.txPackets;
  }

  appRxPackets(): number {
    return this.rxPackets;
  }

  notePortRead(byteLength: number): void {
    this.rxCount += byteLength;
    this.rxPackets += 1;
  }

  async disconnectPort(): Promise<Result<void>> {
    this.repository.unwatchPortRead();
    return this.repository.disconnectPort(this.portAddress, this.portUuid);
  }

  destroyPort(): Result<void> {
    const destroyed = this.repository.destroyPort(this.portUuid);
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
    const created = this.repository.prepareRemote(address);
    if (!created.success) {
      return Result.fail(created.error ?? new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'api=createRemoteDevice'));
    }
    const state = this.repository.remoteSecurity();
    if (!state.success || state.value === undefined) {
      return Result.fail(state.error ?? new ResultError(NearLinkErrorCodes.VERSION_UNAVAILABLE, 'api=getAcbState'));
    }
    this.security = state.value;
    return Result.ok(this.security);
  }

  async startPairing(address: string): Promise<Result<string>> {
    if (this.currentApi() < NearLinkConstants.API_PAIRING) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.VERSION_UNAVAILABLE,
        `api=startPairing;since=${NearLinkConstants.SINCE_PAIRING}`
      ));
    }
    const created = this.repository.prepareRemote(address);
    if (!created.success) {
      return Result.fail(created.error ?? new ResultError(NearLinkErrorCodes.DT_GENERIC_FAILED, 'api=createRemoteDevice'));
    }
    const paired = this.repository.remoteIsPaired();
    if (paired.success && paired.value === true) {
      return Result.ok('already_paired');
    }
    const started = await this.repository.remoteStartPairing();
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
    return this.repository.exportText(text);
  }

  private async writePortBytes(
    bytes: Uint8Array,
    blockUnlessEncrypted: boolean,
    sliceConfirmed: boolean
  ): Promise<Result<void>> {
    if (blockUnlessEncrypted && this.security !== NearLinkSecurityState.ENCRYPTED) {
      return Result.fail(new ResultError(NearLinkErrorCodes.BLOCKED_UNENCRYPTED, 'api=writeData'));
    }
    if (this.portMtuNegotiated > 0 &&
      NearLinkPayloadRules.exceedsMtu(bytes.length, this.portMtuNegotiated) &&
      !sliceConfirmed) {
      return Result.fail(new ResultError(
        NearLinkErrorCodes.VALIDATION,
        `api=writeData;slice=required;mtu=${this.portMtuNegotiated}`
      ));
    }
    const now = Date.now();
    if (now < this.nextWriteAt) {
      await this.waitMs(this.nextWriteAt - now);
    }
    const limit = this.portMtuNegotiated > 0 ? this.portMtuNegotiated : bytes.length;
    const plan = NearLinkSlicePlan.plan(bytes, limit, true);
    const chunks = plan.value ?? [];
    for (let i = 0; i < chunks.length; i++) {
      if (i > 0) {
        await this.waitMs(NearLinkConstants.CONGESTION_MIN_GAP_MS);
      }
      const payload = chunks[i];
      const buffer = payload.buffer.slice(payload.byteOffset, payload.byteOffset + payload.byteLength);
      const written = await this.repository.writePortData(this.portAddress, this.portUuid, buffer);
      if (!written.success && written.error?.code === NearLinkErrorCodes.DT_WRITE_CONGESTED) {
        this.nextWriteAt = Date.now() + NearLinkConstants.CONGESTION_MIN_GAP_MS;
        return written;
      }
      if (!written.success) {
        return written;
      }
      this.txCount += payload.byteLength;
      this.txPackets += 1;
    }
    return Result.ok(undefined);
  }

  private waitMs(ms: number): Promise<void> {
    return new Promise<void>((resolve: () => void) => {
      setTimeout(() => {
        resolve();
      }, ms);
    });
  }
}
