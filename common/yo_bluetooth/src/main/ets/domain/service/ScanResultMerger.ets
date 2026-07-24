import { BluetoothDevice } from '../model/BluetoothDevice';
import { ClassicDeviceMajorFilter, ClassicScanFilter } from '../model/ClassicScanFilter';

/**
 * Merges classic/BLE scan results per architecture bluetooth/00 + 01-§8.
 * Map key is primaryDeviceId (rail address).
 */
export class ScanResultMerger {
  private readonly devices: Map<string, BluetoothDevice> = new Map();

  merge(device: BluetoothDevice): BluetoothDevice {
    const key = device.primaryDeviceId;
    const existing = this.devices.get(key);
    if (existing === undefined) {
      this.devices.set(key, device);
      return device;
    }
    const withMeta = existing.mergeFrom(device);
    this.devices.set(key, withMeta);
    return withMeta;
  }

  replaceAll(devices: BluetoothDevice[]): void {
    this.devices.clear();
    for (let i = 0; i < devices.length; i++) {
      this.devices.set(devices[i].primaryDeviceId, devices[i]);
    }
  }

  /**
   * Upsert without clearing discovery-only entries that are not in devices.
   */
  upsertAll(devices: BluetoothDevice[]): void {
    for (let i = 0; i < devices.length; i++) {
      this.merge(devices[i]);
    }
  }

  listSorted(): BluetoothDevice[] {
    const items: BluetoothDevice[] = [];
    this.devices.forEach((device: BluetoothDevice) => {
      items.push(device);
    });
    items.sort((a: BluetoothDevice, b: BluetoothDevice) => {
      if (a.favorite !== b.favorite) {
        return a.favorite ? -1 : 1;
      }
      if (a.paired !== b.paired) {
        return a.paired ? -1 : 1;
      }
      if (a.rssi !== b.rssi) {
        return b.rssi - a.rssi;
      }
      if (a.effectiveName !== b.effectiveName) {
        return a.effectiveName.localeCompare(b.effectiveName);
      }
      return b.lastSeenMs - a.lastSeenMs;
    });
    return items;
  }

  filter(filter: ClassicScanFilter, activeClassicAddresses: Set<string> = new Set()): BluetoothDevice[] {
    const all = this.listSorted();
    const filtered: BluetoothDevice[] = [];
    const nameQuery = filter.nameQuery.trim();
    const addressQuery = filter.addressQuery.trim();
    for (let i = 0; i < all.length; i++) {
      const item = all[i];
      if (filter.pairedOnly && !item.paired) {
        continue;
      }
      if (filter.favoritesOnly && !item.favorite) {
        continue;
      }
      if (nameQuery.length > 0 && !item.effectiveName.includes(nameQuery)) {
        continue;
      }
      if (addressQuery.length > 0) {
        const hitClassic = item.classicDeviceId.includes(addressQuery);
        const hitBle = item.bleDeviceId.includes(addressQuery);
        const hitPrimary = item.primaryDeviceId.includes(addressQuery);
        if (!hitClassic && !hitBle && !hitPrimary) {
          continue;
        }
      }
      const rssiExempt = ScanResultMerger.isActiveSessionDevice(item, activeClassicAddresses);
      if (!ScanResultMerger.matchesRssi(item.rssi, filter.minRssi, rssiExempt)) {
        continue;
      }
      if (!ScanResultMerger.matchesMajor(item.majorClass, filter.majorFilter)) {
        continue;
      }
      filtered.push(item);
    }
    return filtered;
  }

  private static isActiveSessionDevice(device: BluetoothDevice, activeClassicAddresses: Set<string>): boolean {
    if (activeClassicAddresses.size === 0) {
      return false;
    }
    return activeClassicAddresses.has(device.primaryDeviceId) ||
      (device.classicDeviceId.length > 0 && activeClassicAddresses.has(device.classicDeviceId));
  }

  clear(): void {
    this.devices.clear();
  }

  private static matchesRssi(rssi: number, minRssi: number, exempt: boolean = false): boolean {
    if (exempt) {
      return true;
    }
    if (minRssi <= ClassicScanFilter.RSSI_SLIDER_MIN) {
      return true;
    }
    if (rssi === 0) {
      return false;
    }
    return rssi >= minRssi;
  }

  private static matchesMajor(majorClass: number, majorFilter: ClassicDeviceMajorFilter): boolean {
    if (majorFilter === ClassicDeviceMajorFilter.ALL) {
      return true;
    }
    if (majorFilter === ClassicDeviceMajorFilter.OTHER) {
      return !ScanResultMerger.isKnownMajor(majorClass);
    }
    return majorClass === (majorFilter as number);
  }

  private static isKnownMajor(majorClass: number): boolean {
    return majorClass === (ClassicDeviceMajorFilter.COMPUTER as number) ||
      majorClass === (ClassicDeviceMajorFilter.PHONE as number) ||
      majorClass === (ClassicDeviceMajorFilter.AUDIO_VIDEO as number) ||
      majorClass === (ClassicDeviceMajorFilter.PERIPHERAL as number) ||
      majorClass === (ClassicDeviceMajorFilter.IMAGING as number) ||
      majorClass === (ClassicDeviceMajorFilter.WEARABLE as number) ||
      majorClass === (ClassicDeviceMajorFilter.HEALTH as number);
  }
}
