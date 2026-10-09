import { pasteboard } from '@kit.BasicServicesKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { Result, ResultError } from 'common_core';
import { NearLinkErrorCodes } from '../../../constants/NearLinkErrorCodes';

export class NearLinkLogExportDataSource {
  static async copyText(text: string): Promise<Result<void>> {
    try {
      const data = pasteboard.createData(pasteboard.MIMETYPE_TEXT_PLAIN, text);
      const board = pasteboard.getSystemPasteboard();
      await board.setData(data);
      return Result.ok(undefined);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(ResultError.fromError(NearLinkErrorCodes.SCAN_FAILED, err));
    }
  }
}
