import { Observable, Result, ResultError } from 'common_core';
import { TransportSessionRegistry, TransportState, TransportStateSnapshot, WriteResult } from 'debug_core';
import { TcpSocketDataSource } from '../datasource/TcpSocketDataSource';
import { TcpClientTransportSession } from './TcpClientTransportSession';
import { SocketConnectionParams } from '../../domain/model/SocketModels';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';

/**
 * Owns TCP client socket connect + transport registration; use cases stay kit-free.
 */
export class TcpClientSessionCoordinator {
  private static instance: TcpClientSessionCoordinator | undefined;
  private readonly tcpDataSource: TcpSocketDataSource;
  private readonly transportRegistry: TransportSessionRegistry;

  private constructor(
    tcpDataSource: TcpSocketDataSource = TcpSocketDataSource.getInstance(),
    transportRegistry: TransportSessionRegistry = TransportSessionRegistry.getInstance()
  ) {
    this.tcpDataSource = tcpDataSource;
    this.transportRegistry = transportRegistry;
  }

  static getInstance(): TcpClientSessionCoordinator {
    if (TcpClientSessionCoordinator.instance === undefined) {
      TcpClientSessionCoordinator.instance = new TcpClientSessionCoordinator();
    }
    return TcpClientSessionCoordinator.instance;
  }

  async connectSession(sessionId: string, params: SocketConnectionParams): Promise<Result<void>> {
    const transport = new TcpClientTransportSession(sessionId);
    if (params.mode === 'tls') {
      const secured = await this.tcpDataSource.connectTls(params.host, params.port, params.timeoutMs);
      if (!secured.success || secured.value === undefined) {
        return Result.fail(secured.error ??
          new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'TLS connect failed'));
      }
      transport.bindTls(secured.value);
      this.transportRegistry.register(sessionId, transport);
      return Result.ok(undefined);
    }
    const connected = await this.tcpDataSource.connectWithTimeout(params.host, params.port, params.timeoutMs);
    if (!connected.success || connected.value === undefined) {
      return Result.fail(connected.error ??
        new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'Connect failed'));
    }
    transport.bindSocket(connected.value);
    this.transportRegistry.register(sessionId, transport);
    return Result.ok(undefined);
  }

  observeState(sessionId: string): Observable<TransportStateSnapshot> | undefined {
    const transport = this.transportRegistry.get(sessionId);
    if (transport === undefined) {
      return undefined;
    }
    return transport.observeState();
  }

  async sendText(sessionId: string, text: string): Promise<WriteResult> {
    const transport = this.transportRegistry.get(sessionId);
    if (transport === undefined || transport.state !== TransportState.CONNECTED) {
      return new WriteResult(false, 0, WifiNetworkErrorCodes.NOT_CONNECTED, '发送不可用');
    }
    return transport.write(TcpClientSessionCoordinator.toBytes(text));
  }

  async disconnect(sessionId: string): Promise<void> {
    const transport = this.transportRegistry.get(sessionId);
    if (transport !== undefined) {
      await transport.disconnect('tcp_disconnected');
      this.transportRegistry.remove(sessionId);
    }
  }

  private static toBytes(text: string): Uint8Array {
    const bytes = new Uint8Array(text.length);
    for (let i = 0; i < text.length; i++) {
      bytes[i] = text.charCodeAt(i) & 0xff;
    }
    return bytes;
  }
}
