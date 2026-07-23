export enum PairingState {
  UNKNOWN = 'unknown',
  UNPAIRED = 'unpaired',
  PAIRING = 'pairing',
  PAIRED = 'paired',
  FAILED = 'failed',
  CANCELLED = 'cancelled'
}

export class PairingEvent {
  readonly address: string;
  readonly state: PairingState;
  readonly timestampMs: number;

  constructor(address: string, state: PairingState, timestampMs: number) {
    this.address = address;
    this.state = state;
    this.timestampMs = timestampMs;
  }
}
