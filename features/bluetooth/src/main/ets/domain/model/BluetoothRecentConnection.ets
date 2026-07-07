export class BluetoothRecentConnection {
  readonly deviceId: string;
  readonly displayName: string;
  readonly protocol: string;
  readonly connectedAtMs: number;

  constructor(deviceId: string, displayName: string, protocol: string, connectedAtMs: number) {
    this.deviceId = deviceId;
    this.displayName = displayName;
    this.protocol = protocol;
    this.connectedAtMs = connectedAtMs;
  }

  toJson(): string {
    return `${this.deviceId}|${this.displayName}|${this.protocol}|${this.connectedAtMs}`;
  }

  static fromJson(line: string): BluetoothRecentConnection | undefined {
    const parts = line.split('|');
    if (parts.length < 4) {
      return undefined;
    }
    const connectedAtMs = parseInt(parts[3], 10);
    if (Number.isNaN(connectedAtMs)) {
      return undefined;
    }
    return new BluetoothRecentConnection(parts[0], parts[1], parts[2], connectedAtMs);
  }
}
