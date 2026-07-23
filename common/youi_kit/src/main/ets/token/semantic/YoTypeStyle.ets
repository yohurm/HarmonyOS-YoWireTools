/**
 * 语义排版 — float.json 为权威数值来源。
 */
export interface YoTypeStyleSpec {
  size: Resource;
  weight: FontWeight;
  family?: string;
}

export class YoTypeStyle {
  static readonly DISPLAY_S: YoTypeStyleSpec = {
    size: $r('app.float.youi_display_s'),
    weight: FontWeight.Bold
  };
  static readonly TITLE_L: YoTypeStyleSpec = {
    size: $r('app.float.youi_title_l'),
    weight: FontWeight.Bold
  };
  static readonly TITLE_M: YoTypeStyleSpec = {
    size: $r('app.float.youi_title_m'),
    weight: FontWeight.Bold
  };
  static readonly TITLE_S: YoTypeStyleSpec = {
    size: $r('app.float.youi_title_s'),
    weight: FontWeight.Bold
  };
  static readonly SUBTITLE_L: YoTypeStyleSpec = {
    size: $r('app.float.youi_subtitle_l'),
    weight: FontWeight.Medium
  };
  static readonly SUBTITLE_M: YoTypeStyleSpec = {
    size: $r('app.float.youi_subtitle_m'),
    weight: FontWeight.Medium
  };
  static readonly SUBTITLE_S: YoTypeStyleSpec = {
    size: $r('app.float.youi_subtitle_s'),
    weight: FontWeight.Medium
  };
  static readonly BODY_L: YoTypeStyleSpec = {
    size: $r('app.float.youi_body_l'),
    weight: FontWeight.Regular
  };
  static readonly BODY_M: YoTypeStyleSpec = {
    size: $r('app.float.youi_body_m'),
    weight: FontWeight.Regular
  };
  static readonly BODY_S: YoTypeStyleSpec = {
    size: $r('app.float.youi_body_s'),
    weight: FontWeight.Regular
  };
  static readonly MONO_M: YoTypeStyleSpec = {
    size: $r('app.float.youi_body_m'),
    weight: FontWeight.Regular,
    family: 'HarmonyOS Sans Mono'
  };
  static readonly MONO_S: YoTypeStyleSpec = {
    size: $r('app.float.youi_body_s'),
    weight: FontWeight.Regular,
    family: 'HarmonyOS Sans Mono'
  };
}
