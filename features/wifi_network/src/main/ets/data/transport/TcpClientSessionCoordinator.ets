import { Result, ResultError } from 'common_core';
import { TransportSessionRegistry } from 'feature_debug_core';
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
    const connected = await this.tcpDataSource.connectWithTimeout(params.host, params.port, params.timeoutMs);
    if (!connected.success || connected.value === undefined) {
      return Result.fail(connected.error ??
        new ResultError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, 'Connect failed'));
    }
    const transport = new TcpClientTransportSession(sessionId);
    transport.bindSocket(connected.value);
    this.transportRegistry.register(sessionId, transport);
    return Result.ok(undefined);
  }
}
