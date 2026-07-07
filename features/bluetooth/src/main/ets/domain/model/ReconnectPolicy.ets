/**
 * SPP auto-reconnect policy per architecture bluetooth/02-§9.
 */
export class ReconnectPolicy {
  readonly maxAttempts: number;
  readonly initialDelayMs: number;
  readonly maxDelayMs: number;
  readonly backoffFactor: number;
  readonly stopOnPermissionLost: boolean;
  readonly stopOnPairLost: boolean;

  constructor(
    maxAttempts: number = 5,
    initialDelayMs: number = 1000,
    maxDelayMs: number = 15000,
    backoffFactor: number = 2,
    stopOnPermissionLost: boolean = true,
    stopOnPairLost: boolean = true
  ) {
    this.maxAttempts = maxAttempts;
    this.initialDelayMs = initialDelayMs;
    this.maxDelayMs = maxDelayMs;
    this.backoffFactor = backoffFactor;
    this.stopOnPermissionLost = stopOnPermissionLost;
    this.stopOnPairLost = stopOnPairLost;
  }

  static defaultPolicy(): ReconnectPolicy {
    return new ReconnectPolicy();
  }

  computeDelayMs(attemptIndex: number): number {
    const scaled = this.initialDelayMs * Math.pow(this.backoffFactor, attemptIndex);
    return scaled > this.maxDelayMs ? this.maxDelayMs : scaled;
  }
}
