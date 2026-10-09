import { NearLinkDevice } from '../model/NearLinkDevice';

/**
 * Merges NearLink scan results per architecture nearlink/01-§8.
 */
export class ScanResultMerger {
  private readonly devices: Map<string, NearLinkDevice> = new Map();

  merge(device: NearLinkDevice): NearLinkDevice {
    const existing = this.devices.get(device.randomAddress);
    if (existing === undefined) {
      this.devices.set(device.randomAddress, device);
      return device;
    }
    const merged = existing.withSeen(device.rssi, device.rssiValid, device.lastSeenMs);
    const withMeta = new NearLinkDevice(
      merged.randomAddress,
      device.displayName.length > 0 ? device.displayName : merged.displayName,
      merged.rssi,
      merged.rssiValid,
      device.connectable,
      merged.favorite || device.favorite,
      merged.lastSeenMs,
      merged.firstSeenMs,
      device.serviceUuids.length > 0 ? device.serviceUuids : merged.serviceUuids,
      merged.alias.length > 0 ? merged.alias : device.alias,
      device.rawHex.length > 0 ? device.rawHex : merged.rawHex,
      merged.seenCount,
      device.deviceClass.length > 0 ? device.deviceClass : merged.deviceClass,
      device.belowLocalRssiGate
    );
    this.devices.set(device.randomAddress, withMeta);
    return withMeta;
  }

  listSorted(): NearLinkDevice[] {
    const items: NearLinkDevice[] = [];
    this.devices.forEach((device: NearLinkDevice) => {
      items.push(device);
    });
    items.sort((a: NearLinkDevice, b: NearLinkDevice) => {
      if (a.favorite !== b.favorite) {
        return a.favorite ? -1 : 1;
      }
      if (a.rssiValid !== b.rssiValid) {
        return a.rssiValid ? -1 : 1;
      }
      const left = a.rssiValid ? a.rssi : -1000;
      const right = b.rssiValid ? b.rssi : -1000;
      if (left !== right) {
        return right - left;
      }
      return b.lastSeenMs - a.lastSeenMs;
    });
    return items;
  }

  clear(): void {
    this.devices.clear();
  }
}
