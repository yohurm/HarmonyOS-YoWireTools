import { ModuleType, ProtocolType } from '../enums/DomainEnums';

/**
 * Unified debug target per 05-§3.1.
 */
export class DebugTarget {
  readonly id: string;
  readonly module: ModuleType;
  readonly protocol: ProtocolType;
  readonly displayName: string;
  readonly address: string;
  readonly addressType: string;
  readonly host: string;
  readonly port: number;
  readonly uuid: string;
  readonly alias: string;
  readonly favorite: boolean;
  readonly attributes: Record<string, string | number | boolean>;

  constructor(
    id: string,
    module: ModuleType,
    displayName: string,
    protocol: ProtocolType = ProtocolType.NONE,
    address: string = '',
    addressType: string = '',
    host: string = '',
    port: number = 0,
    uuid: string = '',
    alias: string = '',
    favorite: boolean = false,
    attributes: Record<string, string | number | boolean> = {}
  ) {
    this.id = id;
    this.module = module;
    this.displayName = displayName;
    this.protocol = protocol;
    this.address = address;
    this.addressType = addressType;
    this.host = host;
    this.port = port;
    this.uuid = uuid;
    this.alias = alias;
    this.favorite = favorite;
    this.attributes = attributes;
  }
}
