import { LengthMetrics, window } from '@kit.ArkUI';
import {
  HdsNavigationIconItemStyle,
  HdsNavigationTitleBarOptions,
  HdsNavigationTitleBarStyle,
  HdsNavigationTitleStyle,
  HdsTitleBarContentStyle,
  ScrollEffectOptions,
  ScrollEffectType,
  TitleBarContentOptions,
  TitleBarStyleOptions
} from '@kit.UIDesignKit';
import { SystemBarThemeCoordinator } from 'common_platform';
import { HdsMaterialPolicy } from './HdsMaterialPolicy';

/**
 * HdsNavigation 标题栏场景策略（WSL UI Design Kit）。
 *
 * 场景映射（设置动态模糊样式.md + HdsNavigation API）：
 * - 列表/工作台浅色页：COMMON_BLUR + font_primary
 * - 沉浸式图文 hero：IMMERSIVE_GRADIENT_BLUR + font_on_primary → font_primary
 *
 * 禁止在浅色列表页使用 IMMERSIVE_GRADIENT_BLUR 或
 * GRADIENT_BLUR(enableScrollEffect:false)——默认 font_on_primary（白字）。
 */
export enum HdsTitleBarScene {
  LIST_CONTENT = 0,
  HERO_IMMERSIVE = 1
}

export type HdsTitleBarStyle = HdsNavigationTitleBarStyle;
export type HdsTitleBarStyleBundle = TitleBarStyleOptions;
export type HdsSystemBarStyleBundle = window.SystemBarStyle;
export type YoTitleBarContent = TitleBarContentOptions;
export type YoNavigationTitleBarConfig = HdsNavigationTitleBarOptions;

export class HdsTitleBarPolicy {
  /** WSL 官方列表页 originalStyle：显式 font_primary。 */
  static buildPrimaryTitleStyle(): HdsTitleBarStyle {
    return HdsTitleBarPolicy.buildTitleBarStyle(false);
  }
  static resolveScene(immersiveHeroContent: boolean): HdsTitleBarScene {
    return immersiveHeroContent ? HdsTitleBarScene.HERO_IMMERSIVE : HdsTitleBarScene.LIST_CONTENT;
  }

  static buildStyleBundle(
    scene: HdsTitleBarScene,
    scrollable: boolean,
    immersiveTitleBar: boolean
  ): HdsTitleBarStyleBundle {
    const enableScrollEffect = scrollable && immersiveTitleBar;
    const scrollEffectType = scene === HdsTitleBarScene.HERO_IMMERSIVE ?
      ScrollEffectType.IMMERSIVE_GRADIENT_BLUR :
      ScrollEffectType.COMMON_BLUR;
    const scrollEffectOpts: ScrollEffectOptions = {
      enableScrollEffect,
      scrollEffectType,
      blurEffectiveStartOffset: LengthMetrics.vp(0),
      blurEffectiveEndOffset: LengthMetrics.vp(20)
    };
    const bundle: HdsTitleBarStyleBundle = {
      scrollEffectOpts,
      originalStyle: HdsTitleBarPolicy.buildTitleBarStyle(scene === HdsTitleBarScene.HERO_IMMERSIVE)
    };
    if (enableScrollEffect) {
      bundle.scrollEffectStyle = HdsTitleBarPolicy.buildTitleBarStyle(false);
    }
    if (immersiveTitleBar) {
      bundle.systemMaterialEffect = HdsMaterialPolicy.adaptiveEffect();
    }
    return bundle;
  }

  /** L4 权威状态栏色：与 L1 PlatformColorToken 对齐，经 HdsNavigation.systemBarStyle 下发。 */
  static buildSystemBarStyle(colorMode: number): HdsSystemBarStyleBundle {
    return {
      statusBarContentColor: SystemBarThemeCoordinator.resolveContentColor(colorMode)
    };
  }

  static buildHeroSystemBarOriginalStyle(): HdsSystemBarStyleBundle {
    return {
      statusBarContentColor: SystemBarThemeCoordinator.resolveOnPrimaryContentColor()
    };
  }

  private static buildTitleBarStyle(onPrimary: boolean): HdsTitleBarStyle {
    const titleStyle: HdsNavigationTitleStyle = onPrimary ? {
      mainTitleColor: $r('sys.color.font_on_primary'),
      subTitleColor: $r('sys.color.font_on_secondary')
    } : {
      mainTitleColor: $r('sys.color.font_primary'),
      subTitleColor: $r('sys.color.font_secondary')
    };
    const backIconStyle: HdsNavigationIconItemStyle = onPrimary ? {
      iconColor: $r('sys.color.icon_on_primary'),
      backgroundColor: Color.Transparent
    } : {
      iconColor: $r('sys.color.icon_primary'),
      backgroundColor: $r('sys.color.comp_background_tertiary')
    };
    const menuStyle: HdsNavigationIconItemStyle = onPrimary ? {
      iconColor: $r('sys.color.icon_on_primary'),
      backgroundColor: Color.Transparent
    } : {
      iconColor: $r('sys.color.icon_primary'),
      backgroundColor: $r('sys.color.comp_background_tertiary')
    };
    const contentStyle: HdsTitleBarContentStyle = {
      titleStyle,
      menuStyle,
      backIconStyle
    };
    const style: HdsTitleBarStyle = { contentStyle };
    return style;
  }
}
