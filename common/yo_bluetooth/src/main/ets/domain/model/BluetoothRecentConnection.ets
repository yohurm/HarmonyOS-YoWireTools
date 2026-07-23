export class BluetoothRecentConnection {
  readonly targetAddress: string;
  readonly displayName: string;
  readonly protocol: string;
  readonly connectedAtMs: number;

  constructor(targetAddress: string, displayName: string, protocol: string, connectedAtMs: number) {
    this.targetAddress = targetAddress;
    this.displayName = displayName;
    this.protocol = protocol;
    this.connectedAtMs = connectedAtMs;
  }

  toJson(): string {
    return `${this.targetAddress}|${this.displayName}|${this.protocol}|${this.connectedAtMs}`;
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
