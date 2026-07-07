import { Subscription, TimeUtil, Result } from 'common_core';
import { UiPageState } from 'common_ui';
import {
  PayloadEncoding,
  LineEndingMode,
  RepeatPolicy,
  SendCommandInput,
  StartRepeatCommandUseCase,
  StopRepeatCommandUseCase,
  TransportSessionRegistry,
  DebugLogRecord
} from 'feature_debug_core';
import {
  ConnectDataTransferUseCase,
  DisconnectDataTransferUseCase,
  ObserveDataTransferPacketsUseCase,
  SendNearLinkCommandUseCase,
  PairNearLinkDeviceUseCase
} from '../domain/usecase/NearLinkExtendedUseCases';
import {
  DataTransferPortConfig,
  DataTransferRuntimeState,
  DataTransferPacket,
  CongestionPolicy
} from '../domain/model/DataTransferPortConfig';
import { ConnectDataTransferResult } from '../domain/model/ConnectDataTransferResult';
import { NearLinkSecurityState, NearLinkEncryptionLabel } from '../domain/model/NearLinkSecurityState';
import { NearLinkConstants } from '../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../constants/NearLinkErrorCodes';

@ObservedV2
export class DataTransferViewModel {
  private static readonly PERIODIC_JOB_ID: string = 'nearlink-dt-periodic';

  @Trace pageState: UiPageState = UiPageState.CONTENT;
  @Trace deviceId: string = '';
  @Trace displayName: string = '';
  @Trace sessionId: string = '';
  @Trace portUuid: string = '';
  @Trace mtu: number = NearLinkConstants.DEFAULT_MTU;
  @Trace secureRequired: boolean = false;
  @Trace securityState: NearLinkSecurityState = NearLinkSecurityState.NOT_REQUIRED;
  @Trace encryptionLabel: string = NearLinkEncryptionLabel.NOT_REQUIRED;
  @Trace runtimeState: DataTransferRuntimeState = DataTransferRuntimeState.IDLE;
  @Trace sendPayload: string = '';
  @Trace encoding: PayloadEncoding = PayloadEncoding.HEX;
  @Trace lineEnding: LineEndingMode = LineEndingMode.NONE;
  @Trace terminalLog: DataTransferPacket[] = [];
  @Trace statusMessage: string = '';
  @Trace showPortPanel: boolean = true;
  @Trace periodicSendEnabled: boolean = false;
  @Trace periodicIntervalMs: number = 1000;
  @Trace periodicPayload: string = '';

  private readonly connectUseCase: ConnectDataTransferUseCase = new ConnectDataTransferUseCase();
  private readonly sendCommand: SendNearLinkCommandUseCase = new SendNearLinkCommandUseCase();
  private readonly pairDevice: PairNearLinkDeviceUseCase = new PairNearLinkDeviceUseCase();
  private readonly observePackets: ObserveDataTransferPacketsUseCase = new ObserveDataTransferPacketsUseCase();
  private readonly startRepeat: StartRepeatCommandUseCase = new StartRepeatCommandUseCase();
  private readonly stopRepeat: StopRepeatCommandUseCase = new StopRepeatCommandUseCase();
  private packetSub: Subscription | undefined;

  bindTarget(deviceId: string, displayName: string): void {
    this.deviceId = deviceId;
    this.displayName = displayName;
  }

  initializeObservers(): void {
    if (this.packetSub !== undefined) {
      return;
    }
    this.packetSub = this.observePackets.execute((packet: DataTransferPacket) => {
      this.terminalLog = [...this.terminalLog, packet];
    });
  }

  dispose(): void {
    this.stopPeriodicSend();
    this.packetSub?.dispose();
    if (this.sessionId.length > 0) {
      void this.disconnectAction();
    }
  }

  updateSecurityLabel(): void {
    if (!this.secureRequired) {
      this.encryptionLabel = NearLinkEncryptionLabel.NOT_REQUIRED;
      this.securityState = NearLinkSecurityState.NOT_REQUIRED;
      return;
    }
    if (this.securityState === NearLinkSecurityState.ENCRYPTED) {
      this.encryptionLabel = NearLinkEncryptionLabel.ENCRYPTED;
    } else {
      this.encryptionLabel = NearLinkEncryptionLabel.UNVERIFIED;
    }
  }

  async pairOnlyAction(): Promise<void> {
    this.runtimeState = DataTransferRuntimeState.PAIRING;
    const result: Result<NearLinkSecurityState> = await this.pairDevice.execute(this.deviceId);
    if (!result.success || result.value === undefined) {
      this.securityState = NearLinkSecurityState.FAILED;
      this.runtimeState = DataTransferRuntimeState.FAILED;
      this.statusMessage = result.error?.message ?? 'Pairing failed';
      this.updateSecurityLabel();
      return;
    }
    this.securityState = result.value;
    this.runtimeState = DataTransferRuntimeState.IDLE;
    this.updateSecurityLabel();
    this.statusMessage = this.securityState === NearLinkSecurityState.ENCRYPTED ? 'Pairing OK, encrypted' : 'Pairing done, encryption unverified';
  }

  async connectAction(): Promise<void> {
    this.initializeObservers();
    this.runtimeState = this.secureRequired
      ? DataTransferRuntimeState.PAIRING
      : DataTransferRuntimeState.CONNECTING;
    const config = new DataTransferPortConfig(
      this.portUuid,
      this.mtu,
      this.secureRequired,
      new CongestionPolicy(
        NearLinkConstants.CONGESTION_INITIAL_BACKOFF_MS,
        NearLinkConstants.CONGESTION_MAX_BACKOFF_MS,
        NearLinkConstants.CONGESTION_MAX_RETRY
      )
    );
    const result: Result<ConnectDataTransferResult> = await this.connectUseCase.execute(this.deviceId, this.displayName, config);
    if (!result.success || result.value === undefined) {
      this.runtimeState = DataTransferRuntimeState.FAILED;
      this.statusMessage = result.error?.message ?? 'Connect failed';
      if (this.secureRequired) {
        this.securityState = NearLinkSecurityState.UNKNOWN;
        this.updateSecurityLabel();
      }
      return;
    }
    this.sessionId = result.value.sessionId;
    this.securityState = result.value.securityState;
    this.runtimeState = DataTransferRuntimeState.CONNECTED;
    this.showPortPanel = false;
    this.updateSecurityLabel();
    this.statusMessage = 'dataTransfer connected';
    if (this.periodicSendEnabled) {
      await this.startPeriodicSend();
    }
  }

  async sendAction(): Promise<void> {
    if (this.sessionId.length === 0 || this.portUuid.length === 0 || this.sendPayload.length === 0) {
      return;
    }
    this.runtimeState = DataTransferRuntimeState.SENDING;
    const result: Result<DebugLogRecord | void> = await this.sendCommand.execute(
      this.sessionId,
      this.sendPayload,
      this.encoding,
      this.lineEnding
    );
    if (!result.success && result.error?.code === NearLinkErrorCodes.DT_WRITE_CONGESTED) {
      this.runtimeState = DataTransferRuntimeState.CONGESTED;
      this.statusMessage = 'Write congested (backoff applied)';
      return;
    }
    this.runtimeState = result.success ? DataTransferRuntimeState.CONNECTED : DataTransferRuntimeState.FAILED;
    if (result.success) {
      const hex = this.encoding === PayloadEncoding.HEX ? this.sendPayload : this.sendPayload;
      this.terminalLog = [...this.terminalLog, new DataTransferPacket('out', hex, TimeUtil.nowMs())];
    }
    this.statusMessage = result.success ? 'Sent' : (result.error?.message ?? 'Send failed');
  }

  togglePeriodicSend(enable: boolean): void {
    this.periodicSendEnabled = enable;
    if (enable) {
      void this.startPeriodicSend();
    } else {
      this.stopPeriodicSend();
    }
  }

  async startPeriodicSend(): Promise<void> {
    this.stopPeriodicSend();
    if (!this.periodicSendEnabled || this.periodicPayload.length === 0 || this.sessionId.length === 0) {
      return;
    }
    const transport = TransportSessionRegistry.getInstance().get(this.sessionId);
    if (transport === undefined) {
      return;
    }
    const input = new SendCommandInput(
      this.sessionId,
      transport,
      this.periodicPayload,
      this.encoding,
      this.lineEnding
    );
    const policy = new RepeatPolicy(this.periodicIntervalMs, 0, 0, false, false);
    await this.startRepeat.execute(DataTransferViewModel.PERIODIC_JOB_ID, input, policy);
  }

  stopPeriodicSend(): void {
    this.stopRepeat.execute(DataTransferViewModel.PERIODIC_JOB_ID);
  }

  async disconnectAction(): Promise<void> {
    this.stopPeriodicSend();
    if (this.sessionId.length === 0) {
      return;
    }
    this.runtimeState = DataTransferRuntimeState.DISCONNECTING;
    const sessionId = this.sessionId;
    const disconnect = new DisconnectDataTransferUseCase();
    await disconnect.execute(sessionId, this.portUuid);
    this.stopRepeat.stopForSession(sessionId);
    this.sessionId = '';
    this.runtimeState = DataTransferRuntimeState.DISCONNECTED;
    this.showPortPanel = true;
    this.statusMessage = 'Disconnected';
  }
}
