import { scan } from '@kit.NearLinkKit';
import { NearLinkScanFilter, NearLinkScanMode, NearLinkSystemFilter } from '../../domain/model/NearLinkScanFilter';

/**
 * Maps system scan fields onto Kit ScanFilters. No service UUID parameter.
 */
export class NearLinkScanPlatformMapper {
  static toPlatformFilters(filter: NearLinkScanFilter, includeRssi: boolean): scan.ScanFilters[] {
    const mapped: scan.ScanFilters[] = [];
    for (let i = 0; i < filter.groups.length; i++) {
      const group = filter.groups[i];
      if (group.isEmpty()) {
        continue;
      }
      mapped.push(NearLinkScanPlatformMapper.mapGroup(group, includeRssi));
    }
    return mapped;
  }

  static toScanOptions(filter: NearLinkScanFilter): scan.ScanOptions {
    const options: scan.ScanOptions = {};
    if (filter.durationSec > 0) {
      options.duration = filter.durationSec;
    }
    if (filter.scanMode === NearLinkScanMode.BALANCED) {
      options.scanMode = scan.ScanMode.SCAN_MODE_BALANCED;
    } else {
      options.scanMode = scan.ScanMode.SCAN_MODE_LOW_POWER;
    }
    return options;
  }

  private static mapGroup(group: NearLinkSystemFilter, includeRssi: boolean): scan.ScanFilters {
    const platformFilter: scan.ScanFilters = {};
    if (group.address.length > 0) {
      platformFilter.address = group.address;
    }
    if (group.deviceName.length > 0) {
      platformFilter.deviceName = group.deviceName;
    }
    if (group.manufacturerId >= 0) {
      platformFilter.manufacturerId = group.manufacturerId;
    }
    if (group.manufacturerDataHex.length > 0) {
      platformFilter.manufacturerData = NearLinkScanPlatformMapper.hexToArrayBuffer(group.manufacturerDataHex);
    }
    if (group.manufacturerDataMaskHex.length > 0) {
      platformFilter.manufacturerDataMask = NearLinkScanPlatformMapper.hexToArrayBuffer(group.manufacturerDataMaskHex);
    }
    if (includeRssi && group.hasRssi) {
      platformFilter.rssi = group.rssi;
    }
    return platformFilter;
  }

  private static hexToArrayBuffer(hex: string): ArrayBuffer {
    const normalized = hex.replace(/\s/g, '').toLowerCase();
    const bytes = new Uint8Array(normalized.length / 2);
    for (let i = 0; i < bytes.length; i++) {
      bytes[i] = parseInt(normalized.substring(i * 2, i * 2 + 2), 16);
    }
    return bytes.buffer.slice(bytes.byteOffset, bytes.byteOffset + bytes.byteLength);
  }
}
