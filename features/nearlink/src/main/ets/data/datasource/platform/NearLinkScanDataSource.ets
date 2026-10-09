import { deviceInfo } from '@kit.BasicServicesKit';
import { scan } from '@kit.NearLinkKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { KitEventSubscription } from 'common_platform';
import { NearLinkScanFilter } from '../../../domain/model/NearLinkScanFilter';
import { NearLinkScanPlatformMapper } from '../../mapper/NearLinkScanPlatformMapper';
import { NearLinkAdvertisingPacket } from '../../../domain/model/NearLinkAdvertisingPacket';
import { NearLinkAdvParser } from '../../../domain/service/NearLinkAdvParser';
import { NearLinkConstants } from '../../../constants/NearLinkConstants';
import { NearLinkErrorCodes } from '../../../constants/NearLinkErrorCodes';

export class NearLinkDiscoveryPayload {
  readonly randomAddress: string;
  readonly deviceName: string;
  readonly rssi: number;
  readonly rssiValid: boolean;
  readonly connectable: boolean;
  readonly advertising: NearLinkAdvertisingPacket;
  readonly deviceClass: string;

  constructor(
    randomAddress: string,
    deviceName: string,
    rssi: number,
    rssiValid: boolean,
    connectable: boolean,
    advertising: NearLinkAdvertisingPacket,
    deviceClass: string = ''
  ) {
    this.randomAddress = randomAddress;
    this.deviceName = deviceName;
    this.rssi = rssi;
    this.rssiValid = rssiValid;
    this.connectable = connectable;
    this.advertising = advertising;
    this.deviceClass = deviceClass;
  }
}

export class NearLinkScanStartInfo {
  readonly rssiFilter: string;

  constructor(rssiFilter: string) {
    this.rssiFilter = rssiFilter;
  }
}

type DeviceFoundListener = (payload: NearLinkDiscoveryPayload) => void;

export class NearLinkScanDataSource {
  private static instance: NearLinkScanDataSource | undefined;
  private findListener: DeviceFoundListener | undefined;
  private findHandler: ((results: scan.ScanResults[]) => void) | undefined;
  private scanning: boolean = false;
  private rssiFilterMode: string = 'none';
  private seenApi: number = 0;

  private constructor() {
  }

  static getInstance(): NearLinkScanDataSource {
    if (NearLinkScanDataSource.instance === undefined) {
      NearLinkScanDataSource.instance = new NearLinkScanDataSource();
    }
    return NearLinkScanDataSource.instance;
  }

  isScanning(): boolean {
    return this.scanning;
  }

  getRssiFilterMode(): string {
    return this.rssiFilterMode;
  }

  async startScan(filter: NearLinkScanFilter): Promise<Result<NearLinkScanStartInfo>> {
    const api = deviceInfo.sdkApiVersion;
    this.seenApi = api;
    const validated = filter.validate();
    if (!validated.success) {
      return Result.fail(validated.error ?? new ResultError(NearLinkErrorCodes.EMPTY_FILTER, 'api=startScan'));
    }
    if (filter.scanAll) {
      if (api < NearLinkConstants.API_NULL_FILTER) {
        return Result.fail(new ResultError(
          NearLinkErrorCodes.VERSION_UNAVAILABLE,
          `api=startScan;since=${NearLinkConstants.SINCE_NULL_FILTER}`,
          undefined,
          { 'since': NearLinkConstants.SINCE_NULL_FILTER },
          ''
        ));
      }
    }
    const includeRssi = api >= NearLinkConstants.API_RSSI_FILTER;
    this.rssiFilterMode = includeRssi && this.requestHasRssi(filter) ? 'system' :
      (filter.hasLocalRssiGate ? 'local' : 'none');
    try {
      this.offDeviceFound();
      const options = NearLinkScanPlatformMapper.toScanOptions(filter);
      if (filter.scanAll) {
        await scan.startScan(null, options);
      } else {
        const filters = NearLinkScanPlatformMapper.toPlatformFilters(filter, includeRssi);
        await scan.startScan(filters, options);
      }
      this.scanning = true;
      return Result.ok(new NearLinkScanStartInfo(this.rssiFilterMode));
    } catch (error) {
      const err = error as BusinessError;
      this.scanning = false;
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
      this.scanning = false;
      this.offDeviceFound();
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.SCAN_FAILED, err));
    }
  }

  onDeviceFound(listener: DeviceFoundListener): Result<void> {
    this.offDeviceFound();
    this.findListener = listener;
    const handler = (results: scan.ScanResults[]) => {
      this.dispatchResults(results);
    };
    this.findHandler = handler;
    return KitEventSubscription.subscribe(() => {
      scan.on('deviceFound', handler);
    }, 'scan.deviceFound');
  }

  offDeviceFound(): void {
    if (this.findHandler !== undefined) {
      const handler = this.findHandler;
      KitEventSubscription.unsubscribe(() => {
        scan.off('deviceFound', handler);
      }, 'scan.deviceFound');
      this.findHandler = undefined;
    }
    this.findListener = undefined;
  }

  private requestHasRssi(filter: NearLinkScanFilter): boolean {
    for (let i = 0; i < filter.groups.length; i++) {
      if (filter.groups[i].hasRssi) {
        return true;
      }
    }
    return false;
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
      const deviceName = item.deviceName.length > 0 ? item.deviceName : item.address;
      let deviceClass = '';
      if (this.seenApi >= NearLinkConstants.API_DEVICE_CLASS && item.deviceClass !== undefined) {
        deviceClass = `${item.deviceClass}`;
      }
      this.findListener(new NearLinkDiscoveryPayload(
        item.address,
        deviceName,
        rssi,
        rssiValid,
        item.isConnectable,
        advertising,
        deviceClass
      ));
    }
  }
}
