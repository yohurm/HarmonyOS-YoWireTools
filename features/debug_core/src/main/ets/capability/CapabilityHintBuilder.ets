import { CapabilityResult, CapabilityStatus } from 'common_platform';

/**
 * Business degradation hints per architecture §8.2.
 */
export class CapabilityHintBuilder {
  static fromResult(result: CapabilityResult): CapabilityDegradationHint | undefined {
    if (result.status === CapabilityStatus.AVAILABLE || result.status === CapabilityStatus.LIMITED) {
      return undefined;
    }
    const reasonLower = result.reason.toLowerCase();
    const missingPermission = result.requiredPermission.length > 0 || reasonLower.indexOf('permission') >= 0;
    const deviceUnsupported = reasonLower.indexOf('unsupported') >= 0 || reasonLower.indexOf('hardware') >= 0;
    const apiLevelInsufficient = reasonLower.indexOf('api') >= 0 || reasonLower.indexOf('version') >= 0;
    const systemSwitchRequired = reasonLower.indexOf('switch') >= 0 || reasonLower.indexOf('disabled') >= 0;
    let nextAction = 'Retry capability probe';
    if (missingPermission) {
      nextAction = 'Grant required permission in settings';
    } else if (systemSwitchRequired) {
      nextAction = 'Enable system switch in settings';
    } else if (deviceUnsupported) {
      nextAction = 'Use a supported device or downgrade feature';
    } else if (apiLevelInsufficient) {
      nextAction = 'Upgrade system version';
    }
    return new CapabilityDegradationHint(
      result.capabilityId,
      result.reason.length > 0 ? result.reason : 'Capability unavailable',
      missingPermission,
      deviceUnsupported,
      apiLevelInsufficient,
      systemSwitchRequired,
      nextAction
    );
  }
}

export class CapabilityDegradationHint {
  readonly capabilityId: string;
  readonly unavailableReason: string;
  readonly missingPermission: boolean;
  readonly deviceUnsupported: boolean;
  readonly apiLevelInsufficient: boolean;
  readonly systemSwitchRequired: boolean;
  readonly nextUserAction: string;

  constructor(
    capabilityId: string,
    unavailableReason: string,
    missingPermission: boolean,
    deviceUnsupported: boolean,
    apiLevelInsufficient: boolean,
    systemSwitchRequired: boolean,
    nextUserAction: string
  ) {
    this.capabilityId = capabilityId;
    this.unavailableReason = unavailableReason;
    this.missingPermission = missingPermission;
    this.deviceUnsupported = deviceUnsupported;
    this.apiLevelInsufficient = apiLevelInsufficient;
    this.systemSwitchRequired = systemSwitchRequired;
    this.nextUserAction = nextUserAction;
  }
}
