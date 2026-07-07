import { ModuleType, ProtocolType } from 'feature_debug_core';
import { AddressKind, IdentityStability } from './DeviceIdentity';
import { DiscoverySource } from './DiscoverySource';
import { PairingState } from './PairingState';
import { BleScanPhase } from './BleScanPhase';
import { ClassicScanPhase } from './ClassicScanPhase';

export enum BluetoothDeviceKind {
  CLASSIC = 'classic',
  BLE = 'ble'
}

export enum IdentityType {
  CLASSIC = 'classic',
  BLE = 'ble',
  PERSISTENT = 'persistent',
  VIRTUAL = 'virtual',
  UNKNOWN = 'unknown'
}

/**
 * Unified Bluetooth device model per architecture 02-§5.
 */
export class BluetoothDevice {
  readonly identityId: string;
  readonly deviceId: string;
  readonly displayName: string;
  readonly alias: string;
  readonly addressKind: AddressKind;
  readonly identityType: IdentityType;
  readonly rssi: number;
  readonly paired: boolean;
  readonly pairState: PairingState;
  readonly kind: BluetoothDeviceKind;
  readonly deviceType: number;
  readonly connectable: boolean;
  readonly favorite: boolean;
  readonly lastSeenMs: number;
  readonly firstSeenMs: number;
  readonly serviceUuids: string[];
  readonly profileUuids: string[];
  readonly discoverySource: DiscoverySource;
  readonly identityStability: IdentityStability;
  readonly rawHex: string;

  constructor(
    deviceId: string,
    displayName: string,
    rssi: number = 0,
    paired: boolean = false,
    kind: BluetoothDeviceKind = BluetoothDeviceKind.CLASSIC,
    deviceType: number = 0,
    connectable: boolean = true,
    lastSeenMs: number = Date.now(),
    serviceUuids: string[] = [],
    identityId: string = deviceId,
    alias: string = '',
    addressKind: AddressKind = AddressKind.VIRTUAL,
    identityType: IdentityType = IdentityType.UNKNOWN,
    pairState: PairingState = PairingState.UNKNOWN,
    favorite: boolean = false,
    firstSeenMs: number = lastSeenMs,
    profileUuids: string[] = [],
    discoverySource: DiscoverySource = DiscoverySource.DISCOVERY_RESULT,
    identityStability: IdentityStability = IdentityStability.UNKNOWN,
    rawHex: string = ''
  ) {
    this.identityId = identityId;
    this.deviceId = deviceId;
    this.displayName = displayName;
    this.alias = alias;
    this.addressKind = addressKind;
    this.identityType = identityType;
    this.rssi = rssi;
    this.paired = paired;
    this.pairState = pairState;
    this.kind = kind;
    this.deviceType = deviceType;
    this.connectable = connectable;
    this.favorite = favorite;
    this.lastSeenMs = lastSeenMs;
    this.firstSeenMs = firstSeenMs;
    this.serviceUuids = serviceUuids;
    this.profileUuids = profileUuids;
    this.discoverySource = discoverySource;
    this.identityStability = identityStability;
    this.rawHex = rawHex;
  }

  get effectiveName(): string {
    if (this.alias.length > 0) {
      return this.alias;
    }
    return this.displayName;
  }

  withSeen(rssi: number, lastSeenMs: number): BluetoothDevice {
    return new BluetoothDevice(
      this.deviceId,
      this.displayName,
      rssi !== 0 ? rssi : this.rssi,
      this.paired,
      this.kind,
      this.deviceType,
      this.connectable,
      lastSeenMs,
      this.serviceUuids,
      this.identityId,
      this.alias,
      this.addressKind,
      this.identityType,
      this.pairState,
      this.favorite,
      this.firstSeenMs,
      this.profileUuids,
      this.discoverySource,
      this.identityStability,
      this.rawHex
    );
  }

  withPairState(pairState: PairingState, paired: boolean): BluetoothDevice {
    return new BluetoothDevice(
      this.deviceId,
      this.displayName,
      this.rssi,
      paired,
      this.kind,
      this.deviceType,
      this.connectable,
      this.lastSeenMs,
      this.serviceUuids,
      this.identityId,
      this.alias,
      this.addressKind,
      this.identityType,
      pairState,
      this.favorite,
      this.firstSeenMs,
      this.profileUuids,
      this.discoverySource,
      paired ? IdentityStability.PAIRED_STABLE : this.identityStability,
      this.rawHex
    );
  }

  withFavorite(favorite: boolean, alias: string = this.alias): BluetoothDevice {
    return new BluetoothDevice(
      this.deviceId,
      this.displayName,
      this.rssi,
      this.paired,
      this.kind,
      this.deviceType,
      this.connectable,
      this.lastSeenMs,
      this.serviceUuids,
      this.identityId,
      alias,
      this.addressKind,
      this.identityType,
      this.pairState,
      favorite,
      this.firstSeenMs,
      this.profileUuids,
      this.discoverySource,
      this.identityStability,
      this.rawHex
    );
  }

  withProfileUuids(profileUuids: string[]): BluetoothDevice {
    return new BluetoothDevice(
      this.deviceId,
      this.displayName,
      this.rssi,
      this.paired,
      this.kind,
      this.deviceType,
      this.connectable,
      this.lastSeenMs,
      this.serviceUuids,
      this.identityId,
      this.alias,
      this.addressKind,
      this.identityType,
      this.pairState,
      this.favorite,
      this.firstSeenMs,
      profileUuids,
      this.discoverySource,
      this.identityStability,
      this.rawHex
    );
  }
}

export class BluetoothAdapterSnapshot {
  readonly enabled: boolean;
  readonly stateCode: number;
  readonly label: string;

  constructor(enabled: boolean, stateCode: number, label: string) {
    this.enabled = enabled;
    this.stateCode = stateCode;
    this.label = label;
  }
}

export class BluetoothCapabilitySnapshot {
  readonly permissionGranted: boolean;
  readonly adapterOn: boolean;

  constructor(permissionGranted: boolean, adapterOn: boolean) {
    this.permissionGranted = permissionGranted;
    this.adapterOn = adapterOn;
  }
}

export class BluetoothOverviewSnapshot {
  readonly adapter: BluetoothAdapterSnapshot;
  readonly permissionGranted: boolean;
  readonly classicSupported: boolean;
  readonly bleSupported: boolean;
  readonly pairedCount: number;
  readonly favoriteCount: number;
  readonly classicScanPhase: ClassicScanPhase;
  readonly bleScanPhase: BleScanPhase;
  readonly classicDeviceCount: number;
  readonly bleDeviceCount: number;
  readonly activeSessionCount: number;
  readonly warnings: string[];

  constructor(
    adapter: BluetoothAdapterSnapshot,
    permissionGranted: boolean,
    classicSupported: boolean,
    bleSupported: boolean,
    pairedCount: number,
    favoriteCount: number,
    classicScanPhase: ClassicScanPhase,
    bleScanPhase: BleScanPhase,
    classicDeviceCount: number,
    bleDeviceCount: number,
    activeSessionCount: number,
    warnings: string[] = []
  ) {
    this.adapter = adapter;
    this.permissionGranted = permissionGranted;
    this.classicSupported = classicSupported;
    this.bleSupported = bleSupported;
    this.pairedCount = pairedCount;
    this.favoriteCount = favoriteCount;
    this.classicScanPhase = classicScanPhase;
    this.bleScanPhase = bleScanPhase;
    this.classicDeviceCount = classicDeviceCount;
    this.bleDeviceCount = bleDeviceCount;
    this.activeSessionCount = activeSessionCount;
    this.warnings = warnings;
  }
}

export class BluetoothTargetAttributes {
  static moduleType(): ModuleType {
    return ModuleType.BLUETOOTH;
  }

  static sppProtocol(): ProtocolType {
    return ProtocolType.SPP;
  }

  static gattProtocol(): ProtocolType {
    return ProtocolType.BLE_GATT;
  }
}
