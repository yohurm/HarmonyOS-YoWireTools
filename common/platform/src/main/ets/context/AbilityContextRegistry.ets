import { common } from '@kit.AbilityKit';

/**
 * Holds the active UIAbilityContext bound during PlatformBootstrap.
 * Feature modules must use this instead of deprecated getContext() in UI components.
 */
export class AbilityContextRegistry {
  private static instance: AbilityContextRegistry | undefined;
  private context: common.UIAbilityContext | undefined;

  static getInstance(): AbilityContextRegistry {
    if (AbilityContextRegistry.instance === undefined) {
      AbilityContextRegistry.instance = new AbilityContextRegistry();
    }
    return AbilityContextRegistry.instance;
  }

  bind(context: common.UIAbilityContext): void {
    this.context = context;
  }

  get(): common.UIAbilityContext | undefined {
    return this.context;
  }
}
