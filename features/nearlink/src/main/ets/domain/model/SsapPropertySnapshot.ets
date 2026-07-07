/**
 * Domain snapshot of an SSAP property change event (kit-free).
 */
export class SsapPropertySnapshot {
  readonly serviceUuid: string;
  readonly propertyUuid: string;
  readonly valueBytes: Uint8Array;

  constructor(serviceUuid: string, propertyUuid: string, valueBytes: Uint8Array) {
    this.serviceUuid = serviceUuid;
    this.propertyUuid = propertyUuid;
    this.valueBytes = valueBytes;
  }
}
