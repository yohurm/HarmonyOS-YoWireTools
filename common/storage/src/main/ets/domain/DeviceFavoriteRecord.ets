/**
 * Device favorite record mapped to device_favorite table.
 */
export class DeviceFavoriteRecord {
  readonly id: string;
  readonly module: string;
  readonly protocol: string;
  readonly displayName: string;
  readonly alias: string;
  readonly address: string;
  readonly addressType: string;
  readonly host: string;
  readonly port: number;
  readonly uuid: string;
  readonly attributesJson: string;
  readonly updatedAtMs: number;

  constructor(
    id: string,
    module: string,
    protocol: string,
    displayName: string,
    alias: string,
    address: string,
    addressType: string,
    host: string,
    port: number,
    uuid: string,
    attributesJson: string,
    updatedAtMs: number
  ) {
    this.id = id;
    this.module = module;
    this.protocol = protocol;
    this.displayName = displayName;
    this.alias = alias;
    this.address = address;
    this.addressType = addressType;
    this.host = host;
    this.port = port;
    this.uuid = uuid;
    this.attributesJson = attributesJson;
    this.updatedAtMs = updatedAtMs;
  }
}
