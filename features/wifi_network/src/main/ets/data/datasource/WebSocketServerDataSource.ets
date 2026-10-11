import { webSocket } from '@kit.NetworkKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { WifiNetworkConstants } from '../../constants/WifiNetworkConstants';
import { Observable, Result, ResultError } from 'common_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import {
  WebSocketServerClientRecord,
  WebSocketServerConfigModel,
  WebSocketServerPhase
} from '../../domain/model/WebSocketModels';
import { NetworkKitEventBridge } from '../kit/NetworkKitEventBridge';
type ConnectHandler = (client: webSocket.WebSocketConnection) => void;
type MessageReceiveHandler = (message: webSocket.WebSocketMessage) => void;

export class WebSocketServerDataSource {
  private static instance: WebSocketServerDataSource | undefined;
  private server: webSocket.WebSocketServer | undefined;
  private phase: WebSocketServerPhase = WebSocketServerPhase.IDLE;
  private clients: WebSocketServerClientRecord[] = [];
  private readonly connectionMap: Map<string, webSocket.WebSocketConnection> = new Map();
  private connectHandler: ConnectHandler | undefined;
  private messageHandler: MessageReceiveHandler | undefined;
  private readonly phaseObservable: Observable<WebSocketServerPhase>;
  private readonly clientsObservable: Observable<WebSocketServerClientRecord[]>;
  private constructor() {
    this.phaseObservable = new Observable<WebSocketServerPhase>(WebSocketServerPhase.IDLE);
    this.clientsObservable = new Observable<WebSocketServerClientRecord[]>([]);
  }
  static getInstance(): WebSocketServerDataSource {
    if (WebSocketServerDataSource.instance === undefined) {
      WebSocketServerDataSource.instance = new WebSocketServerDataSource();
    }
    return WebSocketServerDataSource.instance;
  }
  getPhase(): WebSocketServerPhase {
    return this.phase;
  }
  observePhase(): Observable<WebSocketServerPhase> {
    return this.phaseObservable;
  }
  observeClients(): Observable<WebSocketServerClientRecord[]> {
    return this.clientsObservable;
  }
  async start(config: WebSocketServerConfigModel): Promise<Result<void>> {
    if (deviceInfo.sdkApiVersion < WifiNetworkConstants.WEB_SOCKET_SERVER_MIN_API) {
      this.setPhase(WebSocketServerPhase.FAILED);
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.WS_SERVER_UNSUPPORTED,
        '当前系统版本没有该接口'
      ));
    }
    await this.stop();
    try {
      this.server = webSocket.createWebSocketServer();
      this.registerHandlers();
      const started = await this.server.start({
        serverPort: config.serverPort,
        maxConcurrentClientsNumber: config.maxClients,
        maxConnectionsForOneClient: config.maxConnectionsPerClient
      });
      if (!started) {
        this.setPhase(WebSocketServerPhase.FAILED);
        return Result.fail(new ResultError(WifiNetworkErrorCodes.PORT_IN_USE, 'WebSocket server start failed'));
      }
      this.setPhase(WebSocketServerPhase.LISTENING);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      this.setPhase(WebSocketServerPhase.FAILED);
      return Result.fail(ResultError.fromError(WifiNetworkErrorCodes.PORT_IN_USE, err));
    }
  }
  async sendToClient(clientId: string, text: string): Promise<Result<void>> {
    if (this.server === undefined) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NOT_CONNECTED, 'Server not running'));
    }
    const client = this.connectionMap.get(clientId);
    if (client === undefined) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NOT_CONNECTED, 'Client not found'));
    }
    try {
      const ok = await this.server.send(text, client);
      return ok ? Result.ok(undefined) :
        Result.fail(new ResultError(WifiNetworkErrorCodes.SOCKET_ERRNO, 'WebSocket send failed'));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(WifiNetworkErrorCodes.SOCKET_ERRNO, err));
    }
  }
  async broadcast(text: string): Promise<Result<void>> {
    if (this.server === undefined) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.NOT_CONNECTED, 'Server not running'));
    }
    for (let i = 0; i < this.clients.length; i++) {
      const client = this.connectionMap.get(this.clients[i].id);
      if (client !== undefined) {
        try {
          await this.server.send(text, client);
        } catch (_error) {
        }
      }
    }
    return Result.ok(undefined);
  }
  async stop(): Promise<void> {
    this.unregisterHandlers();
    if (this.server !== undefined) {
      try {
        await this.server.stop();
      } catch (_error) {
      }
      this.server = undefined;
    }
    this.clients = [];
    this.connectionMap.clear();
    this.clientsObservable.next([]);
    this.setPhase(WebSocketServerPhase.IDLE);
  }
  private registerHandlers(): void {
    if (this.server === undefined) {
      return;
    }
    this.connectHandler = (connection: webSocket.WebSocketConnection) => {
      const id = `${Date.now()}-${this.clients.length}`;
      this.connectionMap.set(id, connection);
      this.clients.push(new WebSocketServerClientRecord(id, connection.clientIP, connection.clientPort));
      this.clientsObservable.next(this.clients.slice());
    };
    this.messageHandler = (message: webSocket.WebSocketMessage) => {
      const connection = message.clientConnection;
      const id = this.findClientId(connection);
      if (id.length === 0) {
        return;
      }
      const payload = typeof message.data === 'string' ? message.data : 'binary';
      for (let i = 0; i < this.clients.length; i++) {
        if (this.clients[i].id === id) {
          this.clients[i] = new WebSocketServerClientRecord(
            this.clients[i].id,
            this.clients[i].remoteHost,
            this.clients[i].remotePort,
            payload,
            Date.now()
          );
          break;
        }
      }
      this.clientsObservable.next(this.clients.slice());
    };
    NetworkKitEventBridge.subscribeWebSocketServerConnect(this.server, this.connectHandler);
    NetworkKitEventBridge.subscribeWebSocketServerMessage(this.server, this.messageHandler);
  }
  private unregisterHandlers(): void {
    if (this.server === undefined) {
      return;
    }
    if (this.connectHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeWebSocketServerConnect(this.server, this.connectHandler);
    }
    if (this.messageHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeWebSocketServerMessage(this.server, this.messageHandler);
    }
    this.connectHandler = undefined;
    this.messageHandler = undefined;
  }
  private findClientId(connection: webSocket.WebSocketConnection): string {
    for (let i = 0; i < this.clients.length; i++) {
      const mapped = this.connectionMap.get(this.clients[i].id);
      if (mapped === connection) {
        return this.clients[i].id;
      }
    }
    return '';
  }
  private setPhase(phase: WebSocketServerPhase): void {
    this.phase = phase;
    this.phaseObservable.next(phase);
  }
}
