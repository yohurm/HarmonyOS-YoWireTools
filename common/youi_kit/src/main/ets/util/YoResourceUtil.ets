import { AbilityContextRegistry } from 'common_platform';

/**
 * UI 组件中 ResourceStr 空值判断与格式化字符串辅助方法。
 */
export class YoResourceUtil {
  static hasText(value: ResourceStr): boolean {
    return YoResourceUtil.resolveText(value).length > 0;
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
