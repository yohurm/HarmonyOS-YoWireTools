import { socket } from '@kit.NetworkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
export class MulticastSocketDataSource {
  private static instance: MulticastSocketDataSource | undefined;
  private activeSocket: socket.MulticastSocket | undefined;
  static getInstance(): MulticastSocketDataSource {
    if (MulticastSocketDataSource.instance === undefined) {
      MulticastSocketDataSource.instance = new MulticastSocketDataSource();
    }
    return MulticastSocketDataSource.instance;
  }
  create(): socket.MulticastSocket {
    return socket.constructMulticastSocketInstance();
  }
  getActiveSocket(): socket.MulticastSocket | undefined {
    return this.activeSocket;
  }
  async bindAndJoin(localPort: number, groupAddress: string): Promise<Result<socket.MulticastSocket>> {
    const multicast = this.create();
    const bindAddr: socket.NetAddress = { address: '0.0.0.0', port: localPort, family: 1 };
    const groupAddr: socket.NetAddress = { address: groupAddress, port: localPort, family: 1 };
    try {
      await multicast.bind(bindAddr);
      await multicast.addMembership(groupAddr);
      this.activeSocket = multicast;
      return Result.ok(multicast);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(WifiNetworkErrorCodes.SOCKET_PORT_IN_USE, err));
    }
  }
  async close(multicast?: socket.MulticastSocket): Promise<void> {
    const target = multicast ?? this.activeSocket;
    if (target === undefined) {
      return;
    }
    try {
      await target.close();
    } catch (_error) {
    }
    if (target === this.activeSocket) {
      this.activeSocket = undefined;
    }
  }
}
