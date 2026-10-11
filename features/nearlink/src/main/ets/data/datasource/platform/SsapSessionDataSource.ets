import { Observable, Result, ResultError } from 'common_core';
import { TransportSessionRegistry } from 'debug_core';
import { NearLinkConstants } from '../../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../../constants/NearLinkErrorCodes';
import { SsapPropertyNotifyPayload } from '../../../domain/model/SsapPropertyNotifyPayload';
import { SsapServerWriteRecord } from '../../../domain/model/SsapServerWriteRecord';
import { SsapClientState, SsapServiceTreeSnapshot } from '../../../domain/model/SsapServiceTree';
import { NearLinkEventLogger } from '../../../domain/service/NearLinkEventLogger';
import { SsapPlatformMapper } from '../../mapper/SsapPlatformMapper';
import { SsapPropertyChangeDispatcher } from '../../service/SsapPropertyChangeDispatcher';
import { SsapTransportSession } from '../../transport/SsapTransportSession';
import { SsapClientDataSource } from './SsapClientDataSource';
import { SsapServerDataSource } from './SsapServerDataSource';

/**
 * Owns SSAP client maps, the server instance, and SSAP transports.
 * Callers see domain snapshots and Result values.
 */
export class SsapSessionDataSource {
  private readonly clients: Map<string, SsapClientDataSource> = new Map();
  private readonly clientAddress: Map<string, string> = new Map();
  private readonly byAddress: Map<string, SsapClientDataSource> = new Map();
  private readonly dispatchers: Map<string, SsapPropertyChangeDispatcher> = new Map();
  private readonly transports: Map<string, SsapTransportSession> = new Map();
  private readonly serverSource: SsapServerDataSource = new SsapServerDataSource();
  private readonly treeObservable: Observable<SsapServiceTreeSnapshot>;

  constructor() {
    this.treeObservable = new Observable<SsapServiceTreeSnapshot>(
      new SsapServiceTreeSnapshot('', '', NearLinkConstants.DEFAULT_MTU, [], SsapClientState.IDLE)
    );
  }

  observeTree(): Observable<SsapServiceTreeSnapshot> {
    return this.treeObservable;
  }

  observePropertyNotify(sessionId: string): Observable<SsapPropertyNotifyPayload> {
    return this.getOrCreateDispatcher(sessionId).observeNotify();
  }

  hasClient(address: string): boolean {
    return this.findClient(address) !== undefined;
  }

  hasSession(sessionId: string): boolean {
    return this.clients.has(sessionId);
  }

  ensureClient(sessionId: string, address: string): Result<void> {
    const created = this.getOrCreateClient(sessionId, address);
    if (!created.success) {
      return Result.fail(created.error ?? new ResultError(NearLinkErrorCodes.SSAP_CREATE_FAILED, 'create failed'));
    }
    return Result.ok(undefined);
  }

  connect(sessionId: string): Promise<Result<void>> {
    const client = this.clients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.SSAP_CONNECT_FAILED, 'api=connect')));
    }
    return client.connect();
  }

  disconnect(sessionId: string): Promise<Result<void>> {
    const client = this.clients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.ok(undefined));
    }
    return client.disconnect();
  }

  async discover(sessionId: string, address: string, mtu: number): Promise<Result<SsapServiceTreeSnapshot>> {
    const clientResult = this.getOrCreateClient(sessionId, address);
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
    this.treeObservable.next(tree);
    return Result.ok(tree);
  }

  wire(sessionId: string, deviceId: string): Result<void> {
    const client = this.clients.get(sessionId);
    if (client === undefined) {
      return Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP client not created'));
    }
    const dispatcher = this.getOrCreateDispatcher(sessionId);
    const connectionSubscribed = client.onConnectionStateChange((state) => {
      void NearLinkEventLogger.logSsapState(sessionId, `connectionState=${state.state}`);
      const mapped = SsapPlatformMapper.mapConnectionState(state.state);
      const tree = new SsapServiceTreeSnapshot(
        sessionId,
        deviceId,
        client.getMtu(),
        this.treeObservable.snapshot.services,
        mapped
      );
      this.treeObservable.next(tree);
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
        this.treeObservable.snapshot.services,
        SsapClientState.CONNECTED
      );
      this.treeObservable.next(tree);
    });
    if (!mtuSubscribed.success) {
      return mtuSubscribed;
    }
    const propertySubscribed = client.onPropertyChange((property) => {
      const snapshot = SsapPlatformMapper.toPropertySnapshot(property);
      if (snapshot === undefined) {
        return;
      }
      dispatcher.handlePropertyChange(sessionId, snapshot, this.treeObservable.snapshot);
      this.treeObservable.next(this.treeObservable.snapshot);
    });
    return propertySubscribed;
  }

  release(sessionId: string): void {
    const client = this.clients.get(sessionId);
    if (client !== undefined) {
      client.release();
      this.clients.delete(sessionId);
    }
    const boundAddress = this.clientAddress.get(sessionId);
    if (boundAddress !== undefined) {
      this.byAddress.delete(boundAddress);
    }
    this.clientAddress.delete(sessionId);
    this.dispatchers.delete(sessionId);
    this.transports.delete(sessionId);
  }

  readProperty(sessionId: string, serviceUuid: string, propertyUuid: string): Promise<Result<string>> {
    const client = this.clients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP not connected')));
    }
    return client.readProperty(serviceUuid, propertyUuid);
  }

  writeProperty(
    sessionId: string,
    serviceUuid: string,
    propertyUuid: string,
    data: ArrayBuffer
  ): Promise<Result<void>> {
    const client = this.clients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP not connected')));
    }
    return client.writeProperty(serviceUuid, propertyUuid, data);
  }

  writeByOperation(
    sessionId: string,
    serviceUuid: string,
    propertyUuid: string,
    data: ArrayBuffer,
    operation: number,
    withResponse: boolean
  ): Promise<Result<void>> {
    const client = this.clients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=writeProperty')));
    }
    return client.writeByOperation(serviceUuid, propertyUuid, data, operation, withResponse);
  }

  notifyByOperation(
    sessionId: string,
    serviceUuid: string,
    propertyUuid: string,
    enable: boolean,
    operation: number,
    hasClientConfig: boolean
  ): Promise<Result<void>> {
    const client = this.clients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=setPropertyNotification')));
    }
    return client.notifyByOperation(serviceUuid, propertyUuid, enable, operation, hasClientConfig);
  }

  setNotification(
    sessionId: string,
    serviceUuid: string,
    propertyUuid: string,
    enable: boolean
  ): Promise<Result<void>> {
    const client = this.clients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'SSAP not connected')));
    }
    return client.setPropertyNotification(serviceUuid, propertyUuid, enable);
  }

  requestMtu(sessionId: string, mtu: number): Promise<Result<number>> {
    const client = this.clients.get(sessionId);
    if (client === undefined) {
      return Promise.resolve(Result.fail(new ResultError(NearLinkErrorCodes.NOT_CONNECTED, 'api=requestMtuSize')));
    }
    return client.requestMtuSize(mtu);
  }

  mtu(sessionId: string): number {
    const client = this.clients.get(sessionId);
    return client === undefined ? NearLinkConstants.DEFAULT_MTU : client.getMtu();
  }

  async attachTransport(sessionId: string): Promise<Result<void>> {
    const client = this.clients.get(sessionId);
    if (client === undefined) {
      return Result.ok(undefined);
    }
    const transport = new SsapTransportSession(sessionId, client);
    const attachParams: Record<string, string | number | boolean> = {};
    await transport.connect(attachParams);
    this.transports.set(sessionId, transport);
    TransportSessionRegistry.getInstance().register(sessionId, transport);
    return Result.ok(undefined);
  }

  bindEndpoints(sessionId: string, serviceUuid: string, propertyUuid: string): Result<void> {
    const transport = this.transports.get(sessionId);
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

  private getOrCreateDispatcher(sessionId: string): SsapPropertyChangeDispatcher {
    let dispatcher = this.dispatchers.get(sessionId);
    if (dispatcher === undefined) {
      dispatcher = new SsapPropertyChangeDispatcher();
      this.dispatchers.set(sessionId, dispatcher);
    }
    return dispatcher;
  }

  private getOrCreateClient(sessionId: string, address: string): Result<SsapClientDataSource> {
    const bound = this.findClient(address);
    if (bound !== undefined) {
      this.clients.set(sessionId, bound);
      this.clientAddress.set(sessionId, address);
      this.byAddress.set(address, bound);
      return Result.ok(bound);
    }
    let client = this.clients.get(sessionId);
    if (client === undefined) {
      client = new SsapClientDataSource();
      const created = client.createClient(address);
      if (!created.success) {
        return Result.fail(created.error ?? new ResultError(NearLinkErrorCodes.SSAP_CREATE_FAILED, 'create failed'));
      }
      this.clients.set(sessionId, client);
    }
    this.clientAddress.set(sessionId, address);
    this.byAddress.set(address, client);
    return Result.ok(client);
  }

  private findClient(address: string): SsapClientDataSource | undefined {
    return this.byAddress.get(address);
  }
}
