import { common } from '@kit.AbilityKit';
import { MonotonicClockRegistry, TaskExecutorRegistry } from 'common_core';
import { AppLogger } from './logging/AppLogger';
import { AppLogTag } from './logging/AppLogTag';
import { CapabilityRegistry } from './capability/CapabilityRegistry';
import { LifecycleCoordinator } from './lifecycle/LifecycleCoordinator';
import { PermissionOrchestrator } from './permission/PermissionOrchestrator';
import { AbilityContextRegistry } from './context/AbilityContextRegistry';
import { PlatformMonotonicClock } from './time/PlatformMonotonicClock';
import { TaskPoolTaskExecutor } from './task/TaskPoolTaskExecutor';

const logger = new AppLogger(AppLogTag.APP);

/**
 * One-shot platform layer bootstrap invoked from EntryAbility.onCreate.
 * Order: context -> monotonic clock -> task executor -> permission -> lifecycle -> capability.
 */
export class PlatformBootstrap {
  private static initialized: boolean = false;

  static initialize(context: common.UIAbilityContext): void {
    if (PlatformBootstrap.initialized) {
      return;
    }
    AbilityContextRegistry.getInstance().bind(context);
    MonotonicClockRegistry.register(new PlatformMonotonicClock());
    TaskExecutorRegistry.register(new TaskPoolTaskExecutor());
    PermissionOrchestrator.getInstance().bindContext(context);
    LifecycleCoordinator.getInstance();
    CapabilityRegistry.getInstance();
    PlatformBootstrap.initialized = true;
    logger.info('platform_bootstrap successful');
  }

  static resetForTest(): void {
    PlatformBootstrap.initialized = false;
  }
}
