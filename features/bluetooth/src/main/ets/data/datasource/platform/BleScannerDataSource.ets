import { ble } from '@kit.ConnectivityKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BleScanFilter } from '../../../domain/model/BleScanFilter';
import { BleScanPlatformMapper } from '../../mapper/BleScanPlatformMapper';
import { BleAdvertisingPlatformMapper } from '../../../data/mapper/BleAdvertisingPlatformMapper';
import { BleAdvertisingPacket } from '../../../domain/model/BleAdvertisingPacket';
import { ConnectivityKitEventBridge } from '../../kit/ConnectivityKitEventBridge';

export class BleDiscoveryPayload {
  readonly deviceId: string;
  readonly deviceName: string;
  readonly rssi: number;
  readonly connectable: boolean;
  readonly advertising: BleAdvertisingPacket;

  constructor(
    deviceId: string,
    deviceName: string,
    rssi: number,
    connectable: boolean,
    advertising: BleAdvertisingPacket
  ) {
    this.deviceId = deviceId;
    this.deviceName = deviceName;
    this.rssi = rssi;
    this.connectable = connectable;
    this.advertising = advertising;
  }
}

type BleFindListener = (payload: BleDiscoveryPayload) => void;

/**
 * BLE scan platform wrapper per WSL bpta-bluetooth-low-energy and architecture bluetooth/03-§3.2.
 */
export class BleScannerDataSource {
  private static instance: BleScannerDataSource | undefined;
  private findListener: BleFindListener | undefined;
  private legacyFindHandler: ((results: Array<ble.ScanResult>) => void) | undefined;
  private scannerFindHandler: ((report: ble.ScanReport) => void) | undefined;
  private scanning: boolean = false;
  private scanner: ble.BleScanner | undefined;
  private useScannerApi: boolean = false;
  private activeFilter: BleScanFilter | undefined;

  private constructor() {
  }

  static getInstance(): BleScannerDataSource {
    if (BleScannerDataSource.instance === undefined) {
      BleScannerDataSource.instance = new BleScannerDataSource();
    }
    return BleScannerDataSource.instance;
  }

  isScanning(): boolean {
    return this.scanning;
  }

  usesScannerApi(): boolean {
    return this.useScannerApi;
  }

  startScan(filter: BleScanFilter = new BleScanFilter()): Result<void> {
    try {
      this.offDeviceFind();
      this.activeFilter = filter;
      const filters = BleScanPlatformMapper.toPlatformFilters(filter);
      const options = BleScanPlatformMapper.toScanOptions(filter);
      this.useScannerApi = BleScannerDataSource.tryCreateScanner();
      if (this.useScannerApi && this.scanner !== undefined) {
        this.scanner.startScan(filters, options);
      } else {
        ble.startBLEScan(filters, options);
      }
      this.scanning = true;
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.BLE_SCAN_FAILED, err));
    }
  }

  stopScan(): Result<void> {
    try {
      if (this.useScannerApi && this.scanner !== undefined) {
        this.scanner.stopScan();
      } else {
        ble.stopBLEScan();
      }
      this.scanning = false;
      this.offDeviceFind();
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(BluetoothErrorCodes.BLE_SCAN_FAILED, err));
    }
  }

  onDeviceFind(listener: BleFindListener): Result<void> {
    this.offDeviceFind();
    this.findListener = listener;
    this.legacyFindHandler = (results: Array<ble.ScanResult>) => {
      this.dispatchScanResults(results);
    };
    this.scannerFindHandler = (report: ble.ScanReport) => {
      this.dispatchScanResults(report.scanResult ?? []);
    };
    if (this.useScannerApi && this.scanner !== undefined) {
      return ConnectivityKitEventBridge.subscribeScannerBleDeviceFind(this.scanner, this.scannerFindHandler);
    }
    return ConnectivityKitEventBridge.subscribeLegacyBleDeviceFind(this.legacyFindHandler);
  }

  offDeviceFind(): void {
    if (this.legacyFindHandler !== undefined) {
      ConnectivityKitEventBridge.unsubscribeLegacyBleDeviceFind(this.legacyFindHandler);
      this.legacyFindHandler = undefined;
    }
    if (this.scannerFindHandler !== undefined && this.scanner !== undefined) {
      ConnectivityKitEventBridge.unsubscribeScannerBleDeviceFind(this.scanner, this.scannerFindHandler);
      this.scannerFindHandler = undefined;
    }
    this.findListener = undefined;
  }

  private dispatchScanResults(results: Array<ble.ScanResult>): void {
    if (this.findListener === undefined) {
      return;
    }
    for (let i = 0; i < results.length; i++) {
      const item = results[i];
      const advertising = BleAdvertisingPlatformMapper.parse(item);
      const deviceName = item.deviceName ??
        (advertising.localName.length > 0 ? advertising.localName : item.deviceId);
      const payload = new BleDiscoveryPayload(
        item.deviceId,
        deviceName,
        item.rssi ?? 0,
        item.connectable ?? true,
        advertising
      );
      if (this.activeFilter !== undefined &&
        !this.activeFilter.matchesPostFilter(payload.deviceName, payload.rssi, false)) {
        continue;
      }
      this.findListener(payload);
    }
  }

  private static tryCreateScanner(): boolean {
    try {
      const instance = BleScannerDataSource.getInstance();
      instance.scanner = ble.createBleScanner();
      return instance.scanner !== undefined;
    } catch (_error) {
      return false;
    }
  }
}
