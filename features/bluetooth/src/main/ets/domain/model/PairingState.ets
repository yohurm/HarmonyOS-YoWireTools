export enum PairingState {
  UNKNOWN = 'unknown',
  UNPAIRED = 'unpaired',
  PAIRING = 'pairing',
  PAIRED = 'paired',
  FAILED = 'failed',
  CANCELLED = 'cancelled'
}

export class PairingEvent {
  readonly deviceId: string;
  readonly state: PairingState;
  readonly timestampMs: number;

  constructor(deviceId: string, state: PairingState, timestampMs: number) {
    this.deviceId = deviceId;
    this.state = state;
    this.timestampMs = timestampMs;
  }
}
