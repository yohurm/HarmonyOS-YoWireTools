import { ModuleType, ProtocolType } from 'debug_core';
import { IdentityStability } from './DeviceIdentity';
import { DiscoverySource } from './DiscoverySource';
import { PairingState } from './PairingState';
import { BleScanPhase } from './BleScanPhase';
import { ClassicScanPhase } from './ClassicScanPhase';
import {
  AddressPrivacyKind,
  BluetoothListRail,
  BluetoothRawAddrKind,
  BluetoothTransportType
} from './BluetoothTransportType';

/**
 * Unified Bluetooth device model per architecture bluetooth/00.
 * Uses draft-based construction to avoid positional-arg copy bugs.
 */
export class BluetoothDeviceDraft {
  identityId: string = '';
  displayName: string = '';
  alias: string = '';
  classicDeviceId: string = '';
  bleDeviceId: string = '';
  primaryDeviceId: string = '';
  addressPrivacy: AddressPrivacyKind = AddressPrivacyKind.VIRTUAL;
  rawAddressKind: BluetoothRawAddrKind = BluetoothRawAddrKind.UNKNOWN;
  transport: BluetoothTransportType = BluetoothTransportType.UNKNOWN;
  deviceClassCod: number = 0;
  majorClass: number = 0;
  majorMinorClass: number = 0;
  listRail: BluetoothListRail = BluetoothListRail.CLASSIC_SCAN;
  rssi: number = 0;
  rssiKnown: boolean = false;
  paired: boolean = false;
  pairState: PairingState = PairingState.UNKNOWN;
  connectable: boolean = true;
  favorite: boolean = false;
  lastSeenMs: number = Date.now();
  firstSeenMs: number = Date.now();
  serviceUuids: string[] = [];
  profileUuids: string[] = [];
  discoverySource: DiscoverySource = DiscoverySource.DISCOVERY_RESULT;
  identityStability: IdentityStability = IdentityStability.UNKNOWN;
  rawHex: string = '';
}

export class BluetoothDevice {
  readonly identityId: string;
  readonly displayName: string;
  readonly alias: string;
  readonly classicDeviceId: string;
  readonly bleDeviceId: string;
  readonly primaryDeviceId: string;
  readonly addressPrivacy: AddressPrivacyKind;
  readonly rawAddressKind: BluetoothRawAddrKind;
  readonly transport: BluetoothTransportType;
  readonly deviceClassCod: number;
  readonly majorClass: number;
  readonly majorMinorClass: number;
  readonly listRail: BluetoothListRail;
  readonly rssi: number;
  readonly rssiKnown: boolean;
  readonly paired: boolean;
  readonly pairState: PairingState;
  readonly connectable: boolean;
  readonly favorite: boolean;
  readonly lastSeenMs: number;
  readonly firstSeenMs: number;
  readonly serviceUuids: string[];
  readonly profileUuids: string[];
  readonly discoverySource: DiscoverySource;
  readonly identityStability: IdentityStability;
  readonly rawHex: string;

  constructor(draft: BluetoothDeviceDraft) {
    this.identityId = draft.identityId.length > 0 ? draft.identityId : draft.primaryDeviceId;
    this.displayName = draft.displayName;
    this.alias = draft.alias;
    this.classicDeviceId = draft.classicDeviceId;
    this.bleDeviceId = draft.bleDeviceId;
    this.primaryDeviceId = draft.primaryDeviceId.length > 0
      ? draft.primaryDeviceId
      : (draft.classicDeviceId.length > 0 ? draft.classicDeviceId : draft.bleDeviceId);
    this.addressPrivacy = draft.addressPrivacy;
    this.rawAddressKind = draft.rawAddressKind;
    this.transport = draft.transport;
    this.deviceClassCod = draft.deviceClassCod;
    this.majorClass = draft.majorClass;
    this.majorMinorClass = draft.majorMinorClass;
    this.listRail = draft.listRail;
    this.rssi = draft.rssi;
    this.rssiKnown = draft.rssiKnown;
    this.paired = draft.paired;
    this.pairState = draft.pairState;
    this.connectable = draft.connectable;
    this.favorite = draft.favorite;
    this.lastSeenMs = draft.lastSeenMs;
    this.firstSeenMs = draft.firstSeenMs;
    this.serviceUuids = draft.serviceUuids;
    this.profileUuids = draft.profileUuids;
    this.discoverySource = draft.discoverySource;
    this.identityStability = draft.identityStability;
    this.rawHex = draft.rawHex;
  }

  get effectiveName(): string {
    if (this.alias.length > 0) {
      return this.alias;
    }
    return this.displayName;
  }

  /** 是否来自 Inquiry / discovery 回调（非仅配对缓存 seed）。 */
  hasLiveDiscoverySignal(): boolean {
    return this.discoverySource === DiscoverySource.DISCOVERY_RESULT ||
      this.discoverySource === DiscoverySource.DEVICE_FIND;
  }

  toDraft(): BluetoothDeviceDraft {
    const draft = new BluetoothDeviceDraft();
    draft.identityId = this.identityId;
    draft.displayName = this.displayName;
    draft.alias = this.alias;
    draft.classicDeviceId = this.classicDeviceId;
    draft.bleDeviceId = this.bleDeviceId;
    draft.primaryDeviceId = this.primaryDeviceId;
    draft.addressPrivacy = this.addressPrivacy;
    draft.rawAddressKind = this.rawAddressKind;
    draft.transport = this.transport;
    draft.deviceClassCod = this.deviceClassCod;
    draft.majorClass = this.majorClass;
    draft.majorMinorClass = this.majorMinorClass;
    draft.listRail = this.listRail;
    draft.rssi = this.rssi;
    draft.rssiKnown = this.rssiKnown;
    draft.paired = this.paired;
    draft.pairState = this.pairState;
    draft.connectable = this.connectable;
    draft.favorite = this.favorite;
    draft.lastSeenMs = this.lastSeenMs;
    draft.firstSeenMs = this.firstSeenMs;
    draft.serviceUuids = this.serviceUuids.slice();
    draft.profileUuids = this.profileUuids.slice();
    draft.discoverySource = this.discoverySource;
    draft.identityStability = this.identityStability;
    draft.rawHex = this.rawHex;
    return draft;
  }

  withSeen(rssi: number, lastSeenMs: number): BluetoothDevice {
    const draft = this.toDraft();
    if (rssi !== 0) {
      draft.rssi = rssi;
      draft.rssiKnown = true;
    }
    draft.lastSeenMs = lastSeenMs;
    return new BluetoothDevice(draft);
  }

  withPairState(pairState: PairingState, paired: boolean): BluetoothDevice {
    const draft = this.toDraft();
    draft.pairState = pairState;
    draft.paired = paired;
    if (paired) {
      draft.identityStability = IdentityStability.PAIRED_STABLE;
    }
    return new BluetoothDevice(draft);
  }

  withFavorite(favorite: boolean, alias: string = this.alias): BluetoothDevice {
    const draft = this.toDraft();
    draft.favorite = favorite;
    draft.alias = alias;
    return new BluetoothDevice(draft);
  }

  withProfileUuids(profileUuids: string[]): BluetoothDevice {
    const draft = this.toDraft();
    draft.profileUuids = profileUuids.slice();
    return new BluetoothDevice(draft);
  }

  withTransport(transport: BluetoothTransportType): BluetoothDevice {
    const draft = this.toDraft();
    draft.transport = transport;
    return new BluetoothDevice(draft);
  }

  withDualAddresses(classicDeviceId: string, bleDeviceId: string): BluetoothDevice {
    const draft = this.toDraft();
    draft.classicDeviceId = classicDeviceId;
    draft.bleDeviceId = bleDeviceId;
    draft.transport = BluetoothTransportType.DUAL;
    if (draft.listRail === BluetoothListRail.CLASSIC_SCAN) {
      draft.primaryDeviceId = classicDeviceId;
    } else {
      draft.primaryDeviceId = bleDeviceId;
    }
    return new BluetoothDevice(draft);
  }

  mergeFrom(other: BluetoothDevice): BluetoothDevice {
    const draft = this.toDraft();
    if (other.displayName.length > 0) {
      draft.displayName = other.displayName;
    }
    if (other.rssiKnown) {
      draft.rssi = other.rssi;
      draft.rssiKnown = true;
    }
    draft.paired = draft.paired || other.paired;
    draft.connectable = other.connectable;
    draft.lastSeenMs = other.lastSeenMs > 0 ? other.lastSeenMs : draft.lastSeenMs;
    if (other.serviceUuids.length > 0) {
      draft.serviceUuids = other.serviceUuids.slice();
    }
    if (other.alias.length > 0 && draft.alias.length === 0) {
      draft.alias = other.alias;
    }
    if (other.pairState !== draft.pairState) {
      draft.pairState = other.pairState;
    }
    draft.favorite = draft.favorite || other.favorite;
    if (other.profileUuids.length > 0) {
      draft.profileUuids = other.profileUuids.slice();
    }
    if (other.deviceClassCod !== 0) {
      draft.deviceClassCod = other.deviceClassCod;
      draft.majorClass = other.majorClass;
      draft.majorMinorClass = other.majorMinorClass;
    }
    if (other.transport !== BluetoothTransportType.UNKNOWN) {
      draft.transport = other.transport;
    }
    if (other.classicDeviceId.length > 0) {
      draft.classicDeviceId = other.classicDeviceId;
    }
    if (other.bleDeviceId.length > 0) {
      draft.bleDeviceId = other.bleDeviceId;
    }
    if (other.rawHex.length > 0) {
      draft.rawHex = other.rawHex;
    }
    draft.discoverySource = other.discoverySource;
    return new BluetoothDevice(draft);
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
