import { Subscription } from 'common_core';

import {

  WebSocketClientPhase,

  WebSocketConfig,

  WebSocketMessageRecord,

  WebSocketServerClientRecord,

  WebSocketServerConfigModel,

  WebSocketServerPhase

} from '../domain/model/WebSocketModels';

import { OpenWebSocketUseCase } from '../domain/usecase/WifiNetworkUseCases';

import { OpenWebSocketServerUseCase, StopWebSocketServerUseCase } from '../domain/usecase/WifiNetworkSessionUseCases';

import { WebSocketServerCapabilityProbe } from '../domain/service/WebSocketServerCapabilityProbe';

import { WifiNetworkRepository } from '../data/repository/WifiNetworkRepository';



@ObservedV2

export class WebSocketViewModel {

  @Trace panelMode: string = 'client';

  @Trace url: string = 'wss://echo.websocket.events';

  @Trace phase: WebSocketClientPhase = WebSocketClientPhase.IDLE;

  @Trace messages: WebSocketMessageRecord[] = [];

  @Trace outboundText: string = '';

  @Trace serverSupported: boolean = WebSocketServerCapabilityProbe.probeSupported();

  @Trace serverPort: number = 8080;

  @Trace serverPhase: WebSocketServerPhase = WebSocketServerPhase.IDLE;

  @Trace serverClients: WebSocketServerClientRecord[] = [];

  @Trace selectedServerClientId: string = '';

  @Trace serverOutboundText: string = '';

  @Trace statusMessage: string = '';



  private readonly openWebSocket: OpenWebSocketUseCase = new OpenWebSocketUseCase();

  private readonly openServer: OpenWebSocketServerUseCase = new OpenWebSocketServerUseCase();

  private readonly stopServer: StopWebSocketServerUseCase = new StopWebSocketServerUseCase();

  private readonly repository: WifiNetworkRepository = WifiNetworkRepository.getInstance();

  private phaseSubscription: Subscription | undefined;

  private messageSubscription: Subscription | undefined;

  private serverPhaseSubscription: Subscription | undefined;

  private serverClientsSubscription: Subscription | undefined;



  initialize(): void {

    const ds = this.repository.getWebSocketDataSource();

    this.phaseSubscription = ds.observePhase().subscribe((phase: WebSocketClientPhase) => {

      this.phase = phase;

      if (phase === WebSocketClientPhase.OPEN) {

        this.statusMessage = 'WebSocket open';

      }

    }, true);

    this.messageSubscription = ds.observeMessages().subscribe((msgs: WebSocketMessageRecord[]) => {

      this.messages = msgs;

    }, true);

    const serverDs = this.openServer.getDataSource();

    this.serverPhaseSubscription = serverDs.observePhase().subscribe((phase: WebSocketServerPhase) => {

      this.serverPhase = phase;

    }, true);

    this.serverClientsSubscription = serverDs.observeClients().subscribe((clients: WebSocketServerClientRecord[]) => {

      this.serverClients = clients;

      if (this.selectedServerClientId.length === 0 && clients.length > 0) {

        this.selectedServerClientId = clients[0].id;

      }

    }, true);

  }



  dispose(): void {

    if (this.phaseSubscription !== undefined) {

      this.phaseSubscription.dispose();

    }

    if (this.messageSubscription !== undefined) {

      this.messageSubscription.dispose();

    }

    if (this.serverPhaseSubscription !== undefined) {

      this.serverPhaseSubscription.dispose();

    }

    if (this.serverClientsSubscription !== undefined) {

      this.serverClientsSubscription.dispose();

    }

    void this.repository.disconnectWebSocket();

    void this.stopServer.execute();

  }



  async connectAction(): Promise<void> {

    this.statusMessage = 'Connecting...';

    const result = await this.openWebSocket.execute(new WebSocketConfig(this.url));

    this.statusMessage = result.success ?

      'Connect request created — waiting for open event' :

      (result.error?.message ?? 'Connect failed');

  }



  async disconnectAction(): Promise<void> {

    await this.repository.disconnectWebSocket();

    this.statusMessage = 'Disconnected';

  }



  async sendAction(): Promise<void> {

    if (this.phase !== WebSocketClientPhase.OPEN) {

      this.statusMessage = 'Cannot send before open event';

      return;

    }

    const result = await this.repository.getWebSocketDataSource().sendText(this.outboundText);

    if (!result.success) {

      this.statusMessage = result.error?.message ?? 'Send failed';

    }

  }



  async startServerAction(): Promise<void> {

    if (!this.serverSupported) {

      this.statusMessage = WebSocketServerCapabilityProbe.capabilityMessage();

      return;

    }

    const result = await this.openServer.execute(new WebSocketServerConfigModel(this.serverPort));

    this.statusMessage = result.success ?

      `WebSocket server listening on ${this.serverPort}` :

      (result.error?.message ?? 'Server start failed');

  }



  async stopServerAction(): Promise<void> {

    await this.stopServer.execute();

    this.statusMessage = 'WebSocket server stopped';

  }



  async sendServerAction(broadcast: boolean = false): Promise<void> {

    const ds = this.openServer.getDataSource();

    const result = broadcast ?

      await ds.broadcast(this.serverOutboundText) :

      await ds.sendToClient(this.selectedServerClientId, this.serverOutboundText);

    this.statusMessage = result.success ? 'Server message sent' : (result.error?.message ?? 'Send failed');

  }

}

