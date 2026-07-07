import { Result, Subscription } from 'common_core';
import { UiPageState } from 'common_ui';
import { BluetoothRepository } from '../data/repository/BluetoothRepository';
import { BluetoothErrorCodes } from '../constants/BluetoothErrorCodes';
import {
  ObserveBluetoothDevicesUseCase,
  ObservePairingEventsUseCase,
  PairBluetoothDeviceUseCase,
  StartClassicScanUseCase,
  StopClassicScanUseCase,
  BluetoothSubscriptionBundle
} from '../domain/usecase/BluetoothUseCases';
import { LoadRemoteProfileUuidsUseCase } from '../domain/usecase/BluetoothExtendedUseCases';
import { BluetoothDevice, BluetoothDeviceKind } from '../domain/model/BluetoothDevice';
import { ClassicScanPhase } from '../domain/model/ClassicScanPhase';
import { PairingState } from '../domain/model/PairingState';
import { DiscoverySource } from '../domain/model/DiscoverySource';
import { BluetoothScanLogger } from '../domain/service/BluetoothScanLogger';

@ObservedV2
export class ClassicScanViewModel {
  @Trace pageState: UiPageState = UiPageState.CONTENT;
  @Trace devices: BluetoothDevice[] = [];
  @Trace scanPhase: ClassicScanPhase = ClassicScanPhase.IDLE;
  @Trace scanRemainingMs: number = 0;
  @Trace selectedDevice: BluetoothDevice | undefined;
  @Trace profileUuids: string[] = [];
  @Trace statusMessage: string = '';
  @Trace filterName: string = '';
  @Trace filterAddress: string = '';
  @Trace pairedOnly: boolean = false;
  @Trace favoritesOnly: boolean = false;
  @Trace stoppingForConnect: boolean = false;

  private scanSessionId: string = '';
  private readonly repository: BluetoothRepository = BluetoothRepository.getInstance();
  private readonly startScan: StartClassicScanUseCase = new StartClassicScanUseCase();
  private readonly stopScan: StopClassicScanUseCase = new StopClassicScanUseCase();
  private readonly pairDevice: PairBluetoothDeviceUseCase = new PairBluetoothDeviceUseCase();
  private readonly observeDevices: ObserveBluetoothDevicesUseCase = new ObserveBluetoothDevicesUseCase();
  private readonly observePairing: ObservePairingEventsUseCase = new ObservePairingEventsUseCase();
  private readonly loadProfiles: LoadRemoteProfileUuidsUseCase = new LoadRemoteProfileUuidsUseCase();
  private deviceSub: BluetoothSubscriptionBundle | undefined;
  private pairingSub: Subscription | undefined;
  private scanRemainingSub: Subscription | undefined;

  async initialize(): Promise<void> {
    await this.repository.loadPairedDevices();
    this.deviceSub = this.observeDevices.execute(
      (devices: BluetoothDevice[]) => {
        this.devices = devices;
      },
      () => {
      }
    );
    this.pairingSub = this.observePairing.execute(() => {
      void this.repository.loadPairedDevices();
    });
    this.scanRemainingSub = this.repository.observeScanRemainingMs().subscribe((ms: number) => {
      this.scanRemainingMs = ms;
      if (ms === 0 && this.scanPhase === ClassicScanPhase.SCANNING) {
        this.scanPhase = this.repository.getClassicScanPhase();
        if (this.scanPhase === ClassicScanPhase.COMPLETED) {
          this.statusMessage = '扫描已完成';
        }
      }
    });
    this.scanPhase = this.repository.getClassicScanPhase();
    this.statusMessage = this.buildIdleStatus();
  }

  dispose(): void {
    this.deviceSub?.dispose();
    this.pairingSub?.dispose();
    this.scanRemainingSub?.dispose();
    void this.stopScan.execute(this.scanSessionId);
  }

  applyFilter(): void {
    this.repository.setClassicDeviceFilter(this.filterName, this.filterAddress, this.pairedOnly, this.favoritesOnly);
    this.devices = this.repository.listClassicDevices();
  }

  resetFilters(): void {
    this.filterName = '';
    this.filterAddress = '';
    this.pairedOnly = false;
    this.favoritesOnly = false;
    this.applyFilter();
  }

  async refreshPairedAction(): Promise<void> {
    this.statusMessage = '正在刷新已配对设备…';
    const result = await this.repository.loadPairedDevices();
    this.statusMessage = result.success ?
      `已刷新 ${this.pairedDevices().length} 台已配对设备` : (result.error?.message ?? '刷新失败');
  }

  async startScanAction(): Promise<void> {
    this.scanPhase = ClassicScanPhase.CHECKING_PERMISSION;
    const result: Result<string> = await this.startScan.execute();
    if (!result.success || result.value === undefined) {
      const code = result.error?.code ?? BluetoothErrorCodes.SCAN_RESOURCE_FAILED;
      if (code === BluetoothErrorCodes.PERMISSION_DENIED) {
        this.scanPhase = ClassicScanPhase.BLOCKED;
        this.statusMessage = '蓝牙权限未授权，无法扫描';
      } else if (code === BluetoothErrorCodes.ADAPTER_OFF) {
        this.scanPhase = ClassicScanPhase.CHECKING_ADAPTER;
        this.statusMessage = '蓝牙已关闭，请先开启蓝牙';
      } else {
        this.scanPhase = ClassicScanPhase.FAILED;
        this.statusMessage = result.error?.message ?? '扫描启动失败';
      }
      await BluetoothScanLogger.logClassic(this.scanSessionId, this.statusMessage, code);
      return;
    }
    this.scanSessionId = result.value;
    this.scanPhase = ClassicScanPhase.SCANNING;
    this.statusMessage = '正在扫描经典蓝牙设备…';
  }

  async stopScanAction(): Promise<void> {
    this.scanPhase = ClassicScanPhase.STOPPING;
    await this.stopScan.execute(this.scanSessionId);
    this.scanSessionId = '';
    this.scanPhase = this.repository.getClassicScanPhase();
    this.statusMessage = `扫描已停止，发现 ${this.discoveredDevices().length} 台设备`;
  }

  selectDevice(device: BluetoothDevice): void {
    this.selectedDevice = device;
    this.profileUuids = [];
    void this.loadProfiles.execute(device.deviceId).then((result: Result<string[]>) => {
      if (result.success && result.value !== undefined) {
        this.profileUuids = result.value;
      }
    });
  }

  clearSelection(): void {
    this.selectedDevice = undefined;
    this.profileUuids = [];
  }

  async pairSelected(): Promise<void> {
    if (this.selectedDevice === undefined) {
      return;
    }
    const result: Result<void> = await this.pairDevice.execute(this.selectedDevice.deviceId);
    this.statusMessage = result.success ? '已发起系统配对' : (result.error?.message ?? '配对失败');
  }

  /** Stops active scan before SPP connect per design. Returns true when navigation may proceed. */
  async prepareConnectSpp(): Promise<boolean> {
    if (this.scanPhase !== ClassicScanPhase.SCANNING && this.scanPhase !== ClassicScanPhase.STOPPING) {
      return true;
    }
    this.stoppingForConnect = true;
    this.statusMessage = '正在停止扫描以连接…';
    await this.stopScanAction();
    this.stoppingForConnect = false;
    return true;
  }

  isScanning(): boolean {
    return this.scanPhase === ClassicScanPhase.SCANNING || this.scanPhase === ClassicScanPhase.STOPPING ||
      this.stoppingForConnect;
  }

  canStartScan(): boolean {
    return this.scanPhase !== ClassicScanPhase.SCANNING &&
      this.scanPhase !== ClassicScanPhase.STOPPING &&
      this.scanPhase !== ClassicScanPhase.CHECKING_PERMISSION &&
      this.scanPhase !== ClassicScanPhase.BLOCKED &&
      this.scanPhase !== ClassicScanPhase.CHECKING_ADAPTER;
  }

  scanDisabledReason(): string {
    if (this.scanPhase === ClassicScanPhase.BLOCKED) {
      return '需要蓝牙权限';
    }
    if (this.scanPhase === ClassicScanPhase.CHECKING_ADAPTER) {
      return '请先开启蓝牙';
    }
    if (this.isScanning()) {
      return '扫描进行中';
    }
    return '';
  }

  scanStatusLabel(): string {
    switch (this.scanPhase) {
      case ClassicScanPhase.SCANNING:
        return `扫描中 · 剩余 ${this.formatScanRemaining()} · 已发现 ${this.discoveredDevices().length} 台`;
      case ClassicScanPhase.STOPPING:
        return '正在停止扫描…';
      case ClassicScanPhase.COMPLETED:
        return `扫描完成 · 发现 ${this.discoveredDevices().length} 台设备`;
      case ClassicScanPhase.BLOCKED:
        return '权限未授权，无法扫描';
      case ClassicScanPhase.CHECKING_ADAPTER:
        return '蓝牙未开启';
      case ClassicScanPhase.FAILED:
        return this.statusMessage.length > 0 ? this.statusMessage : '扫描失败';
      case ClassicScanPhase.CHECKING_PERMISSION:
        return '正在检查权限…';
      default:
        return this.statusMessage.length > 0 ? this.statusMessage : this.buildIdleStatus();
    }
  }

  formatScanRemaining(): string {
    const seconds = Math.ceil(this.scanRemainingMs / 1000);
    return `${seconds}s`;
  }

  pairedDevices(): BluetoothDevice[] {
    const result: BluetoothDevice[] = [];
    for (let i = 0; i < this.devices.length; i++) {
      const device = this.devices[i];
      if (device.kind !== BluetoothDeviceKind.CLASSIC) {
        continue;
      }
      if (device.paired || device.discoverySource === DiscoverySource.PAIRED) {
        result.push(device);
      }
    }
    return result;
  }

  discoveredDevices(): BluetoothDevice[] {
    const result: BluetoothDevice[] = [];
    for (let i = 0; i < this.devices.length; i++) {
      const device = this.devices[i];
      if (device.kind !== BluetoothDeviceKind.CLASSIC) {
        continue;
      }
      if (!device.paired && device.discoverySource !== DiscoverySource.PAIRED) {
        result.push(device);
      }
    }
    return result;
  }

  needsPairing(device: BluetoothDevice | undefined): boolean {
    if (device === undefined) {
      return false;
    }
    return !device.paired && device.pairState !== PairingState.PAIRED;
  }

  private buildIdleStatus(): string {
    return `已配对 ${this.pairedDevices().length} 台 · 待发现 ${this.discoveredDevices().length} 台`;
  }
}
