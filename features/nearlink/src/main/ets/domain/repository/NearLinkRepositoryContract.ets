import { Observable, Result } from 'common_core';
import { DeviceFavoriteRecord } from 'common_storage';
import { NearLinkDevice, NearLinkAdapterSnapshot, NearLinkOverviewSnapshot } from '../model/NearLinkDevice';
import { NearLinkScanFilter } from '../model/NearLinkScanFilter';
import { NearLinkScanPhase } from '../model/NearLinkScanPhase';
import { NearLinkAdvertisingPacket } from '../model/NearLinkAdvertisingPacket';
import { NearLinkRecentConnection } from '../model/NearLinkRecentConnection';
import { SsapServiceTreeSnapshot } from '../model/SsapServiceTree';
import { SsapPropertyNotifyPayload } from '../model/SsapPropertyNotifyPayload';
import { SsapServerWriteRecord } from '../model/SsapServerWriteRecord';
import { NearLinkPairingNotice, NearLinkRadioSnapshot, NearLinkSupportQuery } from '../model/NearLinkRadio';
import { NearLinkSecurityState } from '../model/NearLinkSecurityState';
import { CongestionPolicy, DataTransferPacket } from '../model/DataTransferPortConfig';

export interface NearLinkRepositoryContract {
  observeDevices(): Observable<NearLinkDevice[]>;
  observeAdapterState(): Observable<NearLinkAdapterSnapshot>;
  observeSsapTree(): Observable<SsapServiceTreeSnapshot>;
  observeSsapPropertyNotify(sessionId: string): Observable<SsapPropertyNotifyPayload>;
  observeDataTransferPackets(): Observable<DataTransferPacket>;
  getScanPhase(): NearLinkScanPhase;
  resetScanPhase(): void;
  loadAdapterState(): Promise<Result<NearLinkAdapterSnapshot>>;
  loadOverview(permissionGranted: boolean): Promise<NearLinkOverviewSnapshot>;
  startScan(sessionId: string, filter: NearLinkScanFilter): Promise<Result<void>>;
  stopScan(): Promise<Result<void>>;
  listDevices(): NearLinkDevice[];
  getAdvertising(address: string): NearLinkAdvertisingPacket | undefined;
  listRecentConnections(): NearLinkRecentConnection[];
  listFavorites(): DeviceFavoriteRecord[];
  saveFavorite(device: NearLinkDevice, alias: string, protocol: string, uuid?: string): Promise<Result<void>>;
  recordRecentConnection(deviceId: string, displayName: string, protocol: string): void;
  currentApi(): number;
  isEmulator(): boolean;
  querySupport(): Result<NearLinkSupportQuery>;
  readRadio(): Result<NearLinkRadioSnapshot>;
  subscribeRadio(listener: (snapshot: NearLinkRadioSnapshot) => void): Result<void>;
  unsubscribeRadio(): void;
  subscribePairing(listener: (notice: NearLinkPairingNotice) => void): Result<void>;
  unsubscribePairing(): void;
  subscribeConnection(listener: (notice: NearLinkPairingNotice) => void): Result<void>;
  unsubscribeConnection(): void;
  readPairedDevices(): Result<string[]>;
  readLocalName(): Result<string>;
  startAdvertising(
    interval: number,
    connectable: boolean,
    includeDeviceName: boolean,
    serviceUuids: string[]
  ): Promise<Result<number>>;
  stopAdvertising(): Promise<Result<void>>;
  hasSsapClient(address: string): boolean;
  hasSsapSession(sessionId: string): boolean;
  ensureSsapClient(sessionId: string, address: string): Result<void>;
  connectSsapClient(sessionId: string): Promise<Result<void>>;
  disconnectSsapClient(sessionId: string): Promise<Result<void>>;
  wireSsapClientSession(sessionId: string, deviceId: string): Result<void>;
  discoverSsapServices(sessionId: string, address: string, mtu: number): Promise<Result<SsapServiceTreeSnapshot>>;
  releaseSsapClient(sessionId: string): void;
  readSsapProperty(sessionId: string, serviceUuid: string, propertyUuid: string): Promise<Result<string>>;
  writeSsapProperty(
    sessionId: string,
    serviceUuid: string,
    propertyUuid: string,
    data: ArrayBuffer
  ): Promise<Result<void>>;
  writeSsapByOperation(
    sessionId: string,
    serviceUuid: string,
    propertyUuid: string,
    data: ArrayBuffer,
    operation: number,
    withResponse: boolean
  ): Promise<Result<void>>;
  notifySsap(
    sessionId: string,
    serviceUuid: string,
    propertyUuid: string,
    enable: boolean,
    operation: number,
    hasClientConfig: boolean
  ): Promise<Result<void>>;
  setSsapNotification(
    sessionId: string,
    serviceUuid: string,
    propertyUuid: string,
    enable: boolean
  ): Promise<Result<void>>;
  requestSsapMtu(sessionId: string, mtu: number): Promise<Result<number>>;
  ssapMtu(sessionId: string): number;
  attachSsapTransport(sessionId: string): Promise<Result<void>>;
  bindSsapEndpoints(sessionId: string, serviceUuid: string, propertyUuid: string): Result<void>;
  openServer(): Result<void>;
  addServerService(serviceUuid: string, propertyUuid: string, operation: number): Result<void>;
  closeServer(): Result<void>;
  removeServerService(serviceUuid: string): Result<void>;
  serverServices(): string[];
  watchServer(
    onWrite: (record: SsapServerWriteRecord) => void,
    onRead: (requestId: number, address: string, propertyUuid: string) => void
  ): void;
  respondServerRead(requestId: number, address: string, value: ArrayBuffer): Result<void>;
  notifyServer(
    address: string,
    serviceUuid: string,
    propertyUuid: string,
    operation: number,
    value: ArrayBuffer
  ): Promise<Result<void>>;
  createPort(uuid: string): Result<void>;
  connectPort(address: string, uuid: string, mtu: number, reliable: boolean): Promise<Result<void>>;
  watchPortLink(onState: (address: string, uuid: string, mtu: number, state: number) => void): Result<void>;
  watchPortRead(onRead: (address: string, uuid: string, hex: string, byteLength: number) => void): Result<void>;
  unwatchPortRead(): void;
  writePortData(address: string, uuid: string, data: ArrayBuffer): Promise<Result<void>>;
  disconnectPort(address: string, uuid: string): Promise<Result<void>>;
  destroyPort(uuid: string): Result<void>;
  prepareRemote(address: string): Result<void>;
  remoteIsPaired(): Result<boolean>;
  remoteStartPairing(): Promise<Result<void>>;
  remoteSecurity(): Result<NearLinkSecurityState>;
  exportText(text: string): Promise<Result<void>>;
  connectDataTransfer(
    sessionId: string,
    address: string,
    uuid: string,
    mtu: number,
    policy: CongestionPolicy
  ): Promise<Result<void>>;
  writeDataTransfer(sessionId: string, bytes: Uint8Array): Promise<Result<string>>;
  detachDataTransferIncoming(sessionId: string): void;
  releaseDataTransferSource(sessionId: string, uuid: string): void;
}
