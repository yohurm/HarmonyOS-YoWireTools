import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { LifecycleCoordinator, SystemBarThemeCoordinator, UIContextRegistry, WindowMetricsRegistry } from 'common_platform';
import { DebugCoreBootstrap } from 'debug_core';

const DOMAIN = 0x0000;
const TAG = 'EntryAbility';

export default class EntryAbility extends UIAbility {
  private mainWindow: window.Window | undefined = undefined;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(DOMAIN, TAG, 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, TAG, 'Ability onDestroy');
  }

  onConfigurationUpdate(newConfig: Configuration): void {
    if (this.mainWindow === undefined) {
      return;
    }
    const colorMode = newConfig.colorMode ?? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
    SystemBarThemeCoordinator.applyToWindow(this.mainWindow, colorMode);
    WindowMetricsRegistry.updateColorMode(colorMode);
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageCreate');
    LifecycleCoordinator.getInstance().onWindowStageCreate('entry');

    void DebugCoreBootstrap.initialize(this.context).then((result) => {
      if (!result.success) {
        hilog.error(DOMAIN, TAG, 'DebugCoreBootstrap failed: %{public}s', result.error?.message ?? 'unknown');
      } else {
        hilog.info(DOMAIN, TAG, 'DebugCoreBootstrap initialized');
      }
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          hilog.error(DOMAIN, TAG, 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
          return;
        }
        this.configureMainWindow(windowStage);
        this.bindUiContext(windowStage);
        hilog.info(DOMAIN, TAG, 'Succeeded in loading the content.');
      });
    });
  }

  onWindowStageDestroy(): void {
    this.mainWindow = undefined;
    LifecycleCoordinator.getInstance().onWindowStageDestroy('entry');
    hilog.info(DOMAIN, TAG, 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    LifecycleCoordinator.getInstance().onAppForeground('entry');
    hilog.info(DOMAIN, TAG, 'Ability onForeground');
  }

  onBackground(): void {
    LifecycleCoordinator.getInstance().onAppBackground('entry');
    hilog.info(DOMAIN, TAG, 'Ability onBackground');
  }

  private configureMainWindow(windowStage: window.WindowStage): void {
    try {
      const mainWindow = windowStage.getMainWindowSync();
      this.mainWindow = mainWindow;
      void mainWindow.setWindowLayoutFullScreen(true);
      const colorMode = this.context.config.colorMode ?? ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT;
      SystemBarThemeCoordinator.applyToWindow(mainWindow, colorMode);
      WindowMetricsRegistry.updateColorMode(colorMode);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'configureMainWindow failed: %{public}s', JSON.stringify(err));
    }
  }

  private bindUiContext(windowStage: window.WindowStage): void {
    try {
      const mainWindow = windowStage.getMainWindowSync();
      this.mainWindow = mainWindow;
      const uiContext = mainWindow.getUIContext();
      UIContextRegistry.getInstance().bind(uiContext);
      WindowMetricsRegistry.bind(mainWindow, uiContext);
    } catch (err) {
      hilog.error(DOMAIN, TAG, 'bindUiContext failed: %{public}s', JSON.stringify(err));
    }
  }
}
