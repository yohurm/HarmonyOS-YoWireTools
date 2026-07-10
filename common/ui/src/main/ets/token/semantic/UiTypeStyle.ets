/**
 * Semantic typography — float.json is the authoritative numeric source.
 */
export interface UiTypeStyleSpec {
  size: Resource;
  weight: FontWeight;
  family?: string;
}

export class UiTypeStyle {
  static readonly DISPLAY_S: UiTypeStyleSpec = {
    size: $r('app.float.ui_display_s'),
    weight: FontWeight.Bold
  };
  static readonly TITLE_L: UiTypeStyleSpec = {
    size: $r('app.float.ui_title_l'),
    weight: FontWeight.Bold
  };
  static readonly TITLE_M: UiTypeStyleSpec = {
    size: $r('app.float.ui_title_m'),
    weight: FontWeight.Bold
  };
  static readonly TITLE_S: UiTypeStyleSpec = {
    size: $r('app.float.ui_title_s'),
    weight: FontWeight.Bold
  };
  static readonly SUBTITLE_L: UiTypeStyleSpec = {
    size: $r('app.float.ui_subtitle_l'),
    weight: FontWeight.Medium
  };
  static readonly SUBTITLE_M: UiTypeStyleSpec = {
    size: $r('app.float.ui_subtitle_m'),
    weight: FontWeight.Medium
  };
  static readonly SUBTITLE_S: UiTypeStyleSpec = {
    size: $r('app.float.ui_subtitle_s'),
    weight: FontWeight.Medium
  };
  static readonly BODY_L: UiTypeStyleSpec = {
    size: $r('app.float.ui_body_l'),
    weight: FontWeight.Regular
  };
  static readonly BODY_M: UiTypeStyleSpec = {
    size: $r('app.float.ui_body_m'),
    weight: FontWeight.Regular
  };
  static readonly BODY_S: UiTypeStyleSpec = {
    size: $r('app.float.ui_body_s'),
    weight: FontWeight.Regular
  };
  static readonly MONO_M: UiTypeStyleSpec = {
    size: $r('app.float.ui_body_m'),
    weight: FontWeight.Regular,
    family: 'HarmonyOS Sans Mono'
  };
  static readonly MONO_S: UiTypeStyleSpec = {
    size: $r('app.float.ui_body_s'),
    weight: FontWeight.Regular,
    family: 'HarmonyOS Sans Mono'
  };
}
