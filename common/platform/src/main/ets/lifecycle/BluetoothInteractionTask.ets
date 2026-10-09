import { backgroundTaskManager } from '@kit.BackgroundTasksKit';
import { common, wantAgent } from '@kit.AbilityKit';
import { Result, ResultError } from 'common_core';
import { YoLog, YoLogTag } from 'yolog';

const logger = YoLog.tag(YoLogTag.LIFE);

/**
 * Continuous task for an already-connected Bluetooth session.
 * Declared background mode is bluetoothInteraction.
 */
export class BluetoothInteractionTask {
  private running: boolean = false;

  isRunning(): boolean {
    return this.running;
  }

  async start(context: common.UIAbilityContext): Promise<Result<void>> {
    if (this.running) {
      return Result.ok(undefined);
    }
    try {
      const info: wantAgent.WantAgentInfo = {
        wants: [
          {
            bundleName: context.abilityInfo.bundleName,
            abilityName: context.abilityInfo.name
          }
        ],
        actionType: wantAgent.OperationType.START_ABILITY,
        requestCode: 0,
        wantAgentFlags: [wantAgent.WantAgentFlags.UPDATE_PRESENT]
      };
      const agent = await wantAgent.getWantAgent(info);
      await backgroundTaskManager.startBackgroundRunning(
        context,
        backgroundTaskManager.BackgroundMode.BLUETOOTH_INTERACTION,
        agent
      );
      this.running = true;
      logger.info('bluetooth_interaction_task started');
      return Result.ok(undefined);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'background task failed';
      logger.error(`bluetooth_interaction_task failed ${message}`);
      return Result.fail(new ResultError('YW-LIFE-1001', message));
    }
  }

  async stop(context: common.UIAbilityContext): Promise<Result<void>> {
    if (!this.running) {
      return Result.ok(undefined);
    }
    try {
      await backgroundTaskManager.stopBackgroundRunning(context);
      this.running = false;
      logger.info('bluetooth_interaction_task stopped');
      return Result.ok(undefined);
    } catch (error) {
      const message = error instanceof Error ? error.message : 'background task stop failed';
      this.running = false;
      return Result.fail(new ResultError('YW-LIFE-1002', message));
    }
  }
}
