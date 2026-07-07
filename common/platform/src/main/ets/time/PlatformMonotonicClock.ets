import { systemDateTime } from '@kit.BasicServicesKit';
import { IMonotonicClock } from 'common_core';

/**
 * Platform monotonic clock backed by systemDateTime.getUptime(ACTIVE) per WSL systemDateTime API.
 */
export class PlatformMonotonicClock implements IMonotonicClock {
  nowMs(): number {
    try {
      return systemDateTime.getUptime(systemDateTime.TimeType.ACTIVE, false);
    } catch (_error) {
      return Date.now();
    }
  }
}
