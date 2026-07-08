import { ConfigurationConstant } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { WindowWidthBreakpoint, WindowWidthBreakpointUtil } from './WindowWidthBreakpoint';

/**
 * Application-wide reactive window metrics (AppStorageV2).
 * Width drives responsive breakpoints; avoid insets drive immersive padding.
 */
@ObservedV2
export class WindowMetricsState {
  @Trace widthVp: number = 0;
  @Trace heightVp: number = 0;
  @Trace breakpoint: WindowWidthBreakpoint = WindowWidthBreakpoint.COMPACT;
  @Trace systemTopInsetVp: number = 0;
  @Trace navigationBottomInsetVp: number = 0;
  @Trace colorMode: number = ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;

  updateSize(widthVp: number, heightVp: number): void {
    this.widthVp = widthVp;
    this.heightVp = heightVp;
    this.breakpoint = WindowWidthBreakpointUtil.resolve(widthVp);
  }

  updateAvoidAreas(uiContext: UIContext, systemArea: window.AvoidArea,
    navigationArea: window.AvoidArea): void {
    this.systemTopInsetVp = uiContext.px2vp(systemArea.topRect.height);
    this.navigationBottomInsetVp = uiContext.px2vp(navigationArea.bottomRect.height);
  }

  updateColorMode(colorMode: number): void {
    this.colorMode = colorMode;
  }
}
