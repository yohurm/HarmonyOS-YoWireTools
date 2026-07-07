import { ble } from '@kit.ConnectivityKit';
import {
  BleAdvertisingPacket,
  BleManufacturerDataEntry,
  BleServiceDataEntry,
  DeviceNameSource
} from '../../domain/model/BleAdvertisingPacket';
import { BleAdStructureParser } from '../../domain/service/BleAdStructureParser';

interface ScanResultExtended {
  deviceId: string;
  rssi?: number;
  connectable?: boolean;
  data?: ArrayBuffer;
  scanResponse?: ArrayBuffer;
  deviceName?: string;
  serviceUuids?: string[];
  manufacturerDataMap?: Map<number, Uint8Array>;
  serviceDataMap?: Map<string, Uint8Array>;
  txPowerLevel?: number;
  advertiseFlags?: number;
}

/**
 * Maps ConnectivityKit scan results to domain advertising packets.
 */
export class BleAdvertisingPlatformMapper {
  static parse(result: ble.ScanResult): BleAdvertisingPacket {
    const warnings: string[] = [];
    const extended = result as ScanResultExtended;
    const deviceId = extended.deviceId;
    const rssi = extended.rssi ?? 0;
    const connectable = extended.connectable ?? true;
    let rawHex = '';
    let localName = extended.deviceName ?? '';
    let nameSource = localName.length > 0 ? DeviceNameSource.SYSTEM : DeviceNameSource.UNKNOWN;
    let flags = extended.advertiseFlags ?? 0;
    const serviceUuids: string[] = [];

    if (extended.data !== undefined) {
      const adBytes = new Uint8Array(extended.data);
      rawHex = BleAdvertisingPlatformMapper.bytesToHex(adBytes);
      const parsed = BleAdStructureParser.parse(adBytes, false);
      if (parsed.localName.length > 0) {
        localName = parsed.localName;
        nameSource = parsed.nameSource;
      }
      if (parsed.flags !== 0) {
        flags = parsed.flags;
      }
      for (let i = 0; i < parsed.serviceUuids.length; i++) {
        serviceUuids.push(parsed.serviceUuids[i]);
      }
    } else {
      warnings.push('raw advertising bytes unavailable');
    }

    if (extended.scanResponse !== undefined) {
      const scanBytes = new Uint8Array(extended.scanResponse);
      const parsedScan = BleAdStructureParser.parse(scanBytes, true);
      if (parsedScan.localName.length > 0) {
        localName = parsedScan.localName;
        nameSource = DeviceNameSource.SCAN_RESPONSE;
      }
      for (let i = 0; i < parsedScan.serviceUuids.length; i++) {
        if (!serviceUuids.includes(parsedScan.serviceUuids[i])) {
          serviceUuids.push(parsedScan.serviceUuids[i]);
        }
      }
    }

    if (extended.serviceUuids !== undefined) {
      for (let i = 0; i < extended.serviceUuids.length; i++) {
        if (!serviceUuids.includes(extended.serviceUuids[i])) {
          serviceUuids.push(extended.serviceUuids[i]);
        }
      }
    }

    const serviceData: BleServiceDataEntry[] = [];
    if (extended.serviceDataMap !== undefined) {
      extended.serviceDataMap.forEach((value: Uint8Array, key: string) => {
        serviceData.push(new BleServiceDataEntry(key, BleAdvertisingPlatformMapper.bytesToHex(value)));
      });
    }
    const manufacturerData: BleManufacturerDataEntry[] = [];
    if (extended.manufacturerDataMap !== undefined) {
      extended.manufacturerDataMap.forEach((value: Uint8Array, key: number) => {
        manufacturerData.push(new BleManufacturerDataEntry(key, BleAdvertisingPlatformMapper.bytesToHex(value)));
      });
    }
    return new BleAdvertisingPacket(
      deviceId,
      rssi,
      connectable,
      rawHex,
      localName,
      nameSource,
      serviceUuids,
      serviceData,
      manufacturerData,
      extended.txPowerLevel ?? 0,
      flags,
      warnings
    );
  }

  static bytesToHex(bytes: Uint8Array): string {
    const parts: string[] = [];
    for (let i = 0; i < bytes.length; i++) {
      parts.push(bytes[i].toString(16).padStart(2, '0'));
    }
    return parts.join(' ');
  }
}
