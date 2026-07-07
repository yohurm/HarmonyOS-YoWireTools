import { scan } from '@kit.NearLinkKit';
import { NearLinkScanFilter, NearLinkScanMode } from '../../domain/model/NearLinkScanFilter';

/**
 * Maps domain NearLink scan filter to NearLinkKit scan parameters.
 */
export class NearLinkScanPlatformMapper {
  static toPlatformFilters(filter: NearLinkScanFilter): scan.ScanFilters[] {
    if (filter.allowNullFilter && !filter.hasEffectiveFilter()) {
      return [];
    }
    const platformFilter: scan.ScanFilters = {};
    if (filter.address.length > 0) {
      platformFilter.address = filter.address;
    }
    if (filter.deviceName.length > 0) {
      platformFilter.deviceName = filter.deviceName;
    }
    if (filter.manufacturerId >= 0) {
      platformFilter.manufacturerId = filter.manufacturerId;
    }
    if (filter.manufacturerDataHex.length > 0) {
      platformFilter.manufacturerData = NearLinkScanPlatformMapper.hexToArrayBuffer(filter.manufacturerDataHex);
    }
    if (filter.manufacturerDataMaskHex.length > 0) {
      platformFilter.manufacturerDataMask =
        NearLinkScanPlatformMapper.hexToArrayBuffer(filter.manufacturerDataMaskHex);
    }
    return [platformFilter];
  }

  static toScanOptions(filter: NearLinkScanFilter): scan.ScanOptions {
    const options: scan.ScanOptions = {};
    if (filter.durationSec > 0) {
      options.duration = filter.durationSec;
    }
    if (filter.scanMode === NearLinkScanMode.LOW_POWER) {
      options.scanMode = scan.ScanMode.SCAN_MODE_LOW_POWER;
    } else {
      options.scanMode = scan.ScanMode.SCAN_MODE_BALANCED;
    }
    return options;
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
