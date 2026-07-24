/**
 * 语义色 Token — 三层模型（foundation → semantic → component）。
 * base/dark color.json 中的资源名须保持对称。
 */
export class YoColor {
  // 品牌与交互
  static readonly BRAND_PRIMARY: Resource = $r('app.color.youi_primary');
  static readonly BRAND_PRIMARY_PRESSED: Resource = $r('app.color.youi_primary_pressed');
  static readonly BRAND_PRIMARY_DISABLED: Resource = $r('app.color.youi_brand_primary_disabled');
  static readonly ON_BRAND_PRIMARY: Resource = $r('app.color.youi_text_inverse');
  static readonly INTERACTIVE_HOVER: Resource = $r('app.color.youi_interactive_hover');
  static readonly INTERACTIVE_PRESSED: Resource = $r('app.color.youi_interactive_pressed');
  static readonly INTERACTIVE_FOCUSED: Resource = $r('app.color.youi_interactive_focused');
  static readonly INTERACTIVE_SELECTED: Resource = $r('app.color.youi_surface_selected');

  // 文本与图标
  static readonly TEXT_PRIMARY: Resource = $r('app.color.youi_text_primary');
  static readonly TEXT_SECONDARY: Resource = $r('app.color.youi_text_secondary');
  static readonly TEXT_TERTIARY: Resource = $r('app.color.youi_text_tertiary');
  static readonly TEXT_DISABLED: Resource = $r('app.color.youi_text_disabled');
  static readonly TEXT_ON_PRIMARY: Resource = $r('app.color.youi_text_inverse');
  static readonly ICON_PRIMARY: Resource = $r('app.color.youi_icon_primary');
  static readonly ICON_SECONDARY: Resource = $r('app.color.youi_icon_secondary');
  static readonly ICON_TERTIARY: Resource = $r('app.color.youi_icon_tertiary');
  static readonly ICON_DISABLED: Resource = $r('app.color.youi_icon_disabled');
  static readonly ICON_ON_PRIMARY: Resource = $r('app.color.youi_text_inverse');

  // 背景与表面
  static readonly BACKGROUND_PRIMARY: Resource = $r('app.color.youi_background');
  static readonly BACKGROUND_SECONDARY: Resource = $r('app.color.youi_background_secondary');
  static readonly SURFACE_CARD: Resource = $r('app.color.youi_surface');
  static readonly SURFACE_RAISED: Resource = $r('app.color.youi_comp_raised');
  static readonly SURFACE_INPUT: Resource = $r('app.color.youi_surface_input');
  static readonly SURFACE_SELECTED: Resource = $r('app.color.youi_surface_selected');
  static readonly EMPHASIZE_TERTIARY: Resource = $r('app.color.youi_emphasize_tertiary');
  static readonly SURFACE_OVERLAY: Resource = $r('app.color.youi_comp_raised');
  static readonly SCRIM: Resource = $r('app.color.youi_scrim');

  // 边框与分隔线
  static readonly BORDER_PRIMARY: Resource = $r('app.color.youi_border');
  static readonly BORDER_SECONDARY: Resource = $r('app.color.youi_divider');
  static readonly BORDER_FOCUSED: Resource = $r('app.color.youi_border_focused');
  static readonly DIVIDER: Resource = $r('app.color.youi_divider');

  // 状态色
  static readonly ERROR: Resource = $r('app.color.youi_error');
  static readonly ERROR_CONTAINER: Resource = $r('app.color.youi_error_container');
  static readonly ON_ERROR_CONTAINER: Resource = $r('app.color.youi_on_error_container');
  static readonly WARNING: Resource = $r('app.color.youi_warning');
  static readonly WARNING_CONTAINER: Resource = $r('app.color.youi_warning_container');
  static readonly ON_WARNING_CONTAINER: Resource = $r('app.color.youi_on_warning_container');
  static readonly SUCCESS: Resource = $r('app.color.youi_success');
  static readonly SUCCESS_CONTAINER: Resource = $r('app.color.youi_success_container');
  static readonly ON_SUCCESS_CONTAINER: Resource = $r('app.color.youi_on_success_container');
  static readonly INFO: Resource = $r('app.color.youi_info');
  static readonly INFO_CONTAINER: Resource = $r('app.color.youi_info_container');
  static readonly ON_INFO_CONTAINER: Resource = $r('app.color.youi_on_info_container');

  // Toast（深色半透明背板，浅/深色主题保持一致，对齐 Android TOAST_BACKGROUND）
  static readonly TOAST_BACKGROUND: Resource = $r('app.color.youi_toast_background');
  static readonly TOAST_TEXT: Resource = $r('app.color.youi_toast_text');
}
