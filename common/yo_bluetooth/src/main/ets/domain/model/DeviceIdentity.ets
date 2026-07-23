import { PairingState } from './PairingState';
import { BluetoothTransportType } from './BluetoothTransportType';

export enum IdentityStability {
  PAIRED_STABLE = 'pairedStable',
  PERSISTENT_MAC = 'persistentMac',
  CURRENT_SESSION = 'currentSession',
  EPHEMERAL_RANDOM = 'ephemeralRandom',
  UNKNOWN = 'unknown'
}

/**
 * Stable dual-address device identity per architecture bluetooth/00-§3.3.
 */
export class DeviceIdentity {
  readonly identityId: string;
  readonly classicDeviceId: string;
  readonly bleDeviceId: string;
  readonly classicIdHash: string;
  readonly bleIdHash: string;
  readonly transport: BluetoothTransportType;
  readonly displayNameHint: string;
  readonly userAlias: string;
  readonly identityStability: IdentityStability;
  readonly lastPairState: PairingState;
  readonly lastConnectedAtMs: number;
  readonly linkedAtMs: number;
  readonly notes: string;

  constructor(
    identityId: string,
    classicDeviceId: string = '',
    bleDeviceId: string = '',
    classicIdHash: string = '',
    bleIdHash: string = '',
    transport: BluetoothTransportType = BluetoothTransportType.UNKNOWN,
    displayNameHint: string = '',
    userAlias: string = '',
    identityStability: IdentityStability = IdentityStability.UNKNOWN,
    lastPairState: PairingState = PairingState.UNKNOWN,
    lastConnectedAtMs: number = 0,
    linkedAtMs: number = 0,
    notes: string = ''
  ) {
    this.identityId = identityId;
    this.classicDeviceId = classicDeviceId;
    this.bleDeviceId = bleDeviceId;
    this.classicIdHash = classicIdHash;
    this.bleIdHash = bleIdHash;
    this.transport = transport;
    this.displayNameHint = displayNameHint;
    this.userAlias = userAlias;
    this.identityStability = identityStability;
    this.lastPairState = lastPairState;
    this.lastConnectedAtMs = lastConnectedAtMs;
    this.linkedAtMs = linkedAtMs;
    this.notes = notes;
  }

  withLink(
    classicDeviceId: string,
    bleDeviceId: string,
    transport: BluetoothTransportType = BluetoothTransportType.DUAL
  ): DeviceIdentity {
    return new DeviceIdentity(
      this.identityId,
      classicDeviceId,
      bleDeviceId,
      this.classicIdHash.length > 0 ? this.classicIdHash : DeviceIdentity.hashOf(classicDeviceId),
      this.bleIdHash.length > 0 ? this.bleIdHash : DeviceIdentity.hashOf(bleDeviceId),
      transport,
      this.displayNameHint,
      this.userAlias,
      this.identityStability,
      this.lastPairState,
      this.lastConnectedAtMs,
      Date.now(),
      this.notes
    );
  }

  static hashOf(value: string): string {
    let hash = 0;
    for (let i = 0; i < value.length; i++) {
      hash = ((hash << 5) - hash) + value.charCodeAt(i);
      hash |= 0;
    }
    return `h${Math.abs(hash)}`;
  }
}
