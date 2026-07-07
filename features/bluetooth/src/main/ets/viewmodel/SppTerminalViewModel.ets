import { Result, Subscription } from 'common_core';

import { LogQuery, LogRepository } from 'common_storage';

import { UiPageState } from 'common_ui';

import {

  DebugLogRecord,

  DisplayHint,

  LineEndingMode,

  PayloadEncoding,

  SendCommandInput,

  SessionRuntimeStore,

  StartRepeatCommandUseCase,

  StopRepeatCommandUseCase,

  RepeatPolicy,

  TransportSessionRegistry,

  TransportState

} from 'feature_debug_core';

import { BluetoothConstants } from '../constants/BluetoothConstants';

import {

  ConnectSppUseCase,

  DisconnectSppUseCase,

  PairBluetoothDeviceUseCase

} from '../domain/usecase/BluetoothUseCases';

import { SaveBluetoothFavoriteUseCase, SendSppCommandUseCase } from '../domain/usecase/BluetoothExtendedUseCases';

import { ReconnectPolicy } from '../domain/model/ReconnectPolicy';

import { ConnectSppResult, SppConnectParams } from '../domain/model/SppConnectParams';

import { SppHeartbeatConfig } from '../domain/model/SppRuntimeState';

import { BluetoothRepository } from '../data/repository/BluetoothRepository';

import { PairingState } from '../domain/model/PairingState';

import { BluetoothDevice } from '../domain/model/BluetoothDevice';

import { SppReconnectCoordinator } from '../domain/service/SppReconnectCoordinator';
import { SppConnectFailureHints } from '../domain/service/SppConnectFailureHints';



export enum SppLogDisplayMode {

  TEXT = 'text',

  HEX = 'hex',

  MIXED = 'mixed'

}



@ObservedV2

export class SppTerminalViewModel {

  @Trace pageState: UiPageState = UiPageState.CONTENT;

  @Trace deviceId: string = '';

  @Trace displayName: string = '';

  @Trace sessionId: string = '';

  @Trace uuid: string = BluetoothConstants.DEFAULT_SPP_UUID;

  @Trace secure: boolean = false;

  @Trace autoReconnect: boolean = false;

  @Trace connectTimeoutMs: number = BluetoothConstants.DEFAULT_SPP_CONNECT_TIMEOUT_MS;

  @Trace pairState: PairingState = PairingState.UNKNOWN;

  @Trace connectionState: TransportState = TransportState.IDLE;

  @Trace sendPayload: string = '';

  @Trace encoding: PayloadEncoding = PayloadEncoding.TEXT;

  @Trace lineEnding: LineEndingMode = LineEndingMode.LF;

  @Trace logDisplayMode: SppLogDisplayMode = SppLogDisplayMode.TEXT;

  @Trace logLines: string[] = [];

  @Trace statusMessage: string = '';

  @Trace pauseScroll: boolean = false;

  @Trace periodicSendEnabled: boolean = false;

  @Trace periodicSendIntervalMs: number = 1000;

  @Trace periodicSendPayload: string = '';

  @Trace heartbeatEnabled: boolean = false;

  @Trace heartbeatIntervalMs: number = 3000;

  @Trace heartbeatPayloadHex: string = '00';

  @Trace showPairingGuide: boolean = false;

  @Trace showUuidPicker: boolean = false;

  @Trace connectFailureHints: string[] = [];

  @Trace favoriteAlias: string = '';



  private static readonly PERIODIC_JOB_ID: string = 'spp-periodic-send';
  private static readonly HEARTBEAT_JOB_ID: string = 'spp-heartbeat';

  private stateSub: Subscription | undefined;
  private sessionLogSub: Subscription | undefined;

  private readonly runtimeStore: SessionRuntimeStore = SessionRuntimeStore.getInstance();
  private readonly startRepeat: StartRepeatCommandUseCase = new StartRepeatCommandUseCase();
  private readonly stopRepeat: StopRepeatCommandUseCase = new StopRepeatCommandUseCase();

  private readonly repository: BluetoothRepository = BluetoothRepository.getInstance();

  private readonly connectSpp: ConnectSppUseCase = new ConnectSppUseCase();

  private readonly disconnectSpp: DisconnectSppUseCase = new DisconnectSppUseCase();

  private readonly sendCommand: SendSppCommandUseCase = new SendSppCommandUseCase();

  private readonly pairDevice: PairBluetoothDeviceUseCase = new PairBluetoothDeviceUseCase();

  private readonly saveFavorite: SaveBluetoothFavoriteUseCase = new SaveBluetoothFavoriteUseCase();



  bindTarget(deviceId: string, displayName: string): void {
    this.deviceId = deviceId;
    this.displayName = displayName;
    void this.repository.getPairState(deviceId).then((result: Result<PairingState>) => {
      if (result.success && result.value !== undefined) {
        this.pairState = result.value;
      }
    });
  }

  restoreSession(sessionId: string, deviceId: string, displayName: string): void {
    this.sessionId = sessionId;
    this.deviceId = deviceId;
    this.displayName = displayName;
    this.bindTransportObservers();
    this.bindSessionLogObserver();
    void this.refreshLogs();
  }

  isConnected(): boolean {
    return this.connectionState === TransportState.CONNECTED;
  }

  canSend(): boolean {
    return this.sessionId.length > 0 && this.isConnected() && this.sendPayload.length > 0;
  }

  connectionStateLabel(): string {
    switch (this.connectionState) {
      case TransportState.CONNECTING:
        return '连接中';
      case TransportState.CONNECTED:
        return '已连接';
      case TransportState.DISCONNECTING:
        return '断开中';
      case TransportState.FAILED:
        return '连接失败';
      case TransportState.DISCONNECTED:
        return '已断开';
      default:
        return '未连接';
    }
  }

  pairStateLabel(): string {
    switch (this.pairState) {
      case PairingState.PAIRED:
        return '已配对';
      case PairingState.PAIRING:
        return '配对中';
      case PairingState.UNPAIRED:
        return '未配对';
      case PairingState.FAILED:
        return '配对失败';
      default:
        return '未知';
    }
  }

  async connect(): Promise<boolean> {

    if (this.pairState === PairingState.UNPAIRED) {

      this.showPairingGuide = true;

      return false;

    }

    await this.repository.ensureClassicDiscoveryStopped();

    const params = new SppConnectParams(

      this.deviceId,

      this.displayName,

      this.uuid,

      this.secure,

      this.connectTimeoutMs,

      this.autoReconnect,

      ReconnectPolicy.defaultPolicy()

    );

    const result: Result<ConnectSppResult> = await this.connectSpp.execute(params);

    if (!result.success || result.value === undefined) {

      this.connectFailureHints = SppConnectFailureHints.explain(
        result.error?.code ?? '',
        result.error?.message ?? ''
      );
      this.statusMessage = result.error?.message ?? '连接失败';

      return false;

    }

    this.connectFailureHints = [];

    this.sessionId = result.value.sessionId;

    this.statusMessage = '已连接';

    this.bindTransportObservers();

    this.bindSessionLogObserver();

    void this.startPeriodicSend();

    void this.startHeartbeat();

    if (this.autoReconnect) {

      SppReconnectCoordinator.getInstance().bind(this.deviceId, async () => {

        await this.connect();

      }, this.sessionId);

    }

    await this.refreshLogs();

    return true;

  }



  async startPairing(): Promise<void> {

    const result: Result<void> = await this.pairDevice.execute(this.deviceId);

    this.statusMessage = result.success ? 'Pairing started' : (result.error?.message ?? 'Pair failed');

  }



  async saveUuidFavorite(): Promise<void> {

    const device = new BluetoothDevice(this.deviceId, this.displayName);

    const alias = this.favoriteAlias.length > 0 ? this.favoriteAlias : this.displayName;

    const saved = await this.saveFavorite.execute(device, alias, 'spp_uuid', this.uuid);

    this.statusMessage = saved.success ? 'UUID favorite saved' : (saved.error?.message ?? 'Save failed');

  }



  selectUuid(uuid: string): void {

    this.uuid = uuid;

    this.showUuidPicker = false;

  }



  async disconnect(): Promise<void> {

    this.stopPeriodicSend();

    this.stopHeartbeat();

    this.unbindSessionLogObserver();

    this.stateSub?.dispose();

    SppReconnectCoordinator.getInstance().unbind();

    if (this.sessionId.length === 0) {

      return;

    }

    await this.disconnectSpp.execute(this.sessionId);

    this.stopRepeat.stopForSession(this.sessionId);

    this.sessionId = '';

    this.connectionState = TransportState.DISCONNECTED;

    this.logLines = [];

    this.statusMessage = 'Disconnected';

  }



  dispose(): void {

    this.stopPeriodicSend();

    this.stopHeartbeat();

    this.unbindSessionLogObserver();

    this.stateSub?.dispose();

    SppReconnectCoordinator.getInstance().unbind();

  }



  async send(): Promise<void> {

    if (this.sessionId.length === 0) {

      return;

    }

    const transport = TransportSessionRegistry.getInstance().get(this.sessionId);

    if (transport === undefined) {

      this.statusMessage = 'Transport missing';

      return;

    }

    const input = new SendCommandInput(

      this.sessionId,

      transport,

      this.sendPayload,

      this.encoding,

      this.lineEnding

    );

    const sent: Result<DebugLogRecord> = await this.sendCommand.execute(input);

    this.statusMessage = sent.success ? 'Sent' : (sent.error?.message ?? 'Send failed');

    await this.refreshLogs();

  }



  clearUiLogs(): void {

    this.logLines = [];

  }



  async startPeriodicSend(): Promise<void> {

    this.stopPeriodicSend();

    if (!this.periodicSendEnabled || this.periodicSendPayload.length === 0 || this.sessionId.length === 0) {

      return;

    }

    const transport = TransportSessionRegistry.getInstance().get(this.sessionId);

    if (transport === undefined) {

      return;

    }

    const input = new SendCommandInput(

      this.sessionId,

      transport,

      this.periodicSendPayload,

      this.encoding,

      this.lineEnding

    );

    const policy = new RepeatPolicy(this.periodicSendIntervalMs, 0, 0, false, false);

    await this.startRepeat.execute(SppTerminalViewModel.PERIODIC_JOB_ID, input, policy);

  }



  stopPeriodicSend(): void {

    this.stopRepeat.execute(SppTerminalViewModel.PERIODIC_JOB_ID);

  }



  async startHeartbeat(): Promise<void> {

    this.stopHeartbeat();

    if (!this.heartbeatEnabled || this.sessionId.length === 0) {

      return;

    }

    const transport = TransportSessionRegistry.getInstance().get(this.sessionId);

    if (transport === undefined) {

      return;

    }

    const config = new SppHeartbeatConfig(true, this.heartbeatIntervalMs, this.heartbeatPayloadHex);

    const input = new SendCommandInput(

      this.sessionId,

      transport,

      config.payloadHex,

      PayloadEncoding.HEX,

      LineEndingMode.NONE

    );

    const policy = new RepeatPolicy(config.intervalMs, 0, 0, false, false);

    await this.startRepeat.execute(SppTerminalViewModel.HEARTBEAT_JOB_ID, input, policy);

  }



  stopHeartbeat(): void {

    this.stopRepeat.execute(SppTerminalViewModel.HEARTBEAT_JOB_ID);

  }



  bindSessionLogObserver(): void {

    this.unbindSessionLogObserver();

    if (this.sessionId.length === 0) {

      return;

    }

    try {

      this.sessionLogSub = this.runtimeStore.subscribeSession(this.sessionId, () => {

        void this.refreshLogs();

      });

    } catch (_error) {

      // Session may not be registered yet.

    }

  }



  unbindSessionLogObserver(): void {

    if (this.sessionLogSub !== undefined) {

      this.sessionLogSub.dispose();

      this.sessionLogSub = undefined;

    }

  }



  bindTransportObservers(): void {

    const transport = TransportSessionRegistry.getInstance().get(this.sessionId);

    if (transport === undefined) {

      return;

    }

    this.connectionState = transport.state;

    this.stateSub?.dispose();

    this.stateSub = transport.observeState().subscribe((snapshot) => {

      this.connectionState = snapshot.state;

    });

  }



  async refreshLogs(): Promise<void> {

    if (this.sessionId.length === 0) {

      return;

    }

    const listed = await LogRepository.getInstance().list(new LogQuery(this.sessionId, 0, 100));

    if (!listed.success || listed.value === undefined) {

      return;

    }

    const lines: string[] = [];

    for (let i = 0; i < listed.value.items.length; i++) {

      const item = listed.value.items[i];

      if (!this.shouldIncludeLog(item.displayHint)) {
        continue;
      }

      lines.push(SppTerminalViewModel.formatLogLine(item.direction, item.summary, item.displayHint));

    }

    if (!this.pauseScroll) {

      this.logLines = lines;

    }

  }



  private shouldIncludeLog(displayHint: string): boolean {
    if (this.logDisplayMode === SppLogDisplayMode.MIXED) {
      return true;
    }
    if (this.logDisplayMode === SppLogDisplayMode.HEX) {
      return displayHint === DisplayHint.HEX || displayHint === DisplayHint.MIXED;
    }
    return displayHint !== DisplayHint.HEX;
  }

  private static formatLogLine(direction: string, summary: string, displayHint: string): string {

    if (displayHint === DisplayHint.HEX) {

      return `${direction} [hex] ${summary}`;

    }

    if (displayHint === DisplayHint.MIXED) {

      return `${direction} [mixed] ${summary}`;

    }

    return `${direction} ${summary}`;

  }

}


