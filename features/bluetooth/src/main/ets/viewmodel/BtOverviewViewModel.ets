import { Subscription } from 'common_core';
import {
  AbilityContextRegistry,
  BluetoothSettingsNavigator,
  LifecycleCoordinator,
  PermissionUiState
} from 'common_platform';
import {
  EnsurePermissionUseCase,
  PermissionScenario,
  PermissionScenarioCoordinator
} from 'feature_debug_core';
import { BluetoothAdapterSnapshot, BluetoothOverviewSnapshot } from '../domain/model/BluetoothDevice';
import { BluetoothRepository } from '../data/repository/BluetoothRepository';
import { LoadBluetoothOverviewSnapshotUseCase } from '../domain/usecase/overview/OverviewUseCases';

@ObservedV2
export class BtOverviewViewModel {
  @Trace isLoading: boolean = true;
  @Trace permissionGranted: boolean = false;
  @Trace permissionUiState: PermissionUiState | undefined = undefined;
  @Trace adapterEnabled: boolean = false;
  @Trace classicSupported: boolean = true;
  @Trace bleSupported: boolean = true;

  private readonly loadOverview: LoadBluetoothOverviewSnapshotUseCase;
  private readonly ensurePermission: EnsurePermissionUseCase;
  private readonly repository: BluetoothRepository;
  private adapterSubscription: Subscription | undefined;
  private lifecycleUnsubscribe: (() => void) | undefined;

  constructor(
    loadOverview: LoadBluetoothOverviewSnapshotUseCase = new LoadBluetoothOverviewSnapshotUseCase(),
    ensurePermission: EnsurePermissionUseCase = new EnsurePermissionUseCase(),
    repository: BluetoothRepository = BluetoothRepository.getInstance()
  ) {
    this.loadOverview = loadOverview;
    this.ensurePermission = ensurePermission;
    this.repository = repository;
  }

  async onPageAppear(): Promise<void> {
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
    const result = await this.loadOverview.execute();
    if (result.success && result.value !== undefined) {
      this.applySnapshot(result.value);
    }
    await this.syncPermissionUiState();
    this.isLoading = false;
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
    return this.permissionGranted && this.adapterEnabled && this.classicSupported;
  }

  isBleReady(): boolean {
    return this.permissionGranted && this.adapterEnabled && this.bleSupported;
  }

  private applySnapshot(snapshot: BluetoothOverviewSnapshot): void {
    this.permissionGranted = snapshot.permissionGranted;
    this.classicSupported = snapshot.classicSupported;
    this.bleSupported = snapshot.bleSupported;
    this.applyAdapter(snapshot.adapter);
  }

  private applyAdapter(snapshot: BluetoothAdapterSnapshot): void {
    this.adapterEnabled = snapshot.enabled;
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
