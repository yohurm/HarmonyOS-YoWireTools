import { Result, Subscription, TimeUtil } from 'common_core';
import { UiPageState } from 'common_ui';
import { BluetoothRepository } from '../data/repository/BluetoothRepository';
import { StartBleScanUseCase, StopBleScanUseCase, ObserveBluetoothDevicesUseCase, BluetoothSubscriptionBundle } from '../domain/usecase/BluetoothUseCases';
import { SaveBluetoothFavoriteUseCase } from '../domain/usecase/BluetoothExtendedUseCases';
import { BleScanFilter, BleScanDutyPreset } from '../domain/model/BleScanFilter';
import { BluetoothDevice } from '../domain/model/BluetoothDevice';
import { BleScanPhase } from '../domain/model/BleScanPhase';
import { BleAdvertisingPacket } from '../domain/model/BleAdvertisingPacket';
import { RssiSample } from '../domain/model/RssiSample';

@ObservedV2
export class BleScanViewModel {
  @Trace pageState: UiPageState = UiPageState.CONTENT;
  @Trace devices: BluetoothDevice[] = [];
  @Trace scanPhase: BleScanPhase = BleScanPhase.IDLE;
  @Trace selectedDevice: BluetoothDevice | undefined;
  @Trace selectedAdvertising: BleAdvertisingPacket | undefined;
  @Trace statusMessage: string = '';
  @Trace namePrefix: string = '';
  @Trace serviceUuid: string = '';
  @Trace minRssi: number = -127;
  @Trace dutyPreset: BleScanDutyPreset = BleScanDutyPreset.BALANCED;

  @Trace rssiSamples: RssiSample[] = [];
  @Trace manufacturerId: string = '';
  @Trace manufacturerData: string = '';
  @Trace manufacturerMask: string = '';
  @Trace favoritesOnly: boolean = false;
  @Trace favoriteAlias: string = '';

  private scanSessionId: string = '';
  private readonly maxRssiSamples: number = 60;
  private readonly repository: BluetoothRepository = BluetoothRepository.getInstance();
  private readonly startScan: StartBleScanUseCase = new StartBleScanUseCase();
  private readonly stopScan: StopBleScanUseCase = new StopBleScanUseCase();
  private readonly observeDevices: ObserveBluetoothDevicesUseCase = new ObserveBluetoothDevicesUseCase();
  private readonly saveFavorite: SaveBluetoothFavoriteUseCase = new SaveBluetoothFavoriteUseCase();
  private bleSub: BluetoothSubscriptionBundle | undefined;

  initialize(): void {
    this.bleSub = this.observeDevices.execute(
      () => {
      },
      (devices: BluetoothDevice[]) => {
        this.devices = devices;
        this.trackRssiForSelected(devices);
      }
    );
    this.scanPhase = this.repository.getBleScanPhase();
  }

  dispose(): void {
    this.bleSub?.dispose();
    void this.stopScan.execute(this.scanSessionId);
  }

  buildFilter(): BleScanFilter {
    const manufacturerId = parseInt(this.manufacturerId, 10);
    return new BleScanFilter(
      this.namePrefix,
      '',
      this.serviceUuid,
      Number.isNaN(manufacturerId) ? -1 : manufacturerId,
      this.manufacturerData,
      this.manufacturerMask,
      this.minRssi,
      this.favoritesOnly,
      this.dutyPreset
    );
  }

  async startScanAction(): Promise<void> {
    const filter = this.buildFilter();
    const result: Result<string> = await this.startScan.execute(this.serviceUuid, filter);
    if (!result.success || result.value === undefined) {
      this.scanPhase = BleScanPhase.FAILED;
      this.statusMessage = result.error?.message ?? 'BLE scan failed';
      return;
    }
    this.scanSessionId = result.value;
    this.scanPhase = BleScanPhase.SCANNING;
    this.statusMessage = this.repository.getBleScanPhase() === BleScanPhase.SCANNING ? 'BLE scanning' : 'BLE scanning (legacy API)';
  }

  async stopScanAction(): Promise<void> {
    await this.stopScan.execute(this.scanSessionId);
    this.scanSessionId = '';
    this.scanPhase = this.repository.getBleScanPhase();
  }

  selectDevice(device: BluetoothDevice): void {
    this.selectedDevice = device;
    this.selectedAdvertising = this.repository.getBleAdvertising(device.deviceId);
    this.rssiSamples = [];
    this.trackRssiForSelected(this.devices);
  }

  private trackRssiForSelected(devices: BluetoothDevice[]): void {
    if (this.selectedDevice === undefined) {
      return;
    }
    for (let i = 0; i < devices.length; i++) {
      if (devices[i].deviceId === this.selectedDevice.deviceId) {
        const sample = new RssiSample(TimeUtil.nowMs(), devices[i].rssi);
        const next = [...this.rssiSamples, sample];
        this.rssiSamples = next.length > this.maxRssiSamples ? next.slice(next.length - this.maxRssiSamples) : next;
        break;
      }
    }
  }

  async favoriteSelected(alias: string): Promise<void> {
    if (this.selectedDevice === undefined) {
      return;
    }
    await this.saveFavorite.execute(this.selectedDevice, alias, 'ble_gatt');
  }
}
