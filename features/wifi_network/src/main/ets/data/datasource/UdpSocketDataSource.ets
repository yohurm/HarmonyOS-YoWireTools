import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { WifiNetworkConstants } from '../../constants/WifiNetworkConstants';

/**
 * UDP socket wrapper per architecture wifi_network/02-§6.
 */

export class UdpSocketDataSource {
  private static instance: UdpSocketDataSource | undefined;
  static getInstance(): UdpSocketDataSource {
    if (UdpSocketDataSource.instance === undefined) {
      UdpSocketDataSource.instance = new UdpSocketDataSource();
    }
    return UdpSocketDataSource.instance;
  }
  create(): socket.UDPSocket {
    return socket.constructUDPSocketInstance();
  }
  async bind(localPort: number, allowBroadcast: boolean = false): Promise<Result<socket.UDPSocket>> {
    const udp = this.create();
    const bindAddr: socket.NetAddress = {
      address: '0.0.0.0',
      port: localPort,
      family: 1
    };
    try {
      await udp.bind(bindAddr);
      if (allowBroadcast) {
        await udp.setExtraOptions({ broadcast: true });
      }
      return Result.ok(udp);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(WifiNetworkErrorCodes.SOCKET_PORT_IN_USE, err));
    }
  }
  async send(
    udp: socket.UDPSocket,
    host: string,
    port: number,
    data: string | ArrayBuffer
  ): Promise<Result<void>> {
    if (UdpSocketDataSource.payloadTooLarge(data)) {
      return Result.fail(new ResultError(
        WifiNetworkErrorCodes.HTTP_SIZE_LIMIT,
        `Datagram exceeds ${WifiNetworkConstants.MAX_UDP_DATAGRAM_BYTES} bytes`
      ));
    }
    try {
      await udp.send({
        data: data,
        address: { address: host, port: port, family: 1 }
      });
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(WifiNetworkErrorCodes.SOCKET_ERRNO, err));
    }
  }
  private static payloadTooLarge(data: string | ArrayBuffer): boolean {
    const size = typeof data === 'string' ? data.length : data.byteLength;
    return size > WifiNetworkConstants.MAX_UDP_DATAGRAM_BYTES;
  }
}
