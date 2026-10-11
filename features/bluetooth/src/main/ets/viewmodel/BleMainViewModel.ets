import { Subscription } from 'common_core';
import {
  BluetoothDevice,
  BluetoothErrorCodes,
  BluetoothRepository,
  BluetoothUseCaseFactory,
  BleScanDutyPreset,
  BleScanFilter,
  ObserveBleDevicesUseCase,
  StartBleScanUseCase,
  StopBleScanUseCase
} from 'yobluetooth';

export class BleDeviceRow {
  readonly deviceId: string;
  readonly name: string;
  readonly address: string;
  readonly rssiText: string;
  readonly connectable: boolean;
  readonly rawSummary: string;

  constructor(
    deviceId: string,
    name: string,
    address: string,
    rssiText: string,
    connectable: boolean,
    rawSummary: string
  ) {
    this.deviceId = deviceId;
    this.name = name;
    this.address = address;
    this.rssiText = rssiText;
    this.connectable = connectable;
    this.rawSummary = rawSummary;
  }
}

@ObservedV2
export class BleMainViewModel {
  @Trace isLoading: boolean = true;
  @Trace ready: boolean = false;
  @Trace scanning: boolean = false;
  @Trace rows: BleDeviceRow[] = [];
  @Trace errorCode: string = '';
  @Trace duty: BleScanDutyPreset = BleScanDutyPreset.BALANCED;
  @Trace exactName: string = '';
  @Trace serviceUuid: string = '';
  @Trace serviceUuidMask: string = '';
  @Trace namePrefix: string = '';
  @Trace manufacturerIdText: string = '';
  @Trace rssiThresholdText: string = '';
  @Trace parallelAvailable: boolean = false;
  @Trace rssiThresholdAvailable: boolean = false;
  @Trace extraScanning: boolean = false;
  @Trace connectBlockedMessage: string = '';

  private readonly startScanUseCase: StartBleScanUseCase = BluetoothUseCaseFactory.startBleScan();
  private readonly stopScanUseCase: StopBleScanUseCase = BluetoothUseCaseFactory.stopBleScan();
  private readonly observeDevices: ObserveBleDevicesUseCase = BluetoothUseCaseFactory.observeBleDevices();
  private readonly repository: BluetoothRepository = BluetoothRepository.getInstance();
  private subscription: Subscription | undefined;
  private sessionId: string = '';

  async onPageAppear(): Promise<void> {
    this.disposeSubscription();
    this.parallelAvailable = this.repository.bleParallelScanAvailable();
    this.rssiThresholdAvailable = this.repository.bleRssiThresholdAvailable();
    this.subscription = this.observeDevices.execute((devices: BluetoothDevice[]) => {
      this.applyDevices(devices);
    });
    this.isLoading = false;
    this.ready = true;
  }

  async onPageDisappear(): Promise<void> {
    this.disposeSubscription();
    await this.stopScan();
    if (this.extraScanning) {
      this.repository.stopExtraBleScan();
      this.extraScanning = false;
    }
  }

  setExactName(value: string): void {
    this.exactName = value;
  }

  setServiceUuid(value: string): void {
    this.serviceUuid = value;
  }

  setServiceUuidMask(value: string): void {
    this.serviceUuidMask = value;
  }

  setNamePrefix(value: string): void {
    this.namePrefix = value;
  }

  setManufacturerIdText(value: string): void {
    this.manufacturerIdText = value;
  }

  setRssiThresholdText(value: string): void {
    this.rssiThresholdText = value;
  }

  selectDuty(duty: BleScanDutyPreset): void {
    this.duty = duty;
  }

  async startScan(): Promise<void> {
    this.errorCode = '';
    this.connectBlockedMessage = '';
    const filter = this.buildFilter();
    const started = await this.startScanUseCase.execute(this.serviceUuid, filter);
    if (!started.success || started.value === undefined) {
      this.scanning = false;
      this.sessionId = '';
      this.errorCode = started.error?.code ?? BluetoothErrorCodes.BLE_SCAN_FAILED;
      return;
    }
    this.sessionId = started.value;
    this.scanning = true;
  }

  async stopScan(): Promise<void> {
    if (this.sessionId.length === 0 && !this.scanning) {
      return;
    }
    await this.stopScanUseCase.execute(this.sessionId);
    this.sessionId = '';
    this.scanning = false;
  }

  async startExtraScan(): Promise<void> {
    if (!this.parallelAvailable) {
      this.errorCode = BluetoothErrorCodes.PARALLEL_SCAN_BLOCKED;
      return;
    }
    const started = this.repository.startExtraBleScan(this.buildFilter());
    if (!started.success) {
      this.errorCode = started.error?.code ?? BluetoothErrorCodes.PARALLEL_SCAN_BLOCKED;
      this.extraScanning = false;
      return;
    }
    this.extraScanning = true;
  }

  stopExtraScan(): void {
    this.repository.stopExtraBleScan();
    this.extraScanning = false;
  }

  connectBlocked(row: BleDeviceRow): boolean {
    if (row.connectable) {
      this.connectBlockedMessage = '';
      return false;
    }
    this.connectBlockedMessage = 'not_connectable';
    return true;
  }

  private buildFilter(): BleScanFilter {
    const manufacturerId = this.manufacturerIdText.length === 0 ? -1 : Number(this.manufacturerIdText);
    const rssiThreshold = this.rssiThresholdText.length === 0 ? -129 : Number(this.rssiThresholdText);
    return new BleScanFilter(
      this.namePrefix,
      '',
      this.serviceUuid,
      Number.isNaN(manufacturerId) ? -1 : manufacturerId,
      '',
      '',
      -127,
      false,
      this.duty,
      this.exactName,
      this.serviceUuidMask,
      Number.isNaN(rssiThreshold) ? -129 : rssiThreshold
    );
  }

  private applyDevices(devices: BluetoothDevice[]): void {
    const rows: BleDeviceRow[] = [];
    for (let i = 0; i < devices.length; i++) {
      const device = devices[i];
      const packet = this.repository.getBleAdvertising(device.bleDeviceId);
      const raw = packet === undefined ? '' : packet.rawHex;
      rows.push(new BleDeviceRow(
        device.bleDeviceId,
        device.displayName,
        device.bleDeviceId,
        device.rssiKnown ? `${device.rssi} dBm` : '',
        device.connectable,
        raw
      ));
    }
    this.rows = rows;
  }

  private disposeSubscription(): void {
    if (this.subscription !== undefined) {
      this.subscription.dispose();
      this.subscription = undefined;
    }
  }
}
