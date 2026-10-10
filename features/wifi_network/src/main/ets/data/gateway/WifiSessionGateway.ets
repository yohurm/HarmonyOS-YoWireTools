import { AbilityContextRegistry } from 'common_platform';
import { Observable, Result, ResultError, Subscription } from 'common_core';
import { TransportSessionRegistry } from 'debug_core';
import { WifiNetworkErrorCodes } from '../../constants/WifiNetworkErrorCodes';
import { DiscoveredNetworkService, MqttConnectConfig } from '../../domain/model/MqttModels';
import { SocketConnectionParams, UdpSessionConfig } from '../../domain/model/SocketModels';
import { MulticastSessionConfig } from '../../domain/model/SocketModels';
import { WebSocketMessageRecord, WebSocketServerConfigModel } from '../../domain/model/WebSocketModels';
import { MdnsDataSource } from '../datasource/MdnsDataSource';
import { MqttClientDataSource } from '../datasource/MqttClientDataSource';
import { MulticastSocketDataSource } from '../datasource/MulticastSocketDataSource';
import { SsdpDiscoveryDataSource } from '../datasource/SsdpDiscoveryDataSource';
import { UdpSocketDataSource } from '../datasource/UdpSocketDataSource';
import { WebSocketDataSource } from '../datasource/WebSocketDataSource';
import { WebSocketServerDataSource } from '../datasource/WebSocketServerDataSource';
import { MulticastSessionCoordinator } from '../transport/MulticastSessionCoordinator';
import { TcpClientSessionCoordinator } from '../transport/TcpClientSessionCoordinator';
import { TcpServerSessionCoordinator } from '../transport/TcpServerSessionCoordinator';
import { UdpTransportSession } from '../transport/UdpTransportSession';

/**
 * Data-layer session bridge. Domain use cases call the repository, which calls this.
 */
export class WifiSessionGateway {
  private readonly udpDataSource: UdpSocketDataSource;
  private readonly multicastDataSource: MulticastSocketDataSource;
  private readonly mdnsDataSource: MdnsDataSource;
  private readonly ssdpDataSource: SsdpDiscoveryDataSource;
  private readonly webSocketServerDataSource: WebSocketServerDataSource;
  private readonly mqttDataSource: MqttClientDataSource;
  private readonly webSocketDataSource: WebSocketDataSource;

  constructor(
    udpDataSource: UdpSocketDataSource = UdpSocketDataSource.getInstance(),
    multicastDataSource: MulticastSocketDataSource = MulticastSocketDataSource.getInstance(),
    mdnsDataSource: MdnsDataSource = MdnsDataSource.getInstance(),
    ssdpDataSource: SsdpDiscoveryDataSource = SsdpDiscoveryDataSource.getInstance(),
    webSocketServerDataSource: WebSocketServerDataSource = WebSocketServerDataSource.getInstance(),
    mqttDataSource: MqttClientDataSource = MqttClientDataSource.getInstance(),
    webSocketDataSource: WebSocketDataSource = WebSocketDataSource.getInstance()
  ) {
    this.udpDataSource = udpDataSource;
    this.multicastDataSource = multicastDataSource;
    this.mdnsDataSource = mdnsDataSource;
    this.ssdpDataSource = ssdpDataSource;
    this.webSocketServerDataSource = webSocketServerDataSource;
    this.mqttDataSource = mqttDataSource;
    this.webSocketDataSource = webSocketDataSource;
  }

  async openUdpSocket(sessionId: string, config: UdpSessionConfig): Promise<Result<void>> {
    const bound = await this.udpDataSource.bind(config.localPort, config.allowBroadcast);
    if (!bound.success || bound.value === undefined) {
      return Result.fail(bound.error ?? new ResultError(WifiNetworkErrorCodes.UDP_NOT_BOUND, 'UDP bind failed'));
    }
    const transport = new UdpTransportSession(sessionId);
    transport.bindSocket(bound.value, config.remoteHost, config.remotePort);
    TransportSessionRegistry.getInstance().register(sessionId, transport);
    return Result.ok(undefined);
  }

  async joinMulticast(sessionId: string, config: MulticastSessionConfig): Promise<Result<void>> {
    const joined = await this.multicastDataSource.bindAndJoin(config.localPort, config.groupAddress);
    if (!joined.success || joined.value === undefined) {
      return Result.fail(joined.error ?? new ResultError(WifiNetworkErrorCodes.SOCKET_ERRNO, 'Multicast join failed'));
    }
    MulticastSessionCoordinator.getInstance().attach(sessionId, joined.value);
    return Result.ok(undefined);
  }

  async leaveMulticast(): Promise<void> {
    await MulticastSessionCoordinator.getInstance().detach();
  }

  async startMdnsDiscovery(serviceType: string): Promise<Result<void>> {
    const context = AbilityContextRegistry.getInstance().get();
    if (context === undefined) {
      return Result.fail(new ResultError(WifiNetworkErrorCodes.SCAN_LIMITED, 'Ability context not bound'));
    }
    return this.mdnsDataSource.startDiscovery(context, serviceType);
  }

  async stopMdnsDiscovery(): Promise<void> {
    await this.mdnsDataSource.stopDiscovery();
  }

  startSsdpDiscovery(): Promise<Result<void>> {
    return this.ssdpDataSource.startDiscovery();
  }

  async stopSsdpDiscovery(): Promise<void> {
    await this.ssdpDataSource.stopDiscovery();
  }

  startWebSocketServer(config: WebSocketServerConfigModel): Promise<Result<void>> {
    return this.webSocketServerDataSource.start(config);
  }

  async stopWebSocketServer(): Promise<void> {
    await this.webSocketServerDataSource.stop();
  }

  listDiscoveredServices(): DiscoveredNetworkService[] {
    const merged: DiscoveredNetworkService[] = [];
    const mdns = this.mdnsDataSource.getServices();
    const ssdp = this.ssdpDataSource.getServices();
    for (let i = 0; i < mdns.length; i++) {
      merged.push(mdns[i]);
    }
    for (let i = 0; i < ssdp.length; i++) {
      merged.push(ssdp[i]);
    }
    return merged;
  }

  observeMdnsServices(onChange: (services: DiscoveredNetworkService[]) => void): Subscription {
    return this.mdnsDataSource.observeServices().subscribe(onChange, true);
  }

  observeSsdpServices(onChange: () => void): Subscription {
    return this.ssdpDataSource.observeServices().subscribe(onChange, true);
  }

  connectMqtt(config: MqttConnectConfig): Promise<Result<void>> {
    return this.mqttDataSource.connect(config);
  }

  async disconnectMqtt(): Promise<void> {
    await this.mqttDataSource.disconnect();
  }

  onMqttMessage(listener: (payload: string) => void): Result<void> {
    return this.mqttDataSource.onMessage(listener);
  }

  publishMqtt(topic: string, payload: string): Promise<Result<void>> {
    return this.mqttDataSource.publish(topic, payload);
  }

  startTcpServer(port: number): Promise<Result<void>> {
    return TcpServerSessionCoordinator.getInstance().start(port);
  }

  async stopTcpServer(): Promise<void> {
    await TcpServerSessionCoordinator.getInstance().stop();
  }

  connectTcpClient(sessionId: string, params: SocketConnectionParams): Promise<Result<void>> {
    return TcpClientSessionCoordinator.getInstance().connectSession(sessionId, params);
  }

  sendWebSocketText(text: string): Promise<Result<void>> {
    return this.webSocketDataSource.sendText(text);
  }

  observeWebSocketMessages(): Observable<WebSocketMessageRecord[]> {
    return this.webSocketDataSource.observeMessages();
  }
}
