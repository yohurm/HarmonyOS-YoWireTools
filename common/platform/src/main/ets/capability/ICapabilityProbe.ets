import { CapabilityResult } from './CapabilityResult';

/**
 * Pluggable native capability probe registered by feature modules.
 */
export interface ICapabilityProbe {
  readonly capabilityId: string;
  probe(): Promise<CapabilityResult>;
}
