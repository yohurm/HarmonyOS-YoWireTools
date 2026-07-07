import { BluetoothDevice } from '../model/BluetoothDevice';

/**
 * Merges classic/BLE scan results per architecture bluetooth/01-§8.
 */
export class ScanResultMerger {
  private readonly devices: Map<string, BluetoothDevice> = new Map();

  merge(device: BluetoothDevice): BluetoothDevice {
    const existing = this.devices.get(device.deviceId);
    if (existing === undefined) {
      this.devices.set(device.deviceId, device);
      return device;
    }
    const merged = existing.withSeen(device.rssi, device.lastSeenMs);
    const withMeta = new BluetoothDevice(
      merged.deviceId,
      device.displayName.length > 0 ? device.displayName : merged.displayName,
      merged.rssi,
      merged.paired || device.paired,
      merged.kind,
      device.deviceType !== 0 ? device.deviceType : merged.deviceType,
      device.connectable,
      merged.lastSeenMs,
      device.serviceUuids.length > 0 ? device.serviceUuids : merged.serviceUuids,
      merged.identityId,
      merged.alias.length > 0 ? merged.alias : device.alias,
      merged.addressKind,
      merged.identityType,
      device.pairState !== merged.pairState ? device.pairState : merged.pairState,
      merged.favorite || device.favorite,
      merged.firstSeenMs,
      device.profileUuids.length > 0 ? device.profileUuids : merged.profileUuids,
      device.discoverySource,
      merged.identityStability,
      device.rawHex.length > 0 ? device.rawHex : merged.rawHex
    );
    this.devices.set(device.deviceId, withMeta);
    return withMeta;
  }

  replaceAll(devices: BluetoothDevice[]): void {
    this.devices.clear();
    for (let i = 0; i < devices.length; i++) {
      this.devices.set(devices[i].deviceId, devices[i]);
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
      if (addressQuery.length > 0 && !item.deviceId.includes(addressQuery)) {
        continue;
      }
      filtered.push(item);
    }
    return filtered;
  }

  clear(): void {
    this.devices.clear();
  }
}
