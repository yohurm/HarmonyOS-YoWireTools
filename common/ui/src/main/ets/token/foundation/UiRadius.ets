/**
 * Foundation corner-radius tokens.
 *
 * Aligned with HarmonyOS design guide「圆角参数」common sizes:
 * - 4vp  系统通用超小圆角 → 标签 / 角标 / 状态标识
 * - 8vp  系统通用小圆角   → 图片 / 图标 / 列表内模块
 * - 16vp 系统通用圆角     → 通知卡片 / 内容容器
 * - 20vp 系统通用大圆角   → 按钮 / 菜单 / 选项卡
 * - 32vp 系统通用超大圆角 → 半模态 / 弹出框
 *
 * System token map (subset):
 * XS↔level2(4) SMALL↔level4(8) MEDIUM↔level8(16)
 * LARGE↔level10(20) XLARGE↔level16(32)
 *
 * Rules: same layer same radius; higher visual hierarchy → larger radius.
 * Components must consume CardToken / ButtonToken / MenuToken — never hardcode vp.
 */
export class UiRadius {
  static readonly NONE: number = 0;
  /** 4vp — 标签、角标、状态标识 */
  static readonly XS: number = 4;
  /** 8vp — 图标、列表内小模块 */
  static readonly SMALL: number = 8;
  /** 16vp — 内容卡片、设备行卡片、通知容器 */
  static readonly MEDIUM: number = 16;
  /** 20vp — 按钮、菜单 */
  static readonly LARGE: number = 20;
  /** 32vp — 半模态、弹出框 */
  static readonly XLARGE: number = 32;
  /** Capsule / circular elements only. */
  static readonly FULL: number = 999;
}
