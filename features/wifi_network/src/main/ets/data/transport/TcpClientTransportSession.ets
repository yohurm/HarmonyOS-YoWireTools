import { IdGenerator, Observable, TimeUtil } from 'common_core';
import { socket } from '@kit.NetworkKit';
import {
  ITransportSession,
  IncomingPayload,
  ModuleType,
  ProtocolType,
  TransportCapabilities,
  TransportState,
  TransportStateSnapshot,
  WriteOptions,
  WriteResult
} from 'debug_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { NetworkKitEventBridge } from '../kit/NetworkKitEventBridge';

/**
 * TCP client transport session with unified logging per architecture 03-搂6.1.
 */
export class TcpClientTransportSession implements ITransportSession {
  readonly id: string;
  readonly module: ModuleType = ModuleType.WIFI;
  readonly protocol: ProtocolType = ProtocolType.TCP_CLIENT;
  readonly capabilities: TransportCapabilities;
  private currentState: TransportState = TransportState.IDLE;
  private tcpSocket: socket.TCPSocket | undefined;
  private readonly incomingObservable: Observable<IncomingPayload>;
  private readonly stateObservable: Observable<TransportStateSnapshot>;

  constructor(sessionId: string = '') {
    this.id = sessionId.length > 0 ? sessionId : IdGenerator.next('tcp');
    this.capabilities = new TransportCapabilities(true, false, 65536, true, false, true, false, true, false);
    this.incomingObservable = new Observable<IncomingPayload>(new IncomingPayload(new Uint8Array(0), 0));
    this.stateObservable = new Observable<TransportStateSnapshot>(new TransportStateSnapshot(TransportState.IDLE));
  }

  get state(): TransportState {
    return this.currentState;
  }

  bindSocket(tcp: socket.TCPSocket): void {
    this.tcpSocket = tcp;
    this.transition(TransportState.CONNECTED);
    NetworkKitEventBridge.subscribeTcpMessage(tcp, (value: socket.SocketMessageInfo) => {
      if (typeof value.message === 'string') {
        const bytes = TcpClientTransportSession.textToBytes(value.message);
        this.incomingObservable.next(new IncomingPayload(bytes, TimeUtil.nowMs(), false));
      }
    });
  }

  async connect(_params: Record<string, string | number | boolean>): Promise<void> {
    this.transition(TransportState.CONNECTING);
  }

  async disconnect(_reason: string): Promise<void> {
    this.transition(TransportState.DISCONNECTING);
    if (this.tcpSocket !== undefined) {
      try {
        await this.tcpSocket.close();
      } catch (_error) {
      }
      this.tcpSocket = undefined;
    }
    this.transition(TransportState.DISCONNECTED);
  }

  async write(payload: Uint8Array, _options?: WriteOptions): Promise<WriteResult> {
    if (this.tcpSocket === undefined || this.currentState !== TransportState.CONNECTED) {
      return new WriteResult(false, 0, WifiNetworkErrorCodes.NOT_CONNECTED, 'TCP not connected');
    }
    try {
      await this.tcpSocket.send({ data: payload.buffer });
      return new WriteResult(true, payload.length);
    } catch (error) {
      const err = error as Error;
      return new WriteResult(false, 0, WifiNetworkErrorCodes.SOCKET_ERRNO, err.message);
    }
  }

  observeIncoming(): Observable<IncomingPayload> {
    return this.incomingObservable;
  }

  observeState(): Observable<TransportStateSnapshot> {
    return this.stateObservable;
  }

  destroy(): void {
    void this.disconnect('destroy');
    this.incomingObservable.clearObservers();
    this.stateObservable.clearObservers();
  }

  private transition(state: TransportState, reason: string = ''): void {
    this.currentState = state;
    this.stateObservable.next(new TransportStateSnapshot(state, reason, TimeUtil.nowMs()));
  }

  private static textToBytes(text: string): Uint8Array {
    const bytes = new Uint8Array(text.length);
    for (let i = 0; i < text.length; i++) {
      bytes[i] = text.charCodeAt(i);
    }
    return bytes;
  }
}
