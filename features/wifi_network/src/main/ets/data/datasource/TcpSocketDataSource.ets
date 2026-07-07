import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { PortProbeResult, PortProbeState } from '../../domain/model/LanDiscoveryModels';

/**
 * TCP socket operations wrapper per architecture wifi_network/02.
 */
export class TcpSocketDataSource {
  private static instance: TcpSocketDataSource | undefined;

  static getInstance(): TcpSocketDataSource {
    if (TcpSocketDataSource.instance === undefined) {
      TcpSocketDataSource.instance = new TcpSocketDataSource();
    }
    return TcpSocketDataSource.instance;
  }

  createClient(): socket.TCPSocket {
    return socket.constructTCPSocketInstance();
  }

  async probeConnect(host: string, port: number, timeoutMs: number): Promise<PortProbeResult> {
    const start = Date.now();
    const tcp = this.createClient();
    try {
      await tcp.connect({ address: { address: host, port: port, family: 1 } });
      const latency = Date.now() - start;
      await tcp.close();
      return new PortProbeResult(host, port, 'tcp', PortProbeState.OPEN, latency);
    } catch (error) {
      const err = error as BusinessError;
      const latency = Date.now() - start;
      return new PortProbeResult(
        host,
        port,
        'tcp',
        PortProbeState.CLOSED,
        latency,
        `${err.code ?? ''}: ${err.message ?? ''}`
      );
    }
  }

  async connectWithTimeout(
    host: string,
    port: number,
    timeoutMs: number
  ): Promise<Result<socket.TCPSocket>> {
    const tcp = this.createClient();
    try {
      const connectPromise = tcp.connect({ address: { address: host, port: port, family: 1 } });
      const timeoutPromise = new Promise<void>((_, reject) => {
        setTimeout(() => reject(new Error('connect timeout')), timeoutMs);
      });
      await Promise.race([connectPromise, timeoutPromise]);
      return Result.ok(tcp);
    } catch (error) {
      try {
        await tcp.close();
      } catch (_e) {
      }
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(WifiNetworkErrorCodes.CONNECT_TIMEOUT, err));
    }
  }

  createServer(): socket.TCPSocketServer {
    return socket.constructTCPSocketServerInstance();
  }

  async listen(port: number): Promise<Result<socket.TCPSocketServer>> {
    const server = this.createServer();
    const listenAddr: socket.NetAddress = {
      address: '0.0.0.0',
      port: port,
      family: 1
    };
    try {
      await server.listen(listenAddr);
      return Result.ok(server);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(WifiNetworkErrorCodes.PORT_IN_USE, err));
    }
  }
}
