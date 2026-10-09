import { ble } from '@kit.ConnectivityKit';
import { BusinessError, deviceInfo } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { BluetoothConstants } from '../../../constants/BluetoothConstants';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';
import { BluetoothPlatformCodes } from '../../../constants/BluetoothPlatformCodes';
import { BleScanFilter } from '../../../domain/model/BleScanFilter';
import { BleScanPlatformMapper } from '../../mapper/BleScanPlatformMapper';
import { BleAdvertisingPlatformMapper } from '../../../data/mapper/BleAdvertisingPlatformMapper';
import { BleAdvertisingPacket } from '../../../domain/model/BleAdvertisingPacket';
import { ConnectivityKitEventBridge } from '../../kit/ConnectivityKitEventBridge';

export class BleDiscoveryPayload {
  readonly bleDeviceId: string;
  readonly deviceName: string;
  readonly rssi: number;
  readonly connectable: boolean;
  readonly advertising: BleAdvertisingPacket;

  constructor(
    bleDeviceId: string,
    deviceName: string,
    rssi: number,
    connectable: boolean,
    advertising: BleAdvertisingPacket
  ) {
    this.bleDeviceId = bleDeviceId;
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
  private extraScanner: ble.BleScanner | undefined;
  private useScannerApi: boolean = false;
  private extraScanning: boolean = false;
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

  rssiThresholdAvailable(): boolean {
    return deviceInfo.sdkApiVersion >= BluetoothConstants.BLE_RSSI_THRESHOLD_API;
  }

  parallelScanAvailable(): boolean {
    return deviceInfo.sdkApiVersion >= BluetoothConstants.BLE_SCANNER_API;
  }

  startScan(filter: BleScanFilter = new BleScanFilter()): Result<void> {
    try {
      if (deviceInfo.sdkApiVersion < BluetoothConstants.BLE_SCANNER_API && this.scanning) {
        return Result.fail(new ResultError(
          BluetoothErrorCodes.PARALLEL_SCAN_BLOCKED,
          'Stop the current scan before starting another'
        ));
      }
      this.offDeviceFind();
      this.activeFilter = filter;
      const filters = BleScannerDataSource.withRssiThreshold(
        BleScanPlatformMapper.toPlatformFilters(filter),
        filter
      );
      const options = BleScanPlatformMapper.toScanOptions(filter);
      if (deviceInfo.sdkApiVersion >= BluetoothConstants.BLE_SCANNER_API) {
        this.scanner = ble.createBleScanner();
        this.useScannerApi = true;
        BleScannerDataSource.submitScanner(this.scanner, filters, options);
      } else {
        this.useScannerApi = false;
        BleScannerDataSource.submitLegacy(filters, options);
      }
      this.scanning = true;
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(BleScannerDataSource.mapError(err));
    }
  }

  startExtraScan(filter: BleScanFilter): Result<void> {
    if (deviceInfo.sdkApiVersion < BluetoothConstants.BLE_SCANNER_API) {
      return Result.fail(new ResultError(
        BluetoothErrorCodes.PARALLEL_SCAN_BLOCKED,
        'A second scanner requires API 15'
      ));
    }
    try {
      const filters = BleScannerDataSource.withRssiThreshold(
        BleScanPlatformMapper.toPlatformFilters(filter),
        filter
      );
      const options = BleScanPlatformMapper.toScanOptions(filter);
      this.extraScanner = ble.createBleScanner();
      BleScannerDataSource.submitScanner(this.extraScanner, filters, options);
      this.extraScanning = true;
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(BleScannerDataSource.mapError(err));
    }
  }

  stopScan(): Result<void> {
    try {
      if (this.useScannerApi && this.scanner !== undefined) {
        this.scanner.stopScan();
      } else if (this.scanning) {
        ble.stopBLEScan();
      }
      this.scanning = false;
      this.scanner = undefined;
      this.offDeviceFind();
      return Result.ok(undefined);
    } catch (error) {
      this.scanning = false;
      const err = error as BusinessError;
      return Result.fail(BleScannerDataSource.mapError(err));
    }
  }

  stopExtraScan(): Result<void> {
    try {
      if (this.extraScanner !== undefined) {
        this.extraScanner.stopScan();
      }
      this.extraScanner = undefined;
      this.extraScanning = false;
      return Result.ok(undefined);
    } catch (error) {
      this.extraScanning = false;
      const err = error as BusinessError;
      return Result.fail(BleScannerDataSource.mapError(err));
    }
  }

  isExtraScanning(): boolean {
    return this.extraScanning;
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

  private static submitLegacy(filters: Array<ble.ScanFilter>, options: ble.ScanOptions): void {
    if (filters.length === 0) {
      ble.startBLEScan(null, options);
      return;
    }
    ble.startBLEScan(filters, options);
  }

  private static submitScanner(
    scanner: ble.BleScanner,
    filters: Array<ble.ScanFilter>,
    options: ble.ScanOptions
  ): void {
    if (filters.length === 0) {
      scanner.startScan(null, options);
      return;
    }
    scanner.startScan(filters, options);
  }

  private static withRssiThreshold(filters: Array<ble.ScanFilter>, filter: BleScanFilter): Array<ble.ScanFilter> {
    if (deviceInfo.sdkApiVersion < BluetoothConstants.BLE_RSSI_THRESHOLD_API) {
      return filters;
    }
    if (filter.rssiThreshold < BluetoothConstants.RSSI_PROTOCOL_MIN ||
      filter.rssiThreshold > BluetoothConstants.RSSI_PROTOCOL_MAX) {
      return filters;
    }
    const next = filters.slice();
    if (next.length === 0) {
      next.push({});
    }
    next[0].rssiThreshold = filter.rssiThreshold;
    return next;
  }

  private static mapError(err: BusinessError): ResultError {
    const mapped = BluetoothPlatformCodes.domainCode(err.code);
    const code = mapped.length > 0 ? mapped : BluetoothErrorCodes.BLE_SCAN_FAILED;
    return ResultError.fromBusinessError(code, err);
  }
}
