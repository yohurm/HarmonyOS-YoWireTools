import { AbilityContextRegistry } from 'common_platform';

/**
 * Helpers for ResourceStr emptiness checks and formatted strings in UI components.
 */
export class UiResourceUtil {
  static hasText(value: ResourceStr): boolean {
    return UiResourceUtil.resolveText(value).length > 0;
  }

  static format(res: Resource, ...args: Array<string | number>): string {
    const context = AbilityContextRegistry.getInstance().get();
    if (context === undefined) {
      return '';
    }
    try {
      return context.resourceManager.getStringSync(res.id, ...args);
    } catch (_error) {
      return '';
    }
  }

  static resolveText(value: ResourceStr): string {
    if (typeof value === 'string') {
      return value;
    }
    const context = AbilityContextRegistry.getInstance().get();
    if (context === undefined) {
      return '';
    }
    try {
      return context.resourceManager.getStringSync(value.id);
    } catch (_error) {
      return '';
    }
  }
}
