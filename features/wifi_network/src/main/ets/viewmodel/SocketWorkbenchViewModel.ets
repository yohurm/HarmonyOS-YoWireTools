import { Subscription } from 'common_core';
import {
  ITransportSession,
  IncomingPayload,
  ProtocolType,
  TransportSessionRegistry
} from 'feature_debug_core';
import { TcpServerSessionCoordinator } from '../data/transport/TcpServerSessionCoordinator';
import { MulticastSessionCoordinator } from '../data/transport/MulticastSessionCoordinator';
import { UdpTransportSession } from '../data/transport/UdpTransportSession';
import {
  ConnectTcpClientUseCase,
  DisconnectTcpClientSessionUseCase,
  OpenTcpServerUseCase,
  SaveNetworkTargetUseCase,
  StopTcpServerSessionUseCase
} from '../domain/usecase/WifiNetworkExtendedUseCases';
import {
  CloseUdpSessionUseCase,
  LeaveMulticastSessionUseCase,
  OpenMulticastSessionUseCase,
  OpenUdpSessionUseCase
} from '../domain/usecase/WifiNetworkSessionUseCases';
import { MulticastSessionConfig, TcpServerClientRecord, UdpSessionConfig } from '../domain/model/SocketModels';
import { SocketConnectionParams } from '../domain/model/SocketModels';
import { WifiNetworkConstants } from '../constants/WifiNetworkConstants';

@ObservedV2
export class SocketWorkbenchViewModel {
  @Trace mode: string = 'tcpClient';
  @Trace host: string = '127.0.0.1';
  @Trace port: number = 8080;
  @Trace localPort: number = 9000;
  @Trace serverPort: number = 9001;
  @Trace multicastGroup: string = WifiNetworkConstants.DEFAULT_MULTICAST_GROUP;
  @Trace allowBroadcast: boolean = false;
  @Trace showBroadcastConfirm: boolean = false;
  @Trace connected: boolean = false;
  @Trace serverListening: boolean = false;
  @Trace multicastJoined: boolean = false;
  @Trace clientCount: number = 0;
  @Trace tcpClients: TcpServerClientRecord[] = [];
  @Trace selectedClientId: string = '';
  @Trace sessionId: string = '';
  @Trace showConnectDialog: boolean = false;
  @Trace logLines: string[] = [];
  @Trace statusMessage: string = '';

  private tcpIncomingSubscription: Subscription | undefined;
  private udpIncomingSubscription: Subscription | undefined;
  private pendingBroadcastText: string = '';
  private callbacksRegistered: boolean = false;

  private readonly connectTcpClient: ConnectTcpClientUseCase = new ConnectTcpClientUseCase();
  private readonly disconnectTcpSession: DisconnectTcpClientSessionUseCase = new DisconnectTcpClientSessionUseCase();
  private readonly openTcpServer: OpenTcpServerUseCase = new OpenTcpServerUseCase();
  private readonly stopTcpServer: StopTcpServerSessionUseCase = new StopTcpServerSessionUseCase();
  private readonly openUdpSession: OpenUdpSessionUseCase = new OpenUdpSessionUseCase();
  private readonly closeUdpSession: CloseUdpSessionUseCase = new CloseUdpSessionUseCase();
  private readonly openMulticastSession: OpenMulticastSessionUseCase = new OpenMulticastSessionUseCase();
  private readonly leaveMulticastSession: LeaveMulticastSessionUseCase = new LeaveMulticastSessionUseCase();
  private readonly saveTarget: SaveNetworkTargetUseCase = new SaveNetworkTargetUseCase();
  private readonly tcpServerCoordinator: TcpServerSessionCoordinator = TcpServerSessionCoordinator.getInstance();
  private readonly multicastCoordinator: MulticastSessionCoordinator = MulticastSessionCoordinator.getInstance();

  initialize(): void {
    if (this.callbacksRegistered) {
      return;
    }
    this.tcpServerCoordinator.setCallbacks(
      (clientId: string, text: string) => {
        this.appendLog(`Server RX(${clientId}): ${text}`);
      },
      () => {
        this.refreshTcpClients();
      }
    );
    this.multicastCoordinator.setMessageListener((text: string) => {
      this.appendLog(`Multicast RX: ${text.substring(0, 200)}`);
    });
    this.callbacksRegistered = true;
  }

  appendLog(line: string): void {
    this.logLines.push(`[${new Date().toLocaleTimeString()}] ${line}`);
  }

  dispose(): void {
    this.clearIncomingSubscriptions();
    void this.disconnectTcp();
    void this.stopTcpServerAction();
    void this.closeUdp();
    void this.leaveMulticast();
  }

  async connectTcp(): Promise<void> {
    this.initialize();
    const params = new SocketConnectionParams('tcpClient', this.port, this.host, 0, 10000);
    const result = await this.connectTcpClient.execute(params);
    if (!result.success || result.value === undefined) {
      this.statusMessage = result.error?.message ?? 'Connect failed';
      return;
    }
    this.sessionId = result.value;
    this.connected = true;
    this.statusMessage = 'TCP connected';
    this.appendLog(`Connected to ${this.host}:${this.port}`);
    const transport = TransportSessionRegistry.getInstance().get(this.sessionId);
    if (transport !== undefined) {
      this.bindTcpIncoming(transport);
    }
  }

  async disconnectTcp(): Promise<void> {
    this.clearTcpIncomingSubscription();
    const sessionId = this.sessionId;
    if (sessionId.length > 0) {
      await this.disconnectTcpSession.execute(sessionId);
    }
    this.connected = false;
    this.sessionId = '';
    this.statusMessage = 'Disconnected';
    this.appendLog('TCP disconnected');
  }

  async startTcpServer(): Promise<void> {
    this.initialize();
    const result = await this.openTcpServer.execute(this.serverPort);
    if (!result.success) {
      this.statusMessage = result.error?.message ?? 'Listen failed';
      return;
    }
    this.serverListening = true;
    this.statusMessage = `Listening :${this.serverPort}`;
    this.appendLog(`TCP server listening on ${this.serverPort}`);
    this.refreshTcpClients();
  }

  async stopTcpServerAction(): Promise<void> {
    await this.stopTcpServer.execute();
    this.serverListening = false;
    this.clientCount = 0;
    this.tcpClients = [];
    this.selectedClientId = '';
    this.statusMessage = 'Server stopped';
    this.appendLog('TCP server stopped');
  }

  async sendTcpServer(text: string, broadcast: boolean = false): Promise<void> {
    if (!this.serverListening) {
      this.statusMessage = 'Server not listening';
      return;
    }
    if (broadcast) {
      for (let i = 0; i < this.tcpClients.length; i++) {
        await this.sendToTcpClient(this.tcpClients[i].id, text);
      }
      return;
    }
    const targetId = this.selectedClientId.length > 0 ? this.selectedClientId : this.tcpClients[0]?.id ?? '';
    await this.sendToTcpClient(targetId, text);
  }

  async disconnectTcpClient(clientId: string): Promise<void> {
    await this.tcpServerCoordinator.disconnectClient(clientId);
    this.refreshTcpClients();
    if (this.selectedClientId === clientId) {
      this.selectedClientId = this.tcpClients.length > 0 ? this.tcpClients[0].id : '';
    }
  }

  async sendTcp(text: string): Promise<void> {
    if (this.sessionId.length === 0 || !this.connected) {
      this.statusMessage = 'Not connected';
      return;
    }
    const transport = TransportSessionRegistry.getInstance().get(this.sessionId);
    if (transport === undefined) {
      this.statusMessage = 'Transport missing';
      return;
    }
    const bytes = SocketWorkbenchViewModel.textToBytes(text);
    const written = await transport.write(bytes);
    this.statusMessage = written.success ? 'Sent' : (written.message ?? 'Send failed');
    if (written.success) {
      this.appendLog(`TX: ${text}`);
    }
  }

  async bindUdp(): Promise<void> {
    await this.closeUdp();
    const config = new UdpSessionConfig(this.localPort, this.host, this.port, this.allowBroadcast);
    const result = await this.openUdpSession.execute(config);
    if (!result.success || result.value === undefined) {
      this.statusMessage = result.error?.message ?? 'UDP bind failed';
      return;
    }
    this.sessionId = result.value.sessionId;
    this.statusMessage = `UDP bound :${this.localPort}`;
    this.appendLog(`UDP bound on port ${this.localPort}`);
    this.bindUdpIncoming(result.value.transport);
  }

  async closeUdp(): Promise<void> {
    this.clearUdpIncomingSubscription();
    const sessionId = this.sessionId;
    if (sessionId.length === 0) {
      return;
    }
    const transport = TransportSessionRegistry.getInstance().get(sessionId);
    if (transport !== undefined && transport.protocol === ProtocolType.UDP) {
      await this.closeUdpSession.execute(sessionId);
      this.sessionId = '';
    }
  }

  requestBroadcastSend(text: string): void {
    if (!this.allowBroadcast) {
      void this.sendUdp(text);
      return;
    }
    this.pendingBroadcastText = text;
    this.showBroadcastConfirm = true;
  }

  confirmBroadcastSend(): void {
    this.showBroadcastConfirm = false;
    if (this.pendingBroadcastText.length > 0) {
      void this.sendUdp(this.pendingBroadcastText, true);
      this.pendingBroadcastText = '';
    }
  }

  cancelBroadcastSend(): void {
    this.showBroadcastConfirm = false;
    this.pendingBroadcastText = '';
  }

  async sendUdp(text: string, forceBroadcast: boolean = false): Promise<void> {
    const targetHost = forceBroadcast || this.allowBroadcast ? '255.255.255.255' : this.host;
    if (this.sessionId.length === 0) {
      this.statusMessage = 'UDP not bound';
      return;
    }
    const transport = TransportSessionRegistry.getInstance().get(this.sessionId);
    if (transport === undefined) {
      this.statusMessage = 'UDP transport missing';
      return;
    }
    const udpTransport = transport as UdpTransportSession;
    udpTransport.setRemoteTarget(targetHost, this.port);
    const bytes = SocketWorkbenchViewModel.textToBytes(text);
    const written = await udpTransport.write(bytes);
    this.statusMessage = written.success ? 'UDP sent' : (written.message ?? 'Send failed');
    if (written.success) {
      this.appendLog(`UDP TX to ${targetHost}:${this.port}: ${text}`);
    }
  }

  async joinMulticast(): Promise<void> {
    this.initialize();
    const config = new MulticastSessionConfig(this.localPort, this.multicastGroup);
    const result = await this.openMulticastSession.execute(config);
    if (!result.success || result.value === undefined) {
      this.statusMessage = result.error?.message ?? 'Multicast join failed';
      return;
    }
    this.sessionId = result.value.sessionId;
    this.multicastJoined = true;
    this.statusMessage = `Joined ${this.multicastGroup}`;
    this.appendLog(`Multicast joined ${this.multicastGroup}:${this.localPort}`);
  }

  async leaveMulticast(): Promise<void> {
    const sessionId = this.sessionId;
    if (this.multicastJoined && sessionId.length > 0) {
      await this.leaveMulticastSession.execute(sessionId);
    } else {
      await this.multicastCoordinator.detach();
    }
    this.sessionId = '';
    this.multicastJoined = false;
    this.statusMessage = 'Multicast left';
    this.appendLog('Multicast left group');
  }

  async saveTcpTarget(): Promise<void> {
    const result = await this.saveTarget.execute(`TCP ${this.host}`, this.host, this.port, 'tcp');
    this.statusMessage = result.success ? 'Target saved' : (result.error?.message ?? 'Save failed');
  }

  private refreshTcpClients(): void {
    this.tcpClients = this.tcpServerCoordinator.listClients();
    this.clientCount = this.tcpClients.length;
  }

  private bindTcpIncoming(transport: ITransportSession): void {
    this.clearTcpIncomingSubscription();
    this.tcpIncomingSubscription = transport.observeIncoming().subscribe((payload: IncomingPayload) => {
      this.appendLog(`TCP RX: ${SocketWorkbenchViewModel.bytesToText(payload.bytes)}`);
    });
  }

  private bindUdpIncoming(transport: UdpTransportSession): void {
    this.clearUdpIncomingSubscription();
    this.udpIncomingSubscription = transport.observeIncoming().subscribe((payload: IncomingPayload) => {
      this.appendLog(`UDP RX: ${SocketWorkbenchViewModel.bytesToText(payload.bytes)}`);
    });
  }

  private clearTcpIncomingSubscription(): void {
    if (this.tcpIncomingSubscription !== undefined) {
      this.tcpIncomingSubscription.dispose();
      this.tcpIncomingSubscription = undefined;
    }
  }

  private clearUdpIncomingSubscription(): void {
    if (this.udpIncomingSubscription !== undefined) {
      this.udpIncomingSubscription.dispose();
      this.udpIncomingSubscription = undefined;
    }
  }

  private clearIncomingSubscriptions(): void {
    this.clearTcpIncomingSubscription();
    this.clearUdpIncomingSubscription();
  }

  private async sendToTcpClient(clientId: string, text: string): Promise<void> {
    const sent = await this.tcpServerCoordinator.sendToClient(clientId, text);
    if (sent.success) {
      this.appendLog(`Server TX(${clientId}): ${text}`);
      this.statusMessage = 'Sent to client';
    } else {
      this.statusMessage = sent.error?.message ?? 'Send failed';
    }
  }

  private static textToBytes(text: string): Uint8Array {
    const bytes = new Uint8Array(text.length);
    for (let i = 0; i < text.length; i++) {
      bytes[i] = text.charCodeAt(i);
    }
    return bytes;
  }

  private static bytesToText(bytes: Uint8Array): string {
    let text = '';
    for (let i = 0; i < bytes.length; i++) {
      text += String.fromCharCode(bytes[i]);
    }
    return text;
  }
}
