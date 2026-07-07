import { PairingState } from './PairingState';

export enum IdentityStability {
  PAIRED_STABLE = 'pairedStable',
  PERSISTENT_MAC = 'persistentMac',
  CURRENT_SESSION = 'currentSession',
  EPHEMERAL_RANDOM = 'ephemeralRandom',
  UNKNOWN = 'unknown'
}

export enum AddressKind {
  VIRTUAL = 'virtual',
  REAL = 'real',
  UNKNOWN = 'unknown'
}

/**
 * Stable device identity per architecture bluetooth/01-§6.2.
 */
export class DeviceIdentity {
  readonly identityId: string;
  readonly platformDeviceId: string;
  readonly platformDeviceIdHash: string;
  readonly userAlias: string;
  readonly identityStability: IdentityStability;
  readonly lastPairState: PairingState;
  readonly lastConnectedAtMs: number;
  readonly notes: string;

  constructor(
    identityId: string,
    platformDeviceId: string,
    platformDeviceIdHash: string,
    userAlias: string = '',
    identityStability: IdentityStability = IdentityStability.UNKNOWN,
    lastPairState: PairingState = PairingState.UNKNOWN,
    lastConnectedAtMs: number = 0,
    notes: string = ''
  ) {
    this.identityId = identityId;
    this.platformDeviceId = platformDeviceId;
    this.platformDeviceIdHash = platformDeviceIdHash;
    this.userAlias = userAlias;
    this.identityStability = identityStability;
    this.lastPairState = lastPairState;
    this.lastConnectedAtMs = lastConnectedAtMs;
    this.notes = notes;
  }
}
