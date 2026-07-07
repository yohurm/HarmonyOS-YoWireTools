import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { EncodingUtil, Result, ResultError } from 'common_core';
import { StoragePayloadKind, StoragePayloadRef } from '../domain/StoragePayloadRef';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';

/**
 * Reads payload bytes from inline ref or chunked file.
 */
export class PayloadFileReader {
  async read(ref: StoragePayloadRef): Promise<Result<Uint8Array>> {
    if (ref.storageType === StoragePayloadKind.INLINE) {
      if (ref.inlineBytesBase64.length === 0) {
        return Result.ok(new Uint8Array(0));
      }
      const decoded = EncodingUtil.base64ToBytes(ref.inlineBytesBase64);
      if (!decoded.success) {
        return Result.fail(decoded.error ?? new ResultError(StoreErrorCodes.FILE_READ_FAILED, 'decode failed'));
      }
      return Result.ok(decoded.getOrThrow());
    }
    if (ref.filePath.length === 0) {
      return Result.fail(new ResultError(StoreErrorCodes.FILE_READ_FAILED, 'Missing file path'));
    }
    let fd: number | undefined;
    try {
      const file = fileIo.openSync(ref.filePath, fileIo.OpenMode.READ_ONLY);
      fd = file.fd;
      const buffer = new ArrayBuffer(ref.length);
      fileIo.readSync(file.fd, buffer, { offset: ref.offset, length: ref.length });
      return Result.ok(new Uint8Array(buffer));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.FILE_READ_FAILED, err.message));
    } finally {
      if (fd !== undefined) {
        try {
          fileIo.closeSync(fd);
        } catch (_closeError) {
          // Best-effort close on failure path.
        }
      }
    }
  }
}
