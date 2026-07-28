import { ble } from '@kit.ConnectivityKit';
import { BleScanDutyPreset, BleScanFilter } from '../../domain/model/BleScanFilter';

/**
 * Maps domain BLE scan filter to ConnectivityKit scan parameters.
 */
export class BleScanPlatformMapper {
  static toPlatformFilters(filter: BleScanFilter): Array<ble.ScanFilter> {
    const filters: Array<ble.ScanFilter> = [];
    const platformFilter: ble.ScanFilter = {};
    if (filter.bleDeviceId.length > 0) {
      platformFilter.deviceId = filter.bleDeviceId;
    }
    if (filter.serviceUuid.length > 0) {
      platformFilter.serviceUuid = filter.serviceUuid;
    }
    if (filter.namePrefix.length > 0) {
      platformFilter.name = filter.namePrefix;
    }
    if (filter.manufacturerId >= 0) {
      platformFilter.manufactureId = filter.manufacturerId;
    }
    if (filter.manufacturerData.length > 0) {
      platformFilter.manufactureData = BleScanPlatformMapper.hexToArrayBuffer(filter.manufacturerData);
    }
    if (filter.manufacturerMask.length > 0) {
      platformFilter.manufactureDataMask = BleScanPlatformMapper.hexToArrayBuffer(filter.manufacturerMask);
    }
    if (Object.keys(platformFilter).length > 0) {
      filters.push(platformFilter);
    }
    return filters;
  }

  static toScanOptions(filter: BleScanFilter): ble.ScanOptions {
    if (filter.dutyPreset === BleScanDutyPreset.LOW_POWER) {
      return {
        interval: 0,
        dutyMode: ble.ScanDuty.SCAN_MODE_LOW_POWER,
        matchMode: ble.MatchMode.MATCH_MODE_STICKY
      };
    }
    if (filter.dutyPreset === BleScanDutyPreset.LOW_LATENCY) {
      return {
        interval: 0,
        dutyMode: ble.ScanDuty.SCAN_MODE_LOW_LATENCY,
        matchMode: ble.MatchMode.MATCH_MODE_AGGRESSIVE
      };
    }
    return {
      interval: 0,
      dutyMode: ble.ScanDuty.SCAN_MODE_BALANCED,
      matchMode: ble.MatchMode.MATCH_MODE_AGGRESSIVE
    };
  }

  private static hexToArrayBuffer(hex: string): ArrayBuffer {
    const normalized = hex.replace(/\s/g, '');
    const length = Math.floor(normalized.length / 2);
    const buffer = new ArrayBuffer(length);
    const view = new Uint8Array(buffer);
    for (let i = 0; i < length; i++) {
      view[i] = parseInt(normalized.substring(i * 2, i * 2 + 2), 16);
    }
    return buffer;
  }
}
