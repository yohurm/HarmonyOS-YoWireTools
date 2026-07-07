import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { EncodingUtil, Result, ResultError } from 'common_core';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';
import { StoragePaths } from './StoragePaths';

/**
 * Writes export artifacts to files/export directory.
 */
export class ExportFileWriter {
  private readonly context: common.Context;

  constructor(context: common.Context) {
    this.context = context;
  }

  async writeText(fileName: string, content: string, stamp?: string): Promise<Result<string>> {
    try {
      const dir = StoragePaths.exportSessionDir(this.context, stamp);
      fileIo.mkdirSync(dir, true);
      const filePath = `${dir}/${fileName}`;
      const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE | fileIo.OpenMode.TRUNC);
      const bytes = EncodingUtil.stringToUtf8Bytes(content);
      fileIo.writeSync(file.fd, bytes.buffer);
      fileIo.closeSync(file.fd);
      return Result.ok(filePath);
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.EXPORT_FAILED, err.message));
    }
  }
}
