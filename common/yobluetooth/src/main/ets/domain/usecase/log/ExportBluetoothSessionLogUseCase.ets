import { Result, ResultError } from 'common_core';
import { AbilityContextRegistry } from 'common_platform';
import { ExportFormat, ExportOptions, LogExportService } from 'common_storage';
import { BluetoothErrorCodes } from '../../../constants/BluetoothErrorCodes';

/**
 * Exports an existing session log. Clearing the on-screen buffer does not call this
 * and does not delete a file this use case already wrote.
 * There is no HCI capture file.
 */
export class ExportBluetoothSessionLogUseCase {
  async execute(sessionId: string): Promise<Result<string>> {
    const context = AbilityContextRegistry.getInstance().get();
    if (context === undefined) {
      return Result.fail(new ResultError(BluetoothErrorCodes.SPP_IO_ERROR, 'Ability context missing'));
    }
    const service = new LogExportService(context);
    const options = new ExportOptions(
      ExportFormat.JSON,
      true,
      false,
      false,
      sessionId
    );
    return service.exportLogs(options);
  }
}
