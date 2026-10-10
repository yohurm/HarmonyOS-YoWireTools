export class NetworkStateSnapshot {
  readonly hasDefaultNet: boolean;
  readonly netType: string;
  readonly bearerTypes: string;

  constructor(hasDefaultNet: boolean, netType: string, bearerTypes: string) {
    this.hasDefaultNet = hasDefaultNet;
    this.netType = netType;
    this.bearerTypes = bearerTypes;
  }
}
