import { webSocket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Observable, Result, ResultError } from 'common_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { WebSocketClientPhase, WebSocketConfig, WebSocketMessageRecord } from '../../domain/model/WebSocketModels';
import { NetworkKitEventBridge } from '../kit/NetworkKitEventBridge';

/**
 * WebSocket client wrapper — connect() success != open per architecture wifi_network/03.
 */
export class WebSocketDataSource {
  private static instance: WebSocketDataSource | undefined;
  private client: webSocket.WebSocket | undefined;
  private phase: WebSocketClientPhase = WebSocketClientPhase.IDLE;
  private readonly phaseObservable: Observable<WebSocketClientPhase>;
  private readonly messageObservable: Observable<WebSocketMessageRecord[]>;
  private messages: WebSocketMessageRecord[] = [];
  private openHandler: (() => void) | undefined;
  private messageHandler: ((err: BusinessError, value: string | ArrayBuffer) => void) | undefined;
  private closeHandler: (() => void) | undefined;
  private errorHandler: ((err: BusinessError) => void) | undefined;

  private constructor() {
    this.phaseObservable = new Observable<WebSocketClientPhase>(WebSocketClientPhase.IDLE);
    this.messageObservable = new Observable<WebSocketMessageRecord[]>([]);
  }

  static getInstance(): WebSocketDataSource {
    if (WebSocketDataSource.instance === undefined) {
      WebSocketDataSource.instance = new WebSocketDataSource();
    }
    return WebSocketDataSource.instance;
  }

  getPhase(): WebSocketClientPhase {
    return this.phase;
  }

  observePhase(): Observable<WebSocketClientPhase> {
    return this.phaseObservable;
  }

  observeMessages(): Observable<WebSocketMessageRecord[]> {
    return this.messageObservable;
  }

  async connect(config: WebSocketConfig): Promise<Result<void>> {
    await this.disconnect();
    this.client = webSocket.createWebSocket();
    this.setPhase(WebSocketClientPhase.CREATING);
    this.registerHandlers();
    try {
      const created = await this.client.connect(config.url, { header: config.headers });
      if (!created) {
        this.setPhase(WebSocketClientPhase.FAILED);
        return Result.fail(new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'WebSocket connect request failed'));
      }
      this.setPhase(WebSocketClientPhase.CONNECTING);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      this.setPhase(WebSocketClientPhase.FAILED);
      return Result.fail(ResultError.fromBusinessError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, err));
    }
  }

  async sendText(text: string): Promise<Result<void>> {
    if (this.phase !== WebSocketClientPhase.OPEN || this.client === undefined) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'WebSocket not open'));
    }
    try {
      await this.client.send(text);
      this.appendMessage('outbound', 'text', text);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromBusinessError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, err));
    }
  }

  async disconnect(): Promise<void> {
    this.unregisterHandlers();
    if (this.client !== undefined) {
      try {
        await this.client.close();
      } catch (_e) {
      }
      this.client = undefined;
    }
    this.setPhase(WebSocketClientPhase.CLOSED);
  }

  private registerHandlers(): void {
    if (this.client === undefined) {
      return;
    }
    this.openHandler = () => {
      this.setPhase(WebSocketClientPhase.OPEN);
    };
    this.messageHandler = (_err: BusinessError, value: string | ArrayBuffer) => {
      const payload = typeof value === 'string' ? value : 'binary';
      this.appendMessage('inbound', typeof value === 'string' ? 'text' : 'binary', payload);
    };
    this.closeHandler = () => {
      this.setPhase(WebSocketClientPhase.CLOSED);
    };
    this.errorHandler = (_err: BusinessError) => {
      this.setPhase(WebSocketClientPhase.FAILED);
    };
    NetworkKitEventBridge.subscribeWebSocketOpen(this.client, this.openHandler);
    NetworkKitEventBridge.subscribeWebSocketMessage(this.client, this.messageHandler);
    NetworkKitEventBridge.subscribeWebSocketClose(this.client, this.closeHandler);
    NetworkKitEventBridge.subscribeWebSocketError(this.client, this.errorHandler);
  }

  private unregisterHandlers(): void {
    if (this.client === undefined) {
      return;
    }
    if (this.openHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeWebSocketOpen(this.client, this.openHandler);
    }
    if (this.messageHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeWebSocketMessage(this.client, this.messageHandler);
    }
    if (this.closeHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeWebSocketClose(this.client, this.closeHandler);
    }
    if (this.errorHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeWebSocketError(this.client, this.errorHandler);
    }
    this.openHandler = undefined;
    this.messageHandler = undefined;
    this.closeHandler = undefined;
    this.errorHandler = undefined;
  }

  private appendMessage(direction: string, messageType: string, payload: string): void {
    this.messages.push(new WebSocketMessageRecord(direction, messageType, payload, Date.now()));
    this.messageObservable.next(this.messages.slice());
  }

  private setPhase(phase: WebSocketClientPhase): void {
    this.phase = phase;
    this.phaseObservable.next(phase);
  }
}
