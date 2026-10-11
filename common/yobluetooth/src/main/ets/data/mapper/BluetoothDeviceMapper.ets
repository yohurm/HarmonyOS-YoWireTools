import { TimeUtil } from 'common_core';
import { PlatformDiscoveryPayload } from '../datasource/platform/ClassicBluetoothDataSource';
import { IdentityStability } from '../../domain/model/DeviceIdentity';
import {
  BluetoothDevice,
  BluetoothDeviceDraft
} from '../../domain/model/BluetoothDevice';
import { DiscoverySource } from '../../domain/model/DiscoverySource';
import { PairingState } from '../../domain/model/PairingState';
import { BleAdvertisingPacket } from '../../domain/model/BleAdvertisingPacket';
import {
  AddressPrivacyKind,
  BluetoothListRail,
  BluetoothTransportType
} from '../../domain/model/BluetoothTransportType';
import { BluetoothIdentityDataSource } from '../datasource/platform/BluetoothIdentityDataSource';
import { connection } from '@kit.ConnectivityKit';

export class PlatformPairedSnapshot {
  readonly address: string;
  readonly deviceName: string;
  readonly transport: BluetoothTransportType;
  readonly deviceClassCod: number;
  readonly majorClass: number;
  readonly majorMinorClass: number;

  constructor(
    address: string,
    deviceName: string,
    transport: BluetoothTransportType,
    deviceClassCod: number = 0,
    majorClass: number = 0,
    majorMinorClass: number = 0
  ) {
    this.address = address;
    this.deviceName = deviceName;
    this.transport = transport;
    this.deviceClassCod = deviceClassCod;
    this.majorClass = majorClass;
    this.majorMinorClass = majorMinorClass;
  }
}

export class BluetoothDeviceMapper {
  private static readonly identitySource: BluetoothIdentityDataSource =
    BluetoothIdentityDataSource.getInstance();

  /**
   * Map paired snapshot onto a specific list rail.
   * Dual-mode devices may appear twice (classic MAC + BLE MAC); each side writes its own address field.
   */
  static fromPairedSnapshot(
    snapshot: PlatformPairedSnapshot,
    listRail: BluetoothListRail = BluetoothListRail.CLASSIC_SCAN
  ): BluetoothDevice {
    const linked = BluetoothDeviceMapper.identitySource.findLinkedByAnyAddress(snapshot.address);
    const draft = new BluetoothDeviceDraft();
    const identity = linked !== undefined
      ? linked
      : BluetoothDeviceMapper.identitySource.buildIdentityForRail(
        snapshot.address,
        true,
        listRail,
        snapshot.transport
      );
    draft.identityId = identity.identityId;
    draft.displayName = snapshot.deviceName.length > 0 ? snapshot.deviceName : snapshot.address;
    draft.transport = snapshot.transport;
    draft.deviceClassCod = snapshot.deviceClassCod;
    draft.majorClass = snapshot.majorClass;
    draft.majorMinorClass = snapshot.majorMinorClass;
    draft.paired = true;
    draft.pairState = PairingState.PAIRED;
    draft.connectable = true;
    draft.lastSeenMs = TimeUtil.nowMs();
    draft.firstSeenMs = draft.lastSeenMs;
    draft.discoverySource = DiscoverySource.PAIRED;
    draft.identityStability = IdentityStability.PAIRED_STABLE;
    draft.addressPrivacy = AddressPrivacyKind.VIRTUAL;
    draft.listRail = listRail;
    draft.primaryDeviceId = snapshot.address;
    if (listRail === BluetoothListRail.BLE_SCAN) {
      draft.bleDeviceId = snapshot.address;
      if (linked !== undefined && linked.classicDeviceId.length > 0) {
        draft.classicDeviceId = linked.classicDeviceId;
        draft.transport = BluetoothTransportType.DUAL;
        draft.discoverySource = DiscoverySource.BRIDGED;
      }
    } else {
      draft.classicDeviceId = snapshot.address;
      if (linked !== undefined && linked.bleDeviceId.length > 0) {
        draft.bleDeviceId = linked.bleDeviceId;
        draft.transport = BluetoothTransportType.DUAL;
        draft.discoverySource = DiscoverySource.BRIDGED;
      }
    }
    return new BluetoothDevice(draft);
  }

  static fromDiscovery(
    payload: PlatformDiscoveryPayload,
    transport: BluetoothTransportType = BluetoothTransportType.UNKNOWN,
    paired: boolean = false
  ): BluetoothDevice {
    const identity = BluetoothDeviceMapper.identitySource.buildIdentityForRail(
      payload.classicDeviceId,
      paired,
      BluetoothListRail.CLASSIC_SCAN,
      transport
    );
    const draft = new BluetoothDeviceDraft();
    draft.identityId = identity.identityId;
    draft.displayName = payload.fromLegacyFind ? '' : payload.deviceName;
    draft.classicDeviceId = payload.classicDeviceId;
    draft.primaryDeviceId = payload.classicDeviceId;
    draft.listRail = BluetoothListRail.CLASSIC_SCAN;
    draft.transport = transport;
    draft.deviceClassCod = payload.deviceClass;
    draft.majorClass = payload.majorClass;
    draft.majorMinorClass = payload.majorMinorClass;
    draft.rssi = payload.fromLegacyFind ? 0 : payload.rssi;
    draft.rssiKnown = !payload.fromLegacyFind;
    draft.paired = paired;
    draft.pairState = paired ? PairingState.PAIRED : PairingState.UNPAIRED;
    draft.connectable = true;
    draft.lastSeenMs = TimeUtil.nowMs();
    draft.firstSeenMs = draft.lastSeenMs;
    draft.discoverySource = payload.fromLegacyFind ?
      DiscoverySource.DEVICE_FIND :
      DiscoverySource.DISCOVERY_RESULT;
    draft.identityStability = paired ?
      IdentityStability.PAIRED_STABLE :
      IdentityStability.CURRENT_SESSION;
    draft.addressPrivacy = AddressPrivacyKind.VIRTUAL;
    return new BluetoothDevice(draft);
  }

  static fromBleAdvertising(packet: BleAdvertisingPacket, favorite: boolean, alias: string): BluetoothDevice {
    const identity = BluetoothDeviceMapper.identitySource.buildIdentityForRail(
      packet.bleDeviceId,
      false,
      BluetoothListRail.BLE_SCAN,
      BluetoothTransportType.LE
    );
    const draft = new BluetoothDeviceDraft();
    draft.identityId = identity.identityId;
    draft.displayName = alias.length > 0
      ? alias
      : (packet.localName.length > 0 ? packet.localName : packet.bleDeviceId);
    draft.alias = alias;
    draft.bleDeviceId = packet.bleDeviceId;
    draft.primaryDeviceId = packet.bleDeviceId;
    draft.listRail = BluetoothListRail.BLE_SCAN;
    draft.transport = BluetoothTransportType.LE;
    draft.rssi = packet.rssi;
    draft.rssiKnown = true;
    draft.paired = false;
    draft.pairState = PairingState.UNPAIRED;
    draft.connectable = packet.connectable;
    draft.favorite = favorite;
    draft.lastSeenMs = packet.discoveredAtMs;
    draft.firstSeenMs = packet.discoveredAtMs;
    draft.serviceUuids = packet.serviceUuids.slice();
    draft.discoverySource = DiscoverySource.BLE_ADV;
    draft.identityStability = IdentityStability.CURRENT_SESSION;
    draft.addressPrivacy = AddressPrivacyKind.VIRTUAL;
    draft.rawHex = packet.rawHex;
    return new BluetoothDevice(draft);
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
}
