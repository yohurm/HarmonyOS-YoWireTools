export class SsapPropertyNotifyPayload {
  readonly serviceUuid: string;
  readonly propertyUuid: string;
  readonly valueHex: string;
  readonly timestampMs: number;

  constructor(serviceUuid: string, propertyUuid: string, valueHex: string, timestampMs: number) {
    this.serviceUuid = serviceUuid;
    this.propertyUuid = propertyUuid;
    this.valueHex = valueHex;
    this.timestampMs = timestampMs;
  }
}
