import { YoLogConfig } from '../config/YoLogConfig';
import { YoLog } from '../api/YoLog';

/**
 * Ability-lifecycle helpers for YoLog.
 */
export class YoLogBootstrap {
  static initialize(filesDir: string, debugBuild: boolean = true): void {
    const config = debugBuild ? YoLogConfig.forDebug(filesDir) : YoLogConfig.forRelease(filesDir);
    YoLog.bootstrap(config);
  }

  static async onBackground(): Promise<void> {
    await YoLog.flush();
  }

  static async onDestroy(): Promise<void> {
    await YoLog.terminate();
  }
}
