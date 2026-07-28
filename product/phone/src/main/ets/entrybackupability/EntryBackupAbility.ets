import { BackupExtensionAbility, BundleVersion } from '@kit.CoreFileKit';
import { YoLog, YoLogTag } from 'yolog';

const logger = YoLog.tag(YoLogTag.APP);

export default class EntryBackupAbility extends BackupExtensionAbility {
  async onBackup() {
    logger.info('onBackup ok');
    await Promise.resolve();
  }

  async onRestore(bundleVersion: BundleVersion) {
    logger.info(`onRestore ok ${JSON.stringify(bundleVersion)}`);
    await Promise.resolve();
  }
}
