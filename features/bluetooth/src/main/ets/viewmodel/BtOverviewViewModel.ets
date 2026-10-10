import { Subscription } from 'common_core';
import {
  AbilityContextRegistry,
  BluetoothSettingsNavigator,
  CapabilityRegistry,
  CapabilityStatus,
  LifecycleCoordinator,
  PermissionUiState
} from 'common_platform';
import {
  CapabilityId,
  EnsurePermissionUseCase,
  PermissionScenario,
  PermissionScenarioCoordinator
} from 'debug_core';
import {
  BluetoothAdapterSnapshot,
  AdapterOperationalDecision,
  BluetoothConstants,
  BluetoothOverviewSnapshot,
  BluetoothRepository,
  DisableBluetoothUseCase,
  EnableBluetoothUseCase,
  LoadBluetoothOverviewSnapshotUseCase
} from 'yobluetooth';

@ObservedV2
export class BtOverviewViewModel {
  @Trace isLoading: boolean = true;
  @Trace permissionGranted: boolean = false;
  @Trace permissionUiState: PermissionUiState | undefined = undefined;
  @Trace adapterEnabled: boolean = false;
  @Trace adapterStateCode: number = BluetoothConstants.ADAPTER_STATE_OFF;
  @Trace switchPending: boolean = false;
  @Trace emulatorBlocked: boolean = false;
  @Trace serviceStopped: boolean = false;
  @Trace actionMessage: string = '';
  @Trace classicSupported: boolean = true;
  @Trace bleSupported: boolean = true;

  private readonly loadOverview: LoadBluetoothOverviewSnapshotUseCase;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly enableBluetooth: EnableBluetoothUseCase;
  private readonly disableBluetooth: DisableBluetoothUseCase;
  private readonly repository: BluetoothRepository;
  private adapterSubscription: Subscription | undefined;
  private lifecycleUnsubscribe: (() => void) | undefined;

  constructor(
    loadOverview: LoadBluetoothOverviewSnapshotUseCase = new LoadBluetoothOverviewSnapshotUseCase(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    enableBluetooth: EnableBluetoothUseCase = new EnableBluetoothUseCase(),
    disableBluetooth: DisableBluetoothUseCase = new DisableBluetoothUseCase(),
    repository: BluetoothRepository = BluetoothRepository.getInstance()
  ) {
    this.loadOverview = loadOverview;
    this.ensurePermission = ensurePermission;
    this.enableBluetooth = enableBluetooth;
    this.disableBluetooth = disableBluetooth;
    this.repository = repository;
  }

  async onPageAppear(): Promise<void> {
    const probed = await CapabilityRegistry.getInstance().probe(CapabilityId.BLUETOOTH_ADAPTER_STATE);
    if (probed.status === CapabilityStatus.UNAVAILABLE && probed.reason === 'emulator') {
      this.emulatorBlocked = true;
      this.adapterEnabled = false;
      this.isLoading = false;
      return;
    }
    this.repository.offAdapterStateChange();
    this.repository.onAdapterStateChange((snapshot: BluetoothAdapterSnapshot) => {
      this.applyAdapter(snapshot);
    });
    this.adapterSubscription = this.repository.observeAdapterState().subscribe((snapshot: BluetoothAdapterSnapshot) => {
      this.applyAdapter(snapshot);
    });
    this.lifecycleUnsubscribe = LifecycleCoordinator.getInstance().addReconcileCallback(async () => {
      await this.refresh();
    });
    await this.refresh();
  }

  onPageDisappear(): void {
    this.repository.offAdapterStateChange();
    if (this.adapterSubscription !== undefined) {
      this.adapterSubscription.dispose();
      this.adapterSubscription = undefined;
    }
    if (this.lifecycleUnsubscribe !== undefined) {
      this.lifecycleUnsubscribe();
      this.lifecycleUnsubscribe = undefined;
    }
  }

  async refresh(): Promise<void> {
    this.isLoading = true;
    const probed = await CapabilityRegistry.getInstance().probe(CapabilityId.BLUETOOTH_ADAPTER_STATE);
    if (probed.status === CapabilityStatus.UNAVAILABLE && probed.reason === 'emulator') {
      this.emulatorBlocked = true;
      this.adapterEnabled = false;
      this.adapterStateCode = BluetoothConstants.ADAPTER_STATE_OFF;
      this.switchPending = false;
      this.isLoading = false;
      return;
    }
    this.emulatorBlocked = false;
    const result = await this.loadOverview.execute();
    if (result.success && result.value !== undefined) {
      this.applySnapshot(result.value);
    }
    this.serviceStopped = this.repository.isServiceStopped();
    await this.syncPermissionUiState();
    this.isLoading = false;
  }

  async requestEnable(): Promise<void> {
    if (this.emulatorBlocked) {
      return;
    }
    this.switchPending = true;
    this.actionMessage = '';
    const result = await this.enableBluetooth.execute();
    this.switchPending = false;
    if (!result.success) {
      this.actionMessage = result.error?.message ?? '';
    }
  }

  async requestDisable(): Promise<void> {
    if (this.emulatorBlocked) {
      return;
    }
    this.switchPending = true;
    this.actionMessage = '';
    const result = await this.disableBluetooth.execute();
    this.switchPending = false;
    if (!result.success) {
      this.actionMessage = result.error?.message ?? '';
    }
  }

  async requestPermission(): Promise<void> {
    await this.ensurePermission.execute(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
    await this.refresh();
  }

  async openBluetoothSettings(): Promise<void> {
    const context = AbilityContextRegistry.getInstance().get();
    if (context !== undefined) {
      await BluetoothSettingsNavigator.openBluetoothSettings(context);
    }
  }

  isClassicReady(): boolean {
    return !this.emulatorBlocked && !this.switchPending && !this.serviceStopped &&
      this.permissionGranted &&
      AdapterOperationalDecision.isOperational(this.adapterStateCode) &&
      this.classicSupported;
  }

  isBleReady(): boolean {
    return !this.emulatorBlocked && !this.switchPending && !this.serviceStopped &&
      this.permissionGranted &&
      AdapterOperationalDecision.isOperational(this.adapterStateCode) &&
      this.bleSupported;
  }

  adapterLabel(): ResourceStr {
    if (this.emulatorBlocked) {
      return $r('app.string.bt_status_emulator');
    }
    if (this.switchPending) {
      return $r('app.string.bt_status_switching');
    }
    if (this.adapterStateCode === BluetoothConstants.ADAPTER_STATE_ON) {
      return $r('app.string.bt_status_on');
    }
    if (this.adapterStateCode === BluetoothConstants.ADAPTER_STATE_TURNING_ON) {
      return $r('app.string.bt_status_turning_on');
    }
    if (this.adapterStateCode === BluetoothConstants.ADAPTER_STATE_TURNING_OFF) {
      return $r('app.string.bt_status_turning_off');
    }
    if (this.adapterStateCode === BluetoothConstants.ADAPTER_STATE_BLE_TURNING_ON) {
      return $r('app.string.bt_status_ble_turning_on');
    }
    if (this.adapterStateCode === BluetoothConstants.ADAPTER_STATE_BLE_ON) {
      return $r('app.string.bt_status_ble_on');
    }
    if (this.adapterStateCode === BluetoothConstants.ADAPTER_STATE_BLE_TURNING_OFF) {
      return $r('app.string.bt_status_ble_turning_off');
    }
    return $r('app.string.bt_status_off');
  }

  private applySnapshot(snapshot: BluetoothOverviewSnapshot): void {
    this.permissionGranted = snapshot.permissionGranted;
    this.classicSupported = snapshot.classicSupported;
    this.bleSupported = snapshot.bleSupported;
    this.applyAdapter(snapshot.adapter);
  }

  private applyAdapter(snapshot: BluetoothAdapterSnapshot): void {
    if (this.emulatorBlocked) {
      return;
    }
    this.adapterEnabled = snapshot.enabled;
    this.adapterStateCode = snapshot.stateCode;
    this.switchPending = false;
  }

  private async syncPermissionUiState(): Promise<void> {
    if (this.permissionGranted) {
      this.permissionUiState = undefined;
      return;
    }
    this.permissionUiState = await PermissionScenarioCoordinator.getInstance()
      .buildUiStateForScenario(PermissionScenario.BLUETOOTH_SCAN_CONNECT);
  }
}
