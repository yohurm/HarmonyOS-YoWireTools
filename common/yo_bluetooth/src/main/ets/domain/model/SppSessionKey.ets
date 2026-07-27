/**
 * SPP session identity per HarmonyOS RFCOMM model.
 *
 * Platform rules (ohos.bluetooth.socket + GAIA FAQ):
 * - Each sppConnect yields an independent clientSocket per (classicDeviceId, uuid) pair.
 * - Same device + same UUID cannot be connected concurrently.
 * - Different devices may share the same standard SPP UUID concurrently.
 * - on('sppRead') and sppReadAsync must not be mixed on the same clientSocket.
 *
 * Normalization (shared by Connect / Admission / Catalog / Ledger):
 * - classicDeviceId: trim + uppercase
 * - serviceUuid: trim + lowercase
 */
export class SppSessionKey {
  readonly classicDeviceId: string;
  readonly serviceUuid: string;

  constructor(classicDeviceId: string, serviceUuid: string) {
    this.classicDeviceId = SppSessionKey.normalizeClassicId(classicDeviceId);
    this.serviceUuid = SppSessionKey.normalizeUuid(serviceUuid);
  }

  static fromParts(classicDeviceId: string, serviceUuid: string): SppSessionKey {
    return new SppSessionKey(classicDeviceId, serviceUuid);
  }

  static normalizeClassicId(classicDeviceId: string): string {
    return classicDeviceId.trim().toUpperCase();
  }

  static normalizeUuid(uuid: string): string {
    return uuid.trim().toLowerCase();
  }

  compositeKey(): string {
    return `${this.classicDeviceId}#${this.serviceUuid}`;
  }

  isValid(): boolean {
    return this.classicDeviceId.length > 0 && this.serviceUuid.length > 0;
  }
}
