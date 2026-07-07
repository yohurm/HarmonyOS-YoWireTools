import { TimeUtil } from 'common_core';
import { AppLogger } from '../logging/AppLogger';
import { AppLogTag } from '../logging/AppLogTag';
import { LogParams } from '../logging/LogParams';
import { CapabilityResult } from './CapabilityResult';
import { CapabilityStatus } from './CapabilityStatus';
import { ICapabilityProbe } from './ICapabilityProbe';
import { PlatformModuleType } from './PlatformModuleType';

const logger = new AppLogger(AppLogTag.CAP);

/**
 * Generic capability probe registry — catalog IDs are configured by business layer.
 */
export class CapabilityRegistry {
  private static instance: CapabilityRegistry | undefined;
  private readonly probes: Map<string, ICapabilityProbe> = new Map();
  private readonly cache: Map<string, CapabilityResult> = new Map();
  private knownCapabilityIds: string[] = [];

  private constructor() {
  }

  static getInstance(): CapabilityRegistry {
    if (CapabilityRegistry.instance === undefined) {
      CapabilityRegistry.instance = new CapabilityRegistry();
    }
    return CapabilityRegistry.instance;
  }

  configureCatalog(capabilityIds: string[]): void {
    this.knownCapabilityIds = capabilityIds.slice();
    for (let i = 0; i < capabilityIds.length; i++) {
      if (!this.cache.has(capabilityIds[i])) {
        this.cache.set(capabilityIds[i], CapabilityRegistry.createUnknown(capabilityIds[i]));
      }
    }
  }

  registerProbe(probe: ICapabilityProbe): void {
    this.probes.set(probe.capabilityId, probe);
  }

  unregisterProbe(capabilityId: string): void {
    this.probes.delete(capabilityId);
  }

  async get(capabilityId: string): Promise<CapabilityResult | undefined> {
    return this.cache.get(capabilityId);
  }

  async list(module?: PlatformModuleType): Promise<CapabilityResult[]> {
    const results: CapabilityResult[] = [];
    for (let i = 0; i < this.knownCapabilityIds.length; i++) {
      const result = await this.get(this.knownCapabilityIds[i]);
      if (result !== undefined && (module === undefined || result.module === module)) {
        results.push(result);
      }
    }
    return results;
  }

  async probe(capabilityId: string): Promise<CapabilityResult> {
    const probe = this.probes.get(capabilityId);
    if (probe === undefined) {
      const unknown = CapabilityRegistry.createUnknown(capabilityId, 'Probe not registered yet');
      this.cache.set(capabilityId, unknown);
      return unknown;
    }
    const result = await probe.probe();
    this.cache.set(capabilityId, result);
    logger.params('capability_probe', LogParams.create()
      .put('id', capabilityId)
      .put('status', `${result.status}`));
    return result;
  }

  async probeAll(): Promise<CapabilityResult[]> {
    const results: CapabilityResult[] = [];
    for (let i = 0; i < this.knownCapabilityIds.length; i++) {
      results.push(await this.probe(this.knownCapabilityIds[i]));
    }
    return results;
  }

  clearCache(): void {
    this.cache.clear();
    for (let i = 0; i < this.knownCapabilityIds.length; i++) {
      this.cache.set(this.knownCapabilityIds[i], CapabilityRegistry.createUnknown(this.knownCapabilityIds[i]));
    }
  }

  private static createUnknown(capabilityId: string, reason: string = 'Not verified'): CapabilityResult {
    return new CapabilityResult(
      capabilityId,
      CapabilityRegistry.inferModule(capabilityId),
      CapabilityStatus.UNKNOWN,
      reason,
      '',
      '',
      '',
      TimeUtil.nowMs(),
      ''
    );
  }

  private static inferModule(capabilityId: string): PlatformModuleType {
    if (capabilityId.startsWith('bluetooth.')) {
      return PlatformModuleType.BLUETOOTH;
    }
    if (capabilityId.startsWith('wifi.')) {
      return PlatformModuleType.WIFI;
    }
    if (capabilityId.startsWith('network.')) {
      return PlatformModuleType.NETWORK;
    }
    if (capabilityId.startsWith('nearlink.')) {
      return PlatformModuleType.NEARLINK;
    }
    return PlatformModuleType.SYSTEM;
  }
}
