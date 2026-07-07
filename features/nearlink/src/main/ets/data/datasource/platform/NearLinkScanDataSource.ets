import { deviceInfo } from '@kit.BasicServicesKit';
import { scan } from '@kit.NearLinkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { NearLinkScanFilter } from '../../../domain/model/NearLinkScanFilter';
import { NearLinkScanPlatformMapper } from '../../mapper/NearLinkScanPlatformMapper';
import { NearLinkAdvertisingPacket } from '../../../domain/model/NearLinkAdvertisingPacket';
import { NearLinkAdvParser } from '../../../domain/service/NearLinkAdvParser';
import { NearLinkErrorCodes } from '../../../constants/NearLinkErrorCodes';
import { NearLinkKitEventBridge } from '../../kit/NearLinkKitEventBridge';

export class NearLinkDiscoveryPayload {
  readonly randomAddress: string;
  readonly deviceName: string;
  readonly rssi: number;
  readonly rssiValid: boolean;
  readonly connectable: boolean;
  readonly advertising: NearLinkAdvertisingPacket;

  constructor(
    randomAddress: string,
    deviceName: string,
    rssi: number,
    rssiValid: boolean,
    connectable: boolean,
    advertising: NearLinkAdvertisingPacket
  ) {
    this.randomAddress = randomAddress;
    this.deviceName = deviceName;
    this.rssi = rssi;
    this.rssiValid = rssiValid;
    this.connectable = connectable;
    this.advertising = advertising;
  }
}

type DeviceFoundListener = (payload: NearLinkDiscoveryPayload) => void;

export class NearLinkScanDataSource {
  private static instance: NearLinkScanDataSource | undefined;
  private static readonly NULL_FILTER_MIN_API: number = 26;
  private findListener: DeviceFoundListener | undefined;
  private findHandler: ((results: scan.ScanResults[]) => void) | undefined;
  private scanning: boolean = false;
  private activeFilter: NearLinkScanFilter | undefined;

  private constructor() {
  }

  static getInstance(): NearLinkScanDataSource {
    if (NearLinkScanDataSource.instance === undefined) {
      NearLinkScanDataSource.instance = new NearLinkScanDataSource();
    }
    return NearLinkScanDataSource.instance;
  }

  static supportsNullFilterScan(): boolean {
    try {
      return deviceInfo.sdkApiVersion >= NearLinkScanDataSource.NULL_FILTER_MIN_API;
    } catch (_error) {
      return false;
    }
  }

  isScanning(): boolean {
    return this.scanning;
  }

  async startScan(filter: NearLinkScanFilter): Promise<Result<void>> {
    const validated = filter.validate();
    if (!validated.success) {
      return validated;
    }
    try {
      this.offDeviceFound();
      this.activeFilter = filter;
      const filters = NearLinkScanPlatformMapper.toPlatformFilters(filter);
      const options = NearLinkScanPlatformMapper.toScanOptions(filter);
      if (filters.length === 0 && filter.allowNullFilter) {
        if (!NearLinkScanDataSource.supportsNullFilterScan()) {
          return Result.fail(new ResultError(
            NearLinkErrorCodes.EMPTY_FILTER,
            `Null filter requires API ${NearLinkScanDataSource.NULL_FILTER_MIN_API}+`
          ));
        }
      }
      await scan.startScan(filters, options);
      this.scanning = true;
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.SCAN_FAILED, err));
    }
  }

  async stopScan(): Promise<Result<void>> {
    try {
      await scan.stopScan();
      this.scanning = false;
      this.offDeviceFound();
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.SCAN_FAILED, err));
    }
  }

  onDeviceFound(listener: DeviceFoundListener): Result<void> {
    this.offDeviceFound();
    this.findListener = listener;
    this.findHandler = (results: scan.ScanResults[]) => {
      this.dispatchResults(results);
    };
    return NearLinkKitEventBridge.subscribeDeviceFound(this.findHandler);
  }

  offDeviceFound(): void {
    if (this.findHandler !== undefined) {
      NearLinkKitEventBridge.unsubscribeDeviceFound(this.findHandler);
      this.findHandler = undefined;
    }
    this.findListener = undefined;
  }

  private dispatchResults(results: scan.ScanResults[]): void {
    if (this.findListener === undefined) {
      return;
    }
    for (let i = 0; i < results.length; i++) {
      const item = results[i];
      const rssi = item.rssi;
      const rssiValid = NearLinkAdvParser.isRssiValid(rssi);
      const advertising = NearLinkAdvParser.parseRawData(item.data, item.deviceName ?? '');
      const deviceName = item.deviceName.length > 0 ? item.deviceName :
        (advertising.localName.length > 0 ? advertising.localName : item.address);
      const payload = new NearLinkDiscoveryPayload(
        item.address,
        deviceName,
        rssi,
        rssiValid,
        item.isConnectable,
        advertising
      );
      if (this.activeFilter !== undefined &&
        !this.activeFilter.matchesPostFilter(payload.deviceName, payload.rssi, payload.rssiValid)) {
        continue;
      }
      this.findListener(payload);
    }
  }
}
