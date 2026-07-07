/**
 * Manufacturer data mask matching per architecture bluetooth/03-§3.4.
 */
export class BleManufacturerMaskMatcher {
  static matches(dataHex: string, filterHex: string, maskHex: string): boolean {
    const data = BleManufacturerMaskMatcher.normalize(dataHex);
    const filter = BleManufacturerMaskMatcher.normalize(filterHex);
    const mask = BleManufacturerMaskMatcher.normalize(maskHex);
    if (filter.length === 0) {
      return false;
    }
    const byteCount = Math.min(data.length, filter.length, mask.length > 0 ? mask.length : filter.length);
    for (let i = 0; i < byteCount; i++) {
      const maskByte = mask.length > 0 ? mask[i] : 0xFF;
      if ((data[i] & maskByte) !== (filter[i] & maskByte)) {
        return false;
      }
    }
    return true;
  }

  private static normalize(hex: string): number[] {
    const compact = hex.replace(/\s/g, '').toLowerCase();
    const bytes: number[] = [];
    for (let i = 0; i < compact.length; i += 2) {
      const part = compact.substring(i, i + 2);
      if (part.length < 2) {
        break;
      }
      bytes.push(parseInt(part, 16));
    }
    return bytes;
  }
}
