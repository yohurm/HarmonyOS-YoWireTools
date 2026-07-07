import { socket } from '@kit.NetworkKit';
import { Observable, Result, ResultError } from 'common_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { DiscoveredNetworkService } from '../../domain/model/MqttModels';
import { SsdpUrlParser } from '../../domain/service/SsdpUrlParser';
import { UdpSocketDataSource } from './UdpSocketDataSource';
import { NetworkKitEventBridge } from '../kit/NetworkKitEventBridge';

const SSDP_MULTICAST_HOST: string = '239.255.255.250';
const SSDP_PORT: number = 1900;

export class SsdpDiscoveryDataSource {
  private static instance: SsdpDiscoveryDataSource | undefined;
  private udpSocket: socket.UDPSocket | undefined;
  private readonly servicesObservable: Observable<DiscoveredNetworkService[]>;
  private services: DiscoveredNetworkService[] = [];
  private searching: boolean = false;
  private messageHandler: ((value: socket.SocketMessageInfo) => void) | undefined;

  private constructor() {
    this.servicesObservable = new Observable<DiscoveredNetworkService[]>([]);
  }

  static getInstance(): SsdpDiscoveryDataSource {
    if (SsdpDiscoveryDataSource.instance === undefined) {
      SsdpDiscoveryDataSource.instance = new SsdpDiscoveryDataSource();
    }
    return SsdpDiscoveryDataSource.instance;
  }

  observeServices(): Observable<DiscoveredNetworkService[]> {
    return this.servicesObservable;
  }

  isSearching(): boolean {
    return this.searching;
  }

  async startDiscovery(): Promise<Result<void>> {
    await this.stopDiscovery();
    const bound = await UdpSocketDataSource.getInstance().bind(0, true);
    if (!bound.success || bound.value === undefined) {
      return Result.fail(bound.error ?? new ResultError(WifiNetworkErrorCodes.UDP_NOT_BOUND, 'SSDP bind failed'));
    }
    this.udpSocket = bound.value;
    this.messageHandler = (value: socket.SocketMessageInfo) => {
      const text = typeof value.message === 'string' ? value.message : SsdpDiscoveryDataSource.bufferToText(value.message);
      this.parseResponse(text);
    };
    const subscribed = NetworkKitEventBridge.subscribeUdpMessage(this.udpSocket, this.messageHandler);
    if (!subscribed.success) {
      return subscribed;
    }
    const search =
      'M-SEARCH * HTTP/1.1\r\n' +
      `HOST: ${SSDP_MULTICAST_HOST}:${SSDP_PORT}\r\n` +
      'MAN: "ssdp:discover"\r\n' +
      'ST: ssdp:all\r\n' +
      'MX: 2\r\n\r\n';
    try {
      await this.udpSocket.send({
        data: search,
        address: { address: SSDP_MULTICAST_HOST, port: SSDP_PORT, family: 1 }
      });
      this.searching = true;
      return Result.ok(undefined);
    } catch (error) {
      const err = error as Error;
      return Result.fail(new ResultError(WifiNetworkErrorCodes.SOCKET_ERRNO, err.message, err));
    }
  }

  async stopDiscovery(): Promise<void> {
    if (this.udpSocket !== undefined && this.messageHandler !== undefined) {
      NetworkKitEventBridge.unsubscribeUdpMessage(this.udpSocket, this.messageHandler);
    }
    if (this.udpSocket !== undefined) {
      try {
        await this.udpSocket.close();
      } catch (_error) {
      }
    }
    this.udpSocket = undefined;
    this.messageHandler = undefined;
    this.searching = false;
  }

  getServices(): DiscoveredNetworkService[] {
    return this.services.slice();
  }

  private parseResponse(text: string): void {
    const location = SsdpUrlParser.headerValue(text, 'LOCATION');
    const server = SsdpUrlParser.headerValue(text, 'SERVER');
    const usn = SsdpUrlParser.headerValue(text, 'USN');
    if (location.length === 0) {
      return;
    }
    const parsed = SsdpUrlParser.parseUrl(location);
    if (parsed === undefined) {
      return;
    }
    const id = `ssdp:${usn.length > 0 ? usn : location}`;
    const now = Date.now();
    const service = new DiscoveredNetworkService(
      id, 'ssdp', server.length > 0 ? server : usn, parsed.host, parsed.port, 'http', location, now, now
    );
    const next: DiscoveredNetworkService[] = [];
    let found = false;
    for (let i = 0; i < this.services.length; i++) {
      if (this.services[i].id === id) {
        next.push(service);
        found = true;
      } else {
        next.push(this.services[i]);
      }
    }
    if (!found) {
      next.push(service);
    }
    this.services = next;
    this.servicesObservable.next(this.services.slice());
  }

  private static bufferToText(buffer: ArrayBuffer): string {
    const bytes = new Uint8Array(buffer);
    let text = '';
    for (let i = 0; i < bytes.length; i++) {
      text += String.fromCharCode(bytes[i]);
    }
    return text;
  }
}
