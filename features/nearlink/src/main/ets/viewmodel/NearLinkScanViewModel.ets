import { Result, Subscription } from 'common_core';
import { UiPageState } from 'common_ui';
import { NearLinkRepository } from '../data/repository/NearLinkRepository';
import {
  StartNearLinkScanUseCase,
  StopNearLinkScanUseCase,
  ObserveNearLinkDevicesUseCase
} from '../domain/usecase/NearLinkUseCases';
import { SaveNearLinkFavoriteUseCase } from '../domain/usecase/NearLinkExtendedUseCases';
import { NearLinkScanFilter, NearLinkScanMode } from '../domain/model/NearLinkScanFilter';
import { NearLinkDevice } from '../domain/model/NearLinkDevice';
import { NearLinkScanPhase } from '../domain/model/NearLinkScanPhase';
import { NearLinkAdvertisingPacket } from '../domain/model/NearLinkAdvertisingPacket';

@ObservedV2
export class NearLinkScanViewModel {
  @Trace pageState: UiPageState = UiPageState.CONTENT;
  @Trace devices: NearLinkDevice[] = [];
  @Trace scanPhase: NearLinkScanPhase = NearLinkScanPhase.IDLE;
  @Trace selectedDevice: NearLinkDevice | undefined;
  @Trace selectedAdvertising: NearLinkAdvertisingPacket | undefined;
  @Trace statusMessage: string = '';
  @Trace deviceName: string = '';
  @Trace address: string = '';
  @Trace manufacturerId: string = '';
  @Trace manufacturerData: string = '';
  @Trace manufacturerMask: string = '';
  @Trace scanMode: NearLinkScanMode = NearLinkScanMode.BALANCED;
  @Trace durationSec: number = 10;
  @Trace allowNullFilter: boolean = false;
  @Trace minRssi: number = -128;
  @Trace favoriteAlias: string = '';
  @Trace showFilterPanel: boolean = true;

  private scanSessionId: string = '';
  private readonly repository: NearLinkRepository = NearLinkRepository.getInstance();
  private readonly startScan: StartNearLinkScanUseCase = new StartNearLinkScanUseCase();
  private readonly stopScan: StopNearLinkScanUseCase = new StopNearLinkScanUseCase();
  private readonly observeDevices: ObserveNearLinkDevicesUseCase = new ObserveNearLinkDevicesUseCase();
  private readonly saveFavorite: SaveNearLinkFavoriteUseCase = new SaveNearLinkFavoriteUseCase();
  private deviceSub: Subscription | undefined;

  initialize(): void {
    this.deviceSub = this.observeDevices.execute((devices: NearLinkDevice[]) => {
      this.devices = devices;
    });
    this.scanPhase = this.repository.getScanPhase();
  }

  dispose(): void {
    this.deviceSub?.dispose();
    void this.stopScan.execute(this.scanSessionId);
  }

  buildFilter(): NearLinkScanFilter {
    const manufacturerId = parseInt(this.manufacturerId, 10);
    return new NearLinkScanFilter(
      this.address,
      this.deviceName,
      Number.isNaN(manufacturerId) ? -1 : manufacturerId,
      this.manufacturerData,
      this.manufacturerMask,
      this.allowNullFilter,
      this.scanMode,
      this.durationSec,
      this.minRssi
    );
  }

  async startScanAction(): Promise<void> {
    const filter = this.buildFilter();
    const validated = filter.validate();
    if (!validated.success) {
      this.scanPhase = NearLinkScanPhase.FAILED;
      this.statusMessage = validated.error?.message ?? 'Invalid scan filter';
      return;
    }
    const result: Result<string> = await this.startScan.execute(filter);
    if (!result.success || result.value === undefined) {
      this.scanPhase = NearLinkScanPhase.FAILED;
      this.statusMessage = result.error?.message ?? 'NearLink scan failed';
      return;
    }
    this.scanSessionId = result.value;
    this.scanPhase = NearLinkScanPhase.SCANNING;
    this.statusMessage = 'NearLink scanning';
  }

  async stopScanAction(): Promise<void> {
    await this.stopScan.execute(this.scanSessionId);
    this.scanSessionId = '';
    this.scanPhase = this.repository.getScanPhase();
  }

  selectDevice(device: NearLinkDevice): void {
    this.selectedDevice = device;
    this.selectedAdvertising = this.repository.getAdvertising(device.randomAddress);
  }

  async favoriteSelected(alias: string): Promise<void> {
    if (this.selectedDevice === undefined) {
      return;
    }
    await this.saveFavorite.execute(this.selectedDevice, alias, 'nearlink_scan');
  }
}
