import { Result, Subscription } from 'common_core';
import { RiskConfirmDialog, UiPageState } from 'common_ui';
import { NearLinkRepository } from '../data/repository/NearLinkRepository';
import {
  ConnectSsapClientUseCase,
  DisconnectSsapClientUseCase,
  ReadSsapPropertyUseCase,
  WriteSsapPropertyUseCase,
  SetSsapNotificationUseCase,
  RequestSsapMtuUseCase,
  ObserveSsapPropertyNotifyUseCase
} from '../domain/usecase/NearLinkExtendedUseCases';
import { SsapClientState, SsapServiceTreeSnapshot } from '../domain/model/SsapServiceTree';
import { NearLinkConstants } from '../constants/NearLinkConstants';

@ObservedV2
export class SsapClientViewModel {
  @Trace pageState: UiPageState = UiPageState.CONTENT;
  @Trace deviceId: string = '';
  @Trace displayName: string = '';
  @Trace sessionId: string = '';
  @Trace ssapState: SsapClientState = SsapClientState.IDLE;
  @Trace serviceTree: SsapServiceTreeSnapshot | undefined;
  @Trace mtu: number = NearLinkConstants.DEFAULT_MTU;
  @Trace writeHex: string = '';
  @Trace readResultHex: string = '';
  @Trace notifyLog: string[] = [];
  @Trace statusMessage: string = '';
  @Trace pendingServiceUuid: string = '';
  @Trace pendingPropertyUuid: string = '';

  private treeSub: Subscription | undefined;
  private notifySub: Subscription | undefined;
  private readonly repository: NearLinkRepository = NearLinkRepository.getInstance();
  private readonly connectSsap: ConnectSsapClientUseCase = new ConnectSsapClientUseCase();
  private readonly disconnectSsap: DisconnectSsapClientUseCase = new DisconnectSsapClientUseCase();
  private readonly readProperty: ReadSsapPropertyUseCase = new ReadSsapPropertyUseCase();
  private readonly writeProperty: WriteSsapPropertyUseCase = new WriteSsapPropertyUseCase();
  private readonly setNotification: SetSsapNotificationUseCase = new SetSsapNotificationUseCase();
  private readonly requestMtu: RequestSsapMtuUseCase = new RequestSsapMtuUseCase();
  private readonly observeNotify: ObserveSsapPropertyNotifyUseCase = new ObserveSsapPropertyNotifyUseCase();

  bindTarget(deviceId: string, displayName: string): void {
    this.deviceId = deviceId;
    this.displayName = displayName;
  }

  initializeObservers(): void {
    this.treeSub = this.repository.observeSsapTree().subscribe((tree: SsapServiceTreeSnapshot) => {
      this.serviceTree = tree;
      this.ssapState = tree.state;
      this.mtu = tree.mtu;
    });
  }

  dispose(): void {
    this.treeSub?.dispose();
    this.notifySub?.dispose();
    if (this.sessionId.length > 0) {
      void this.disconnectSsap.execute(this.sessionId);
    }
  }

  async connectAction(): Promise<void> {
    const result = await this.connectSsap.execute(this.deviceId, this.displayName);
    if (!result.success || result.value === undefined) {
      this.statusMessage = result.error?.message ?? 'SSAP connect failed';
      this.ssapState = SsapClientState.FAILED;
      return;
    }
    this.sessionId = result.value;
    this.ssapState = SsapClientState.CONNECTING;
    this.statusMessage = 'SSAP connecting';
    this.notifySub?.dispose();
    this.notifySub = this.observeNotify.execute(this.sessionId, (payload) => {
      this.notifyLog = [...this.notifyLog, `${payload.propertyUuid}: ${payload.valueHex}`];
    });
  }

  async disconnectAction(): Promise<void> {
    if (this.sessionId.length === 0) {
      return;
    }
    await this.disconnectSsap.execute(this.sessionId);
    this.sessionId = '';
    this.ssapState = SsapClientState.CLOSED;
    this.statusMessage = 'SSAP disconnected';
  }

  selectProperty(serviceUuid: string, propertyUuid: string): void {
    this.pendingServiceUuid = serviceUuid;
    this.pendingPropertyUuid = propertyUuid;
  }

  async readSelected(): Promise<void> {
    if (this.sessionId.length === 0 || this.pendingPropertyUuid.length === 0) {
      return;
    }
    const result = await this.readProperty.execute(this.sessionId, this.pendingServiceUuid, this.pendingPropertyUuid);
    this.readResultHex = result.success && result.value !== undefined ? result.value : (result.error?.message ?? '');
  }

  async writeSelected(): Promise<void> {
    if (this.sessionId.length === 0 || this.pendingPropertyUuid.length === 0) {
      return;
    }
    const result = await this.writeProperty.execute(
      this.sessionId,
      this.pendingServiceUuid,
      this.pendingPropertyUuid,
      this.writeHex
    );
    this.statusMessage = result.success ? 'Write OK' : (result.error?.message ?? 'Write failed');
  }

  async toggleNotify(enable: boolean): Promise<void> {
    if (this.sessionId.length === 0 || this.pendingPropertyUuid.length === 0) {
      return;
    }
    const result = await this.setNotification.execute(
      this.sessionId,
      this.pendingServiceUuid,
      this.pendingPropertyUuid,
      enable
    );
    this.statusMessage = result.success ? (enable ? 'Notify on' : 'Notify off') : (result.error?.message ?? 'Notify failed');
  }

  async requestMtuAction(mtu: number): Promise<void> {
    if (this.sessionId.length === 0) {
      return;
    }
    const result: Result<number> = await this.requestMtu.execute(this.sessionId, mtu);
    this.statusMessage = result.success ? `MTU request sent (${mtu})` : (result.error?.message ?? 'MTU failed');
  }

  promptLeave(onLeave: () => void): void {
    if (this.ssapState === SsapClientState.CONNECTED || this.ssapState === SsapClientState.READY) {
      RiskConfirmDialog.show({
        title: '离开 SSAP 页面',
        message: '选择离开方式：释放订阅将断开连接；后台保持将维持会话。',
        confirmLabel: '释放订阅并返回',
        cancelLabel: '后台保持并返回',
        onConfirm: () => {
          void this.disconnectAction();
          onLeave();
        },
        onCancel: () => {
          onLeave();
        }
      });
      return;
    }
    onLeave();
  }
}
