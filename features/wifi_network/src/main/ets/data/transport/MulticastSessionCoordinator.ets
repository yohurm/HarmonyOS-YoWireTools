import { socket } from '@kit.NetworkKit';
import { MulticastSocketDataSource } from '../datasource/MulticastSocketDataSource';
import { NetworkKitEventBridge } from '../kit/NetworkKitEventBridge';

/**
 * Owns multicast socket and message subscription for the active session.
 */
export class MulticastSessionCoordinator {
  private static instance: MulticastSessionCoordinator | undefined;
  private sessionId: string = '';
  private multicastSocket: socket.MulticastSocket | undefined;
  private messageHandler: ((value: socket.SocketMessageInfo) => void) | undefined;
  private onMessage: ((text: string) => void) | undefined;

  static getInstance(): MulticastSessionCoordinator {
    if (MulticastSessionCoordinator.instance === undefined) {
      MulticastSessionCoordinator.instance = new MulticastSessionCoordinator();
    }
    return MulticastSessionCoordinator.instance;
  }

  setMessageListener(listener: (text: string) => void): void {
    this.onMessage = listener;
  }

  attach(sessionId: string, multicastSocket: socket.MulticastSocket): void {
    this.detach();
    this.sessionId = sessionId;
    this.multicastSocket = multicastSocket;
    this.messageHandler = (value: socket.SocketMessageInfo) => {
      if (this.onMessage === undefined) {
        return;
      }
      const text = typeof value.message === 'string'
        ? value.message
        : MulticastSessionCoordinator.bytesToText(new Uint8Array(value.message as ArrayBuffer));
      this.onMessage(text);
    };
    NetworkKitEventBridge.subscribeMulticastMessage(multicastSocket, this.messageHandler);
  }

  async detach(): Promise<void> {
    if (this.multicastSocket !== undefined && this.messageHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeMulticastMessage(this.multicastSocket, this.messageHandler);
    }
    await MulticastSocketDataSource.getInstance().close(this.multicastSocket);
    this.multicastSocket = undefined;
    this.messageHandler = undefined;
    this.sessionId = '';
  }

  getSessionId(): string {
    return this.sessionId;
  }

  isJoined(): boolean {
    return this.multicastSocket !== undefined;
  }

  private static bytesToText(bytes: Uint8Array): string {
    let text = '';
    for (let i = 0; i < bytes.length; i++) {
      text += String.fromCharCode(bytes[i]);
    }
    return text;
  }
}
