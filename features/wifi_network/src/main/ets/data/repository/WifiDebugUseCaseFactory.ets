import { WifiNetworkRepository } from './WifiNetworkRepository';
import { WifiDebugUseCases } from '../../domain/usecase/WifiDebugUseCases';
import {
  ConnectTcpClientUseCase,
  DisconnectTcpClientSessionUseCase,
  OpenTcpServerUseCase,
  StopTcpServerSessionUseCase
} from '../../domain/usecase/WifiNetworkExtendedUseCases';
import { ExecuteHttpRequestUseCase, OpenWebSocketUseCase, StartPortScanUseCase } from '../../domain/usecase/WifiNetworkUseCases';
import {
  CloseUdpSessionUseCase,
  LeaveMulticastSessionUseCase,
  OpenMulticastSessionUseCase,
  OpenUdpSessionUseCase,
  OpenWebSocketServerUseCase,
  StartMdnsDiscoveryUseCase,
  StopMdnsDiscoveryUseCase,
  StopWebSocketServerUseCase
} from '../../domain/usecase/WifiNetworkSessionUseCases';

/**
 * Composition root. The view model receives use cases and does not call the repository.
 */
export class WifiDebugUseCaseBundle {
  readonly debug: WifiDebugUseCases;
  readonly http: ExecuteHttpRequestUseCase;
  readonly port: StartPortScanUseCase;
  readonly mdns: StartMdnsDiscoveryUseCase;
  readonly stopMdns: StopMdnsDiscoveryUseCase;
  readonly tcp: ConnectTcpClientUseCase;
  readonly disconnectTcp: DisconnectTcpClientSessionUseCase;
  readonly udp: OpenUdpSessionUseCase;
  readonly closeUdp: CloseUdpSessionUseCase;
  readonly tcpServer: OpenTcpServerUseCase;
  readonly stopTcpServer: StopTcpServerSessionUseCase;
  readonly ws: OpenWebSocketUseCase;
  readonly wsServer: OpenWebSocketServerUseCase;
  readonly stopWsServer: StopWebSocketServerUseCase;
  readonly multicast: OpenMulticastSessionUseCase;
  readonly leaveMulticast: LeaveMulticastSessionUseCase;

  constructor(
    debug: WifiDebugUseCases,
    http: ExecuteHttpRequestUseCase,
    port: StartPortScanUseCase,
    mdns: StartMdnsDiscoveryUseCase,
    stopMdns: StopMdnsDiscoveryUseCase,
    tcp: ConnectTcpClientUseCase,
    disconnectTcp: DisconnectTcpClientSessionUseCase,
    udp: OpenUdpSessionUseCase,
    closeUdp: CloseUdpSessionUseCase,
    tcpServer: OpenTcpServerUseCase,
    stopTcpServer: StopTcpServerSessionUseCase,
    ws: OpenWebSocketUseCase,
    wsServer: OpenWebSocketServerUseCase,
    stopWsServer: StopWebSocketServerUseCase,
    multicast: OpenMulticastSessionUseCase,
    leaveMulticast: LeaveMulticastSessionUseCase
  ) {
    this.debug = debug;
    this.http = http;
    this.port = port;
    this.mdns = mdns;
    this.stopMdns = stopMdns;
    this.tcp = tcp;
    this.disconnectTcp = disconnectTcp;
    this.udp = udp;
    this.closeUdp = closeUdp;
    this.tcpServer = tcpServer;
    this.stopTcpServer = stopTcpServer;
    this.ws = ws;
    this.wsServer = wsServer;
    this.stopWsServer = stopWsServer;
    this.multicast = multicast;
    this.leaveMulticast = leaveMulticast;
  }
}

export class WifiDebugUseCaseFactory {
  static create(): WifiDebugUseCaseBundle {
    const repository = WifiNetworkRepository.getInstance();
    return new WifiDebugUseCaseBundle(
      new WifiDebugUseCases(repository),
      new ExecuteHttpRequestUseCase(repository),
      new StartPortScanUseCase(repository),
      new StartMdnsDiscoveryUseCase(repository),
      new StopMdnsDiscoveryUseCase(repository),
      new ConnectTcpClientUseCase(repository),
      new DisconnectTcpClientSessionUseCase(repository),
      new OpenUdpSessionUseCase(repository),
      new CloseUdpSessionUseCase(repository),
      new OpenTcpServerUseCase(repository),
      new StopTcpServerSessionUseCase(repository),
      new OpenWebSocketUseCase(repository),
      new OpenWebSocketServerUseCase(repository),
      new StopWebSocketServerUseCase(repository),
      new OpenMulticastSessionUseCase(repository),
      new LeaveMulticastSessionUseCase(repository)
    );
  }
}
