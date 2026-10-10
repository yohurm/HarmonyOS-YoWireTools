import { TimeUtil } from 'common_core';
import { CapabilityId } from 'debug_core';
import {
  CapabilityRegistry,
  CapabilityResult,
  CapabilityStatus,
  ICapabilityProbe,
  PlatformModuleType
} from 'common_platform';
import { NearLinkRepository } from '../../data/repository/NearLinkRepository';

class NearLinkSupportedProbe implements ICapabilityProbe {
  readonly capabilityId: string = CapabilityId.NEARLINK_SUPPORTED;

  async probe(): Promise<CapabilityResult> {
    const adapter = await NearLinkRepository.getInstance().getAdapterState();
    const supported = adapter.success && adapter.value !== undefined && adapter.value.supported;
    return new CapabilityResult(
      this.capabilityId,
      PlatformModuleType.NEARLINK,
      supported ? CapabilityStatus.AVAILABLE : CapabilityStatus.UNAVAILABLE,
      supported ? 'NearLink hardware supported' : 'NearLink not supported on this device',
      'ohos.permission.ACCESS_NEARLINK',
      '6.1.0(23)+',
      '',
      TimeUtil.nowMs(),
      'Requires real device; emulator unsupported'
    );
  }
}

class NearLinkScanProbe implements ICapabilityProbe {
  readonly capabilityId: string = CapabilityId.NEARLINK_SCAN;

  async probe(): Promise<CapabilityResult> {
    const base = await new NearLinkSupportedProbe().probe();
    if (base.status !== CapabilityStatus.AVAILABLE) {
      return new CapabilityResult(
        this.capabilityId,
        PlatformModuleType.NEARLINK,
        CapabilityStatus.UNAVAILABLE,
        'Scan requires NearLink support',
        'ohos.permission.ACCESS_NEARLINK',
        '5.0.1(13)+',
        '',
        TimeUtil.nowMs()
      );
    }
    const adapter = await NearLinkRepository.getInstance().getAdapterState();
    const enabled = adapter.success && adapter.value !== undefined && adapter.value.enabled;
    return new CapabilityResult(
      this.capabilityId,
      PlatformModuleType.NEARLINK,
      enabled ? CapabilityStatus.AVAILABLE : CapabilityStatus.LIMITED,
      enabled ? 'NearLink scan ready' : 'NearLink switch is off',
      'ohos.permission.ACCESS_NEARLINK',
      '5.0.1(13)+',
      '',
      TimeUtil.nowMs()
    );
  }
}

class NearLinkSsapProbe implements ICapabilityProbe {
  readonly capabilityId: string = CapabilityId.NEARLINK_SSAP_CLIENT;

  async probe(): Promise<CapabilityResult> {
    const scan = await new NearLinkScanProbe().probe();
    return new CapabilityResult(
      this.capabilityId,
      PlatformModuleType.NEARLINK,
      scan.status === CapabilityStatus.AVAILABLE ? CapabilityStatus.AVAILABLE : CapabilityStatus.LIMITED,
      scan.status === CapabilityStatus.AVAILABLE ? 'SSAP Client API available' : scan.reason,
      'ohos.permission.ACCESS_NEARLINK',
      '5.0.1(13)+',
      '',
      TimeUtil.nowMs()
    );
  }
}

class NearLinkDataTransferProbe implements ICapabilityProbe {
  readonly capabilityId: string = CapabilityId.NEARLINK_DATA_TRANSFER;

  async probe(): Promise<CapabilityResult> {
    const scan = await new NearLinkScanProbe().probe();
    return new CapabilityResult(
      this.capabilityId,
      PlatformModuleType.NEARLINK,
      scan.status === CapabilityStatus.AVAILABLE ? CapabilityStatus.AVAILABLE : CapabilityStatus.LIMITED,
      scan.status === CapabilityStatus.AVAILABLE ? 'dataTransfer API available' : scan.reason,
      'ohos.permission.ACCESS_NEARLINK',
      '5.1.0(18)+',
      '',
      TimeUtil.nowMs()
    );
  }
}

/**
 * Registers and probes NearLink capabilities per architecture 04-搂4.1 and PRD 搂5.
 */
export class NearLinkCapabilityService {
  private static registered: boolean = false;

  static ensureRegistered(): void {
    if (NearLinkCapabilityService.registered) {
      return;
    }
    const registry = CapabilityRegistry.getInstance();
    registry.registerProbe(new NearLinkSupportedProbe());
    registry.registerProbe(new NearLinkScanProbe());
    registry.registerProbe(new NearLinkSsapProbe());
    registry.registerProbe(new NearLinkDataTransferProbe());
    NearLinkCapabilityService.registered = true;
  }

  static async probeAll(): Promise<CapabilityResult[]> {
    NearLinkCapabilityService.ensureRegistered();
    const registry = CapabilityRegistry.getInstance();
    const ids = [
      CapabilityId.NEARLINK_SUPPORTED,
      CapabilityId.NEARLINK_SCAN,
      CapabilityId.NEARLINK_SSAP_CLIENT,
      CapabilityId.NEARLINK_DATA_TRANSFER
    ];
    const results: CapabilityResult[] = [];
    for (let i = 0; i < ids.length; i++) {
      results.push(await registry.probe(ids[i]));
    }
    return results;
  }

  static find(results: CapabilityResult[], capabilityId: string): CapabilityResult | undefined {
    for (let i = 0; i < results.length; i++) {
      if (results[i].capabilityId === capabilityId) {
        return results[i];
      }
    }
    return undefined;
  }
}
