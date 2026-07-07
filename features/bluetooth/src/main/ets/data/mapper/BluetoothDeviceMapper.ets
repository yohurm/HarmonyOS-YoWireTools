import { connection } from '@kit.ConnectivityKit';
import { TimeUtil } from 'common_core';
import { PlatformDiscoveryPayload } from '../datasource/platform/ClassicBluetoothDataSource';
import {
  AddressKind,
  IdentityStability
} from '../../domain/model/DeviceIdentity';
import {
  IdentityType,
  BluetoothDevice,
  BluetoothDeviceKind
} from '../../domain/model/BluetoothDevice';
import { DiscoverySource } from '../../domain/model/DiscoverySource';
import { PairingState } from '../../domain/model/PairingState';
import { BleAdvertisingPacket, DeviceNameSource } from '../../domain/model/BleAdvertisingPacket';
import { BluetoothIdentityDataSource } from '../datasource/platform/BluetoothIdentityDataSource';

export class PlatformPairedDevice {
  readonly deviceId: string;
  readonly deviceName: string;
  readonly deviceClass: number;

  constructor(deviceId: string, deviceName: string, deviceClass: number) {
    this.deviceId = deviceId;
    this.deviceName = deviceName;
    this.deviceClass = deviceClass;
  }
}

export class BluetoothDeviceMapper {
  private static readonly identitySource: BluetoothIdentityDataSource =
    BluetoothIdentityDataSource.getInstance();

  static fromPaired(platform: PlatformPairedDevice): BluetoothDevice {
    const identity = BluetoothDeviceMapper.identitySource.buildIdentity(platform.deviceId, true);
    return new BluetoothDevice(
      platform.deviceId,
      platform.deviceName.length > 0 ? platform.deviceName : platform.deviceId,
      0,
      true,
      BluetoothDeviceKind.CLASSIC,
      platform.deviceClass,
      true,
      TimeUtil.nowMs(),
      [],
      identity.identityId,
      '',
      AddressKind.VIRTUAL,
      IdentityType.CLASSIC,
      PairingState.PAIRED,
      false,
      TimeUtil.nowMs(),
      [],
      DiscoverySource.PAIRED,
      IdentityStability.PAIRED_STABLE
    );
  }

  static fromDiscovery(payload: PlatformDiscoveryPayload, paired: boolean = false): BluetoothDevice {
    const identity = BluetoothDeviceMapper.identitySource.buildIdentity(payload.deviceId, paired);
    const source = payload.fromLegacyFind ? DiscoverySource.DEVICE_FIND : DiscoverySource.DISCOVERY_RESULT;
    return new BluetoothDevice(
      payload.deviceId,
      payload.deviceName.length > 0 ? payload.deviceName : payload.deviceId,
      payload.rssi,
      paired,
      BluetoothDeviceKind.CLASSIC,
      payload.deviceClass,
      true,
      TimeUtil.nowMs(),
      [],
      identity.identityId,
      '',
      AddressKind.VIRTUAL,
      IdentityType.VIRTUAL,
      paired ? PairingState.PAIRED : PairingState.UNPAIRED,
      false,
      TimeUtil.nowMs(),
      [],
      source,
      paired ? IdentityStability.PAIRED_STABLE : IdentityStability.CURRENT_SESSION
    );
  }

  static fromBleAdvertising(packet: BleAdvertisingPacket, favorite: boolean, alias: string): BluetoothDevice {
    const identity = BluetoothDeviceMapper.identitySource.buildIdentity(packet.deviceId, false);
    const displayName = alias.length > 0
      ? alias
      : (packet.localName.length > 0 ? packet.localName : packet.deviceId);
    return new BluetoothDevice(
      packet.deviceId,
      displayName,
      packet.rssi,
      false,
      BluetoothDeviceKind.BLE,
      0,
      packet.connectable,
      packet.discoveredAtMs,
      packet.serviceUuids,
      identity.identityId,
      alias,
      AddressKind.VIRTUAL,
      IdentityType.BLE,
      PairingState.UNPAIRED,
      favorite,
      packet.discoveredAtMs,
      [],
      DiscoverySource.DISCOVERY_RESULT,
      IdentityStability.CURRENT_SESSION,
      packet.rawHex
    );
  }

  static applyFavorite(device: BluetoothDevice, favorite: boolean, alias: string): BluetoothDevice {
    return device.withFavorite(favorite, alias);
  }

  static pairStateFromPlatform(state: connection.BondState): PairingState {
    if (state === connection.BondState.BOND_STATE_BONDED) {
      return PairingState.PAIRED;
    }
    if (state === connection.BondState.BOND_STATE_BONDING) {
      return PairingState.PAIRING;
    }
    return PairingState.UNPAIRED;
  }

  static discoverySourceLabel(source: DiscoverySource): string {
    if (source === DiscoverySource.DISCOVERY_RESULT) {
      return 'discoveryResult';
    }
    if (source === DiscoverySource.DEVICE_FIND) {
      return 'bluetoothDeviceFind';
    }
    if (source === DiscoverySource.PAIRED) {
      return 'pairedDevice';
    }
    return `${source}`;
  }

  static nameSourceLabel(source: DeviceNameSource): string {
    return `${source}`;
  }
}
