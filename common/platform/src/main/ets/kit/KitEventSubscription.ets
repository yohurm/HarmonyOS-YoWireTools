import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { YoLog, YoLogTag } from 'yolog';

const logger = YoLog.tag(YoLogTag.APP);

/** Platform-level error when HarmonyOS Kit event subscribe/unsubscribe fails. */
export class PlatformErrorCodes {
  static readonly KIT_EVENT_SUBSCRIBE_FAILED: string = 'YW-PLATFORM-1001';
}

/**
 * Generic HarmonyOS Kit event lifecycle helper.
 * Kit on()/off() may throw BusinessError — callers must use subscribe/unsubscribe
 * instead of invoking kit event APIs directly (ArkTS throw-check rule).
 */
export class KitEventSubscription {
  static subscribe(action: () => void, eventName: string = ''): Result<void> {
    try {
      action();
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      if (eventName.length > 0) {
        logger.error(`kit_event_subscribe_failed event=${eventName} code=${err.code} message=${err.message}`);
      }
      return Result.fail(ResultError.fromError(PlatformErrorCodes.KIT_EVENT_SUBSCRIBE_FAILED, err));
    }
  }

  static unsubscribe(action: () => void, eventName: string = ''): void {
    try {
      action();
    } catch (error) {
      const err = error as BusinessError;
      if (eventName.length > 0) {
        logger.warn(`kit_event_unsubscribe_failed event=${eventName} code=${err.code}`);
      }
    }
  }
}
