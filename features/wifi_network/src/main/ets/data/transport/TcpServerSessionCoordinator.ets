import { socket } from '@kit.NetworkKit';
import { Result, ResultError } from 'common_core';
import { NetworkKitEventBridge } from '../kit/NetworkKitEventBridge';
import { TcpSocketDataSource } from '../datasource/TcpSocketDataSource';
import { TcpServerClientRegistry } from './TcpServerClientRegistry';
import { TcpServerClientRecord } from '../../domain/model/SocketModels';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';

/**
 * Owns TCP server socket lifecycle; ViewModel only sees domain client records.
 */
export class TcpServerSessionCoordinator {
  private static instance: TcpServerSessionCoordinator | undefined;
  private tcpServer: socket.TCPSocketServer | undefined;
  private serverConnectHandler: ((client: socket.TCPSocketConnection) => void) | undefined;
  private readonly clientRegistry: TcpServerClientRegistry = new TcpServerClientRegistry();
  private onClientMessage: ((clientId: string, text: string) => void) | undefined;
  private onClientsChanged: (() => void) | undefined;

  static getInstance(): TcpServerSessionCoordinator {
    if (TcpServerSessionCoordinator.instance === undefined) {
      TcpServerSessionCoordinator.instance = new TcpServerSessionCoordinator();
    }
    return TcpServerSessionCoordinator.instance;
  }

  setCallbacks(
    onClientMessage: (clientId: string, text: string) => void,
    onClientsChanged: () => void
  ): void {
    this.onClientMessage = onClientMessage;
    this.onClientsChanged = onClientsChanged;
  }

  async start(port: number): Promise<Result<void>> {
    await this.stop();
    const listen = await TcpSocketDataSource.getInstance().listen(port);
    if (!listen.success || listen.value === undefined) {
      return Result.fail(listen.error ?? new ResultError(WifiNetworkErrorCodes.SOCKET_ERRNO, 'Listen failed'));
    }
    this.tcpServer = listen.value;
    this.serverConnectHandler = (client: socket.TCPSocketConnection) => {
      const record = this.clientRegistry.add(client);
      this.notifyClientsChanged();
      NetworkKitEventBridge.subscribeTcpConnectionMessage(client, (value: socket.SocketMessageInfo) => {
        const text = typeof value.message === 'string'
          ? value.message
          : TcpServerSessionCoordinator.bytesToText(new Uint8Array(value.message as ArrayBuffer));
        this.clientRegistry.updateLastMessage(record.id, text);
        this.notifyClientsChanged();
        if (this.onClientMessage !== undefined) {
          this.onClientMessage(record.id, text);
        }
      });
    };
    NetworkKitEventBridge.subscribeTcpServerConnect(this.tcpServer, this.serverConnectHandler);
    return Result.ok(undefined);
  }

  async stop(): Promise<void> {
    if (this.tcpServer !== undefined && this.serverConnectHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeTcpServerConnect(this.tcpServer, this.serverConnectHandler);
    }
    this.serverConnectHandler = undefined;
    await this.clientRegistry.closeAll();
    if (this.tcpServer !== undefined) {
      try {
        await this.tcpServer.close();
      } catch (_error) {
      }
      this.tcpServer = undefined;
    }
    this.notifyClientsChanged();
  }

  isListening(): boolean {
    return this.tcpServer !== undefined;
  }

  listClients(): TcpServerClientRecord[] {
    return this.clientRegistry.listRecords();
  }

  async sendToClient(clientId: string, text: string): Promise<Result<void>> {
    const sent = await this.clientRegistry.sendText(clientId, text);
    if (!sent.success) {
      return Result.fail(sent.error ?? new ResultError(WifiNetworkErrorCodes.NOT_CONNECTED, 'Send failed'));
    }
    return Result.ok(undefined);
  }

  async disconnectClient(clientId: string): Promise<void> {
    await this.clientRegistry.disconnect(clientId);
    this.notifyClientsChanged();
  }

  private notifyClientsChanged(): void {
    if (this.onClientsChanged !== undefined) {
      this.onClientsChanged();
    }
  }

  private static bytesToText(bytes: Uint8Array): string {
    let text = '';
    for (let i = 0; i < bytes.length; i++) {
      text += String.fromCharCode(bytes[i]);
    }
    return text;
  }
}
