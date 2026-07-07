export class NearLinkRecentConnection {
  readonly deviceId: string;
  readonly displayName: string;
  readonly protocol: string;
  readonly lastConnectedMs: number;

  constructor(deviceId: string, displayName: string, protocol: string, lastConnectedMs: number) {
    this.deviceId = deviceId;
    this.displayName = displayName;
    this.protocol = protocol;
    this.lastConnectedMs = lastConnectedMs;
  }
}
