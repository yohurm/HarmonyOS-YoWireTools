import { BluetoothDevice } from '../model/BluetoothDevice';

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

  filter(
    nameQuery: string,
    addressQuery: string,
    pairedOnly: boolean,
    favoritesOnly: boolean
  ): BluetoothDevice[] {
    const all = this.listSorted();
    const filtered: BluetoothDevice[] = [];
    for (let i = 0; i < all.length; i++) {
      const item = all[i];
      if (pairedOnly && !item.paired) {
        continue;
      }
      if (favoritesOnly && !item.favorite) {
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
      filtered.push(item);
    }
    return filtered;
  }

  clear(): void {
    this.devices.clear();
  }
}
