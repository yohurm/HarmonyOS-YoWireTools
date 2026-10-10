export class SsapServerWriteRecord {
  readonly requestId: number;
  readonly address: string;
  readonly propertyUuid: string;
  readonly valueHex: string;
  readonly writeType: string;
  readonly responded: boolean;

  constructor(
    requestId: number,
    address: string,
    propertyUuid: string,
    valueHex: string,
    writeType: string,
    responded: boolean
  ) {
    this.requestId = requestId;
    this.address = address;
    this.propertyUuid = propertyUuid;
    this.valueHex = valueHex;
    this.writeType = writeType;
    this.responded = responded;
  }
}
