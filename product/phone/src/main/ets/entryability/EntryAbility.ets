import { AbilityConstant, Configuration, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { window } from '@kit.ArkUI';
import { LifecycleCoordinator, SystemBarThemeCoordinator, UIContextRegistry, WindowMetricsRegistry } from 'common_platform';
import { DebugCoreBootstrap } from 'debug_core';
import { YoLog, YoLogTag } from 'yolog';

const logger = YoLog.tag(YoLogTag.APP);

export default class EntryAbility extends UIAbility {
  private mainWindow: window.Window | undefined = undefined;

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    YoLog.bootstrapFromFilesDir(this.context.filesDir);
    logger.info('Ability onCreate');
  }

  onDestroy(): void {
    logger.info('Ability onDestroy');
    void YoLog.terminate();
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
    logger.info('Ability onWindowStageCreate');
    LifecycleCoordinator.getInstance().onWindowStageCreate('entry');

    void DebugCoreBootstrap.initialize(this.context).then((result) => {
      if (!result.success) {
        logger.error(`DebugCoreBootstrap failed: ${result.error?.message ?? 'unknown'}`);
      } else {
        logger.info('DebugCoreBootstrap initialized');
      }
      windowStage.loadContent('pages/Index', (err) => {
        if (err.code) {
          logger.error(`Failed to load the content. Cause: ${JSON.stringify(err)}`);
          return;
        }
        this.configureMainWindow(windowStage);
        this.bindUiContext(windowStage);
        logger.info('Succeeded in loading the content.');
      });
    });
  }

  onWindowStageDestroy(): void {
    this.mainWindow = undefined;
    LifecycleCoordinator.getInstance().onWindowStageDestroy('entry');
    logger.info('Ability onWindowStageDestroy');
  }

  onForeground(): void {
    LifecycleCoordinator.getInstance().onAppForeground('entry');
    logger.info('Ability onForeground');
  }

  onBackground(): void {
    // LifecycleCoordinator.onAppBackground already flushes YoLog.
    LifecycleCoordinator.getInstance().onAppBackground('entry');
    logger.info('Ability onBackground');
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
      logger.error(`configureMainWindow failed: ${JSON.stringify(err)}`);
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
      logger.error(`bindUiContext failed: ${JSON.stringify(err)}`);
    }
  }
}
