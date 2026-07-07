/**
 * Capability probe persistence record mapped to capability_result table.
 */
export class CapabilityResultRecord {
  readonly capabilityId: string;
  readonly module: string;
  readonly status: string;
  readonly reason: string;
  readonly requiredPermission: string;
  readonly apiLevel: string;
  readonly nativeCode: string;
  readonly verifiedAtMs: number;

  constructor(
    capabilityId: string,
    module: string,
    status: string,
    reason: string,
    requiredPermission: string,
    apiLevel: string,
    nativeCode: string,
    verifiedAtMs: number
  ) {
    this.capabilityId = capabilityId;
    this.module = module;
    this.status = status;
    this.reason = reason;
    this.requiredPermission = requiredPermission;
    this.apiLevel = apiLevel;
    this.nativeCode = nativeCode;
    this.verifiedAtMs = verifiedAtMs;
  }
}
