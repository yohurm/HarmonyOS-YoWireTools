import { BleSerialEndpoints } from '../BleSerialPreset';

/**
 * UART connection phase for explicit stage bar (architecture bluetooth/04).
 */
export enum UartConnectPhase {
  IDLE = 'idle',
  CONNECTING = 'connecting',
  DISCOVERING = 'discovering',
  MATCHING_PROFILE = 'matching_profile',
  NEGOTIATING_MTU = 'negotiating_mtu',
  ENABLING_NOTIFY = 'enabling_notify',
  READY = 'ready',
  FAILED_NO_PROFILE = 'failed_no_profile',
  FAILED = 'failed'
}

export enum SerialProfileId {
  NORDIC_UART = 'nordic_uart',
  TI_CC254X = 'ti_cc254x',
  MICROCHIP_RN487X = 'microchip_rn487x',
  TELIT_BLUEMOD = 'telit_bluemod',
  CUSTOM = 'custom',
  UNKNOWN = 'unknown'
}

export class ProfileMatchResult {
  readonly matched: boolean;
  readonly profileId: SerialProfileId;
  readonly endpoints: BleSerialEndpoints | undefined;
  readonly reason: string;

  constructor(
    matched: boolean,
    profileId: SerialProfileId = SerialProfileId.UNKNOWN,
    endpoints: BleSerialEndpoints | undefined = undefined,
    reason: string = ''
  ) {
    this.matched = matched;
    this.profileId = profileId;
    this.endpoints = endpoints;
    this.reason = reason;
  }

  static none(reason: string): ProfileMatchResult {
    return new ProfileMatchResult(false, SerialProfileId.UNKNOWN, undefined, reason);
  }

  static ok(profileId: SerialProfileId, endpoints: BleSerialEndpoints): ProfileMatchResult {
    return new ProfileMatchResult(true, profileId, endpoints, '');
  }
}
