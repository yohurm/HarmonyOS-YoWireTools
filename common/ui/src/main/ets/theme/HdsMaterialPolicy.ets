import { hdsMaterial, SystemMaterialParams } from '@kit.UIDesignKit';

/** API 26.0.0 — uiMaterial / systemMaterial entry (WSL ArkUI 沉浸光感). */
export const UI_MATERIAL_MIN_SDK_API: number = 26;

export type HdsSystemMaterialEffect = SystemMaterialParams;

/**
 * HDS immersive material policy per UI Design Kit docs.
 * Prefer ADAPTIVE so the system selects material level by device capability.
 */
export class HdsMaterialPolicy {
  static adaptiveEffect(): HdsSystemMaterialEffect {
    const effect: HdsSystemMaterialEffect = {
      materialType: hdsMaterial.MaterialType.ADAPTIVE,
      materialLevel: hdsMaterial.MaterialLevel.ADAPTIVE
    };
    return effect;
  }

  /**
   * Custom material level path: query device IMMERSIVE support before EXQUISITE/GENTLE.
   * Only use when ADAPTIVE is not desired.
   */
  static resolveCustomLevel(
    preferred: hdsMaterial.MaterialLevel = hdsMaterial.MaterialLevel.EXQUISITE
  ): hdsMaterial.MaterialLevel {
    const types: Array<hdsMaterial.MaterialType> = hdsMaterial.getSystemMaterialTypes();
    if (types.indexOf(hdsMaterial.MaterialType.IMMERSIVE) < 0) {
      return hdsMaterial.MaterialLevel.SMOOTH;
    }
    return preferred;
  }

  static supportsImmersiveMaterial(): boolean {
    return hdsMaterial.getSystemMaterialTypes().length > 0;
  }
}
