/**
 * Semantic color tokens — three-layer model (foundation → semantic → component).
 * Resource names in base/dark color.json must stay symmetric.
 */
export class UiColor {
  // Brand & interactive
  static readonly BRAND_PRIMARY: Resource = $r('app.color.ui_primary');
  static readonly BRAND_PRIMARY_PRESSED: Resource = $r('app.color.ui_primary_pressed');
  static readonly BRAND_PRIMARY_DISABLED: Resource = $r('app.color.ui_brand_primary_disabled');
  static readonly ON_BRAND_PRIMARY: Resource = $r('app.color.ui_text_inverse');
  static readonly INTERACTIVE_HOVER: Resource = $r('app.color.ui_interactive_hover');
  static readonly INTERACTIVE_PRESSED: Resource = $r('app.color.ui_interactive_pressed');
  static readonly INTERACTIVE_FOCUSED: Resource = $r('app.color.ui_interactive_focused');
  static readonly INTERACTIVE_SELECTED: Resource = $r('app.color.ui_surface_selected');

  // Text & icon
  static readonly TEXT_PRIMARY: Resource = $r('app.color.ui_text_primary');
  static readonly TEXT_SECONDARY: Resource = $r('app.color.ui_text_secondary');
  static readonly TEXT_TERTIARY: Resource = $r('app.color.ui_text_tertiary');
  static readonly TEXT_DISABLED: Resource = $r('app.color.ui_text_disabled');
  static readonly TEXT_ON_PRIMARY: Resource = $r('app.color.ui_text_inverse');
  static readonly ICON_PRIMARY: Resource = $r('app.color.ui_icon_primary');
  static readonly ICON_SECONDARY: Resource = $r('app.color.ui_icon_secondary');
  static readonly ICON_TERTIARY: Resource = $r('app.color.ui_icon_tertiary');
  static readonly ICON_DISABLED: Resource = $r('app.color.ui_icon_disabled');
  static readonly ICON_ON_PRIMARY: Resource = $r('app.color.ui_text_inverse');

  // Background & surface
  static readonly BACKGROUND_PRIMARY: Resource = $r('app.color.ui_background');
  static readonly BACKGROUND_SECONDARY: Resource = $r('app.color.ui_background_secondary');
  static readonly SURFACE_CARD: Resource = $r('app.color.ui_surface');
  static readonly SURFACE_RAISED: Resource = $r('app.color.ui_comp_raised');
  static readonly SURFACE_INPUT: Resource = $r('app.color.ui_surface_input');
  static readonly SURFACE_SELECTED: Resource = $r('app.color.ui_surface_selected');
  static readonly EMPHASIZE_TERTIARY: Resource = $r('app.color.ui_emphasize_tertiary');
  static readonly SURFACE_OVERLAY: Resource = $r('app.color.ui_comp_raised');
  static readonly SCRIM: Resource = $r('app.color.ui_scrim');

  // Border & divider
  static readonly BORDER_PRIMARY: Resource = $r('app.color.ui_border');
  static readonly BORDER_SECONDARY: Resource = $r('app.color.ui_divider');
  static readonly BORDER_FOCUSED: Resource = $r('app.color.ui_border_focused');
  static readonly DIVIDER: Resource = $r('app.color.ui_divider');

  // Status
  static readonly ERROR: Resource = $r('app.color.ui_error');
  static readonly ERROR_CONTAINER: Resource = $r('app.color.ui_error_container');
  static readonly ON_ERROR_CONTAINER: Resource = $r('app.color.ui_on_error_container');
  static readonly WARNING: Resource = $r('app.color.ui_warning');
  static readonly WARNING_CONTAINER: Resource = $r('app.color.ui_warning_container');
  static readonly ON_WARNING_CONTAINER: Resource = $r('app.color.ui_on_warning_container');
  static readonly SUCCESS: Resource = $r('app.color.ui_success');
  static readonly SUCCESS_CONTAINER: Resource = $r('app.color.ui_success_container');
  static readonly ON_SUCCESS_CONTAINER: Resource = $r('app.color.ui_on_success_container');
  static readonly INFO: Resource = $r('app.color.ui_info');
  static readonly INFO_CONTAINER: Resource = $r('app.color.ui_info_container');
  static readonly ON_INFO_CONTAINER: Resource = $r('app.color.ui_on_info_container');
}
