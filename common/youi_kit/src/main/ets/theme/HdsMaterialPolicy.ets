import { hdsMaterial, SystemMaterialParams } from '@kit.UIDesignKit';

/** API 26.0.0 — uiMaterial / systemMaterial 入口（WSL ArkUI 沉浸光感）。 */
export const UI_MATERIAL_MIN_SDK_API: number = 26;

export type HdsSystemMaterialEffect = SystemMaterialParams;

/**
 * 按 UI Design Kit 文档的 HDS 沉浸材质策略。
 * 优先 ADAPTIVE，由系统按设备能力选择材质等级。
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
   * 自定义材质等级路径：在 EXQUISITE/GENTLE 前查询设备 IMMERSIVE 支持。
   * 仅在不需要 ADAPTIVE 时使用。
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
