import { PlatformModuleType } from './PlatformModuleType';
import { CapabilityStatus } from './CapabilityStatus';

/**
 * Capability probe result per architecture §8.1 and 05-§3.8.
 */
export class CapabilityResult {
  readonly capabilityId: string;
  readonly module: PlatformModuleType;
  readonly status: CapabilityStatus;
  readonly reason: string;
  readonly requiredPermission: string;
  readonly apiLevel: string;
  readonly nativeCode: string;
  readonly verifiedAtMs: number;
  readonly deviceInfo: string;

  constructor(
    capabilityId: string,
    module: PlatformModuleType,
    status: CapabilityStatus,
    reason: string = '',
    requiredPermission: string = '',
    apiLevel: string = '',
    nativeCode: string = '',
    verifiedAtMs: number = Date.now(),
    deviceInfo: string = ''
  ) {
    this.capabilityId = capabilityId;
    this.module = module;
    this.status = status;
    this.reason = reason;
    this.requiredPermission = requiredPermission;
    this.apiLevel = apiLevel;
    this.nativeCode = nativeCode;
    this.verifiedAtMs = verifiedAtMs;
    this.deviceInfo = deviceInfo;
  }
}
