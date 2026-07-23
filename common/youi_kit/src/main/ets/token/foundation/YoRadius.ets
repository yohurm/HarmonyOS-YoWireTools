/**
 * 基础圆角 Token。
 *
 * 对齐 HarmonyOS 设计规范「圆角参数」常用尺寸：
 * - 4vp  系统通用超小圆角 → 标签 / 角标 / 状态标识
 * - 8vp  系统通用小圆角   → 图片 / 图标 / 列表内模块
 * - 16vp 系统通用圆角     → 通知卡片 / 内容容器
 * - 20vp 系统通用大圆角   → 按钮 / 菜单 / 选项卡
 * - 32vp 系统通用超大圆角 → 半模态 / 弹出框
 *
 * 系统 Token 映射（子集）：
 * XS↔level2(4) SMALL↔level4(8) MEDIUM↔level8(16)
 * LARGE↔level10(20) XLARGE↔level16(32)
 *
 * 规则：同层级同圆角；视觉层级越高 → 圆角越大。
 * 组件须消费 YoCardToken / YoButtonToken / YoMenuToken — 禁止硬编码 vp。
 */
export class YoRadius {
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
  /** 仅用于胶囊 / 圆形元素。 */
  static readonly FULL: number = 999;
}
