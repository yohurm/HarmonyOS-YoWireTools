import { Subscription } from 'common_core';
import { LifecycleCoordinator, PermissionUiState } from 'common_platform';
import {
  EnsurePermissionUseCase,
  PermissionScenario,
  PermissionScenarioCoordinator,
  StopSessionUseCase
} from 'debug_core';
import { NearLinkErrorCodes } from '../constants/NearLinkErrorCodes';
import { NearLinkDevice } from '../domain/model/NearLinkDevice';
import { NearLinkScanFilter } from '../domain/model/NearLinkScanFilter';
import { NearLinkScanPhase } from '../domain/model/NearLinkScanPhase';
import {
  ObserveNearLinkAdapterUseCase,
  ObserveNearLinkDevicesUseCase,
  ObserveNearLinkScanPhaseUseCase,
  ReadNearLinkScanFailureUseCase,
  ResolveNearLinkCapabilityUseCase,
  StartNearLinkScanUseCase,
  StopNearLinkScanUseCase
} from '../domain/usecase/NearLinkUseCases';

@ObservedV2
export class NearLinkOverviewViewModel {
  @Trace hasLoaded: boolean = false;
  @Trace permissionGranted: boolean = false;
  @Trace supported: boolean = false;
  @Trace switchOn: boolean = false;
  @Trace readyForScan: boolean = false;
  @Trace permissionUiState: PermissionUiState | undefined = undefined;
  @Trace devices: NearLinkDevice[] = [];
  @Trace scanPhase: NearLinkScanPhase = NearLinkScanPhase.IDLE;
  @Trace deviceNameFilter: string = '';
  @Trace scanErrorCode: string = '';

  private readonly resolveCapability: ResolveNearLinkCapabilityUseCase;
  private readonly startScanUseCase: StartNearLinkScanUseCase;
  private readonly stopScanUseCase: StopNearLinkScanUseCase;
  private readonly observeDevices: ObserveNearLinkDevicesUseCase;
  private readonly observePhase: ObserveNearLinkScanPhaseUseCase;
  private readonly observeAdapter: ObserveNearLinkAdapterUseCase;
  private readonly readFailure: ReadNearLinkScanFailureUseCase;
  private readonly stopSession: StopSessionUseCase;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private scanSessionId: string = '';
  private deviceSubscription: Subscription | undefined;
  private phaseSubscription: Subscription | undefined;
  private adapterSubscription: Subscription | undefined;
  private lifecycleUnsubscribe: (() => void) | undefined;
  private refreshEpoch: number = 0;

  constructor(
    resolveCapability: ResolveNearLinkCapabilityUseCase = new ResolveNearLinkCapabilityUseCase(),
    startScanUseCase: StartNearLinkScanUseCase = new StartNearLinkScanUseCase(),
    stopScanUseCase: StopNearLinkScanUseCase = new StopNearLinkScanUseCase(),
    observeDevices: ObserveNearLinkDevicesUseCase = new ObserveNearLinkDevicesUseCase(),
    observePhase: ObserveNearLinkScanPhaseUseCase = new ObserveNearLinkScanPhaseUseCase(),
    observeAdapter: ObserveNearLinkAdapterUseCase = new ObserveNearLinkAdapterUseCase(),
    readFailure: ReadNearLinkScanFailureUseCase = new ReadNearLinkScanFailureUseCase(),
    stopSession: StopSessionUseCase = new StopSessionUseCase(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase()
  ) {
    this.resolveCapability = resolveCapability;
    this.startScanUseCase = startScanUseCase;
    this.stopScanUseCase = stopScanUseCase;
    this.observeDevices = observeDevices;
    this.observePhase = observePhase;
    this.observeAdapter = observeAdapter;
    this.readFailure = readFailure;
    this.stopSession = stopSession;
    this.ensurePermission = ensurePermission;
  }

  async onPageAppear(): Promise<void> {
    this.deviceSubscription = this.observeDevices.execute((devices: NearLinkDevice[]) => {
      this.devices = devices;
    });
    this.phaseSubscription = this.observePhase.execute((phase: NearLinkScanPhase) => {
      this.onScanPhase(phase);
    });
    this.adapterSubscription = this.observeAdapter.execute(() => {
      void this.refresh();
    });
    this.lifecycleUnsubscribe = LifecycleCoordinator.getInstance().addReconcileCallback(async () => {
      await this.refresh();
    });
    await this.refresh();
  }

  onPageDisappear(): void {
    this.disposeSubscription(this.deviceSubscription);
    this.deviceSubscription = undefined;
    this.disposeSubscription(this.phaseSubscription);
    this.phaseSubscription = undefined;
    this.disposeSubscription(this.adapterSubscription);
    this.adapterSubscription = undefined;
    if (this.lifecycleUnsubscribe !== undefined) {
      this.lifecycleUnsubscribe();
      this.lifecycleUnsubscribe = undefined;
    }
  }

  async refresh(): Promise<void> {
    const epoch = ++this.refreshEpoch;
    const resolved = await this.resolveCapability.execute();
    if (epoch !== this.refreshEpoch) {
      return;
    }
    if (resolved.success && resolved.value !== undefined) {
      this.permissionGranted = resolved.value.permissionGranted;
      this.supported = resolved.value.supported;
      this.switchOn = resolved.value.switchOn;
      this.readyForScan = resolved.value.readyForScan;
    }
    await this.syncPermissionUiState();
    if (epoch === this.refreshEpoch) {
      this.hasLoaded = true;
    }
  }

  async requestPermission(): Promise<void> {
    await this.ensurePermission.execute(PermissionScenario.NEARLINK_ACCESS);
    await this.refresh();
  }

  setDeviceNameFilter(value: string): void {
    this.deviceNameFilter = value;
  }

  isScanning(): boolean {
    return this.scanPhase === NearLinkScanPhase.SCANNING;
  }

  canStartScan(): boolean {
    return this.readyForScan && !this.isScanning();
  }

  scanDisabledReason(): ResourceStr {
    if (this.isScanning()) {
      return '';
    }
    if (!this.supported) {
      return $r('app.string.nl_scan_disabled_unsupported');
    }
    if (!this.switchOn) {
      return $r('app.string.nl_scan_disabled_switch');
    }
    if (!this.readyForScan) {
      return $r('app.string.nl_scan_disabled_capability');
    }
    return '';
  }

  async startScan(): Promise<void> {
    if (!this.canStartScan()) {
      return;
    }
    this.scanErrorCode = '';
    const name = this.deviceNameFilter.trim();
    const filter = new NearLinkScanFilter('', name, -1, '', '', name.length === 0);
    const started = await this.startScanUseCase.execute(filter);
    if (!started.success || started.value === undefined) {
      const code = started.error !== undefined ? started.error.code : NearLinkErrorCodes.SCAN_FAILED;
      if (code === NearLinkErrorCodes.PERMISSION_DENIED) {
        this.permissionGranted = false;
        await this.syncPermissionUiState();
        return;
      }
      this.scanErrorCode = code;
      return;
    }
    this.scanSessionId = started.value;
  }

  async stopScan(): Promise<void> {
    const sessionId = this.scanSessionId;
    this.scanSessionId = '';
    await this.stopScanUseCase.execute(sessionId);
  }

  private onScanPhase(phase: NearLinkScanPhase): void {
    this.scanPhase = phase;
    if (phase !== NearLinkScanPhase.FAILED) {
      return;
    }
    const code = this.readFailure.execute();
    if (code.length > 0) {
      this.scanErrorCode = code;
    }
    void this.closeFailedScanSession();
  }

  private async closeFailedScanSession(): Promise<void> {
    if (this.scanSessionId.length === 0) {
      return;
    }
    const sessionId = this.scanSessionId;
    this.scanSessionId = '';
    await this.stopSession.execute(sessionId, 'nearlink_scan_failed');
  }

  private async syncPermissionUiState(): Promise<void> {
    if (this.permissionGranted) {
      this.permissionUiState = undefined;
      return;
    }
    this.permissionUiState = await PermissionScenarioCoordinator.getInstance()
      .buildUiStateForScenario(PermissionScenario.NEARLINK_ACCESS);
  }

  private disposeSubscription(subscription: Subscription | undefined): void {
    if (subscription !== undefined) {
      subscription.dispose();
    }
  }
}
