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
 * UDP datagram transport session per architecture 03-搂6.3.
 */

export class UdpTransportSession implements ITransportSession {
  readonly id: string;
  readonly module: ModuleType = ModuleType.WIFI;
  readonly protocol: ProtocolType = ProtocolType.UDP;
  readonly capabilities: TransportCapabilities;
  private currentState: TransportState = TransportState.IDLE;
  private udpSocket: socket.UDPSocket | undefined;
  private remoteHost: string = '';
  private remotePort: number = 0;
  private readonly incomingObservable: Observable<IncomingPayload>;
  private readonly stateObservable: Observable<TransportStateSnapshot>;
  constructor(sessionId: string = '') {
    this.id = sessionId.length > 0 ? sessionId : IdGenerator.next('udp');
    this.capabilities = new TransportCapabilities(false, true, 65507, true, false, true, false, true, false);
    this.incomingObservable = new Observable<IncomingPayload>(new IncomingPayload(new Uint8Array(0), 0));
    this.stateObservable = new Observable<TransportStateSnapshot>(new TransportStateSnapshot(TransportState.IDLE));
  }
  get state(): TransportState {
    return this.currentState;
  }
  getSocket(): socket.UDPSocket | undefined {
    return this.udpSocket;
  }
  bindSocket(udp: socket.UDPSocket, remoteHost: string, remotePort: number): void {
    this.udpSocket = udp;
    this.remoteHost = remoteHost;
    this.remotePort = remotePort;
    this.transition(TransportState.CONNECTED);
    NetworkKitEventBridge.subscribeUdpMessage(udp, (value: socket.SocketMessageInfo) => {
      const payload = UdpTransportSession.messageToBytes(value.message);
      this.incomingObservable.next(new IncomingPayload(payload, TimeUtil.nowMs(), true));
    });
  }
  setRemoteTarget(host: string, port: number): void {
    this.remoteHost = host;
    this.remotePort = port;
  }
  async connect(_params: Record<string, string | number | boolean>): Promise<void> {
    this.transition(TransportState.CONNECTING);
    this.transition(TransportState.CONNECTED);
  }
  async disconnect(_reason: string): Promise<void> {
    this.transition(TransportState.DISCONNECTING);
    if (this.udpSocket !== undefined) {
      try {
        await this.udpSocket.close();
      } catch (_error) {
      }
      this.udpSocket = undefined;
    }
    this.transition(TransportState.DISCONNECTED);
  }
  async write(payload: Uint8Array, _options?: WriteOptions): Promise<WriteResult> {
    if (this.udpSocket === undefined) {
      return new WriteResult(false, 0, WifiNetworkErrorCodes.UDP_NOT_BOUND, 'UDP not bound');
    }
    if (this.remoteHost.length === 0 || this.remotePort <= 0) {
      return new WriteResult(false, 0, WifiNetworkErrorCodes.NOT_CONNECTED, 'Remote target required');
    }
    try {
      await this.udpSocket.send({
        data: payload.buffer,
        address: { address: this.remoteHost, port: this.remotePort, family: 1 }
      });
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
  private static messageToBytes(message: string | ArrayBuffer): Uint8Array {
    if (typeof message === 'string') {
      const bytes = new Uint8Array(message.length);
      for (let i = 0; i < message.length; i++) {
        bytes[i] = message.charCodeAt(i);
      }
      return bytes;
    }
    return new Uint8Array(message);
  }
}
