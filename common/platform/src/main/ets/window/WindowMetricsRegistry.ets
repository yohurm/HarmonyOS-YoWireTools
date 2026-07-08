import { AppStorageV2, window } from '@kit.ArkUI';
import { WindowMetricsState } from './WindowMetricsState';

const STORAGE_KEY = 'yo_window_metrics';

/**
 * Binds main-window size and system avoid areas to WindowMetricsState.
 * EntryAbility calls bind() once UIContext is ready.
 */
export class WindowMetricsRegistry {
  static connect(): WindowMetricsState {
    return AppStorageV2.connect(WindowMetricsState, STORAGE_KEY, (): WindowMetricsState => new WindowMetricsState())!;
  }

  static updateColorMode(colorMode: number): void {
    WindowMetricsRegistry.connect().updateColorMode(colorMode);
  }

  static bind(mainWindow: window.Window, uiContext: UIContext): void {
    const state = WindowMetricsRegistry.connect();
    WindowMetricsRegistry.syncSize(mainWindow, uiContext, state);
    WindowMetricsRegistry.syncAvoidAreas(mainWindow, uiContext, state);

    try {
      mainWindow.on('windowSizeChange', (size: window.Size) => {
        state.updateSize(uiContext.px2vp(size.width), uiContext.px2vp(size.height));
      });
    } catch (_error) {
    }

    try {
      mainWindow.on('avoidAreaChange', (options: window.AvoidAreaOptions) => {
        if (options.type === window.AvoidAreaType.TYPE_SYSTEM) {
          const navigation = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
          state.updateAvoidAreas(uiContext, options.area, navigation);
        } else if (options.type === window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR) {
          const system = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
          state.updateAvoidAreas(uiContext, system, options.area);
        }
      });
    } catch (_error) {
    }
  }

  private static syncSize(mainWindow: window.Window, uiContext: UIContext, state: WindowMetricsState): void {
    try {
      const rect = mainWindow.getWindowProperties().windowRect;
      state.updateSize(uiContext.px2vp(rect.width), uiContext.px2vp(rect.height));
    } catch (_error) {
    }
  }

  private static syncAvoidAreas(mainWindow: window.Window, uiContext: UIContext, state: WindowMetricsState): void {
    try {
      const system = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_SYSTEM);
      const navigation = mainWindow.getWindowAvoidArea(window.AvoidAreaType.TYPE_NAVIGATION_INDICATOR);
      state.updateAvoidAreas(uiContext, system, navigation);
    } catch (_error) {
    }
  }
}
