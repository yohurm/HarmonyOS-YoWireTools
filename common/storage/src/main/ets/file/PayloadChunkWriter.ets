import { common } from '@kit.AbilityKit';
import { fileIo } from '@kit.CoreFileKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { EncodingUtil, IdGenerator, Result, ResultError, TimeUtil } from 'common_core';
import { PayloadChunkRecord } from '../domain/PayloadChunkRecord';
import { StoragePayloadKind, StoragePayloadRef } from '../domain/StoragePayloadRef';
import { StorageConstants } from '../constants/StorageConstants';
import { StoreErrorCodes } from '../constants/StoreErrorCodes';
import { StoragePaths } from './StoragePaths';
import { PayloadStoreResult } from './PayloadStoreResult';

/**
 * Writes log payload bytes to inline ref or chunked file.
 */
export class PayloadChunkWriter {
  private readonly context: common.Context;
  private readonly chunkCounters: Map<string, number> = new Map();

  constructor(context: common.Context) {
    this.context = context;
  }

  async store(sessionId: string, payload: Uint8Array): Promise<Result<PayloadStoreResult>> {
    if (payload.length <= StorageConstants.INLINE_PAYLOAD_THRESHOLD_BYTES) {
      const base64 = EncodingUtil.bytesToBase64(payload);
      const ref = new StoragePayloadRef(StoragePayloadKind.INLINE, payload.length, base64);
      return Result.ok(new PayloadStoreResult(ref));
    }

    let fd: number | undefined;
    try {
      const chunkIndex = this.nextChunkIndex(sessionId);
      const dir = StoragePaths.payloadSessionDir(this.context, sessionId);
      await this.ensureDir(dir);
      const fileName = StoragePaths.chunkFileName(chunkIndex);
      const filePath = `${dir}/${fileName}`;
      const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
      fd = file.fd;
      fileIo.writeSync(file.fd, payload.buffer);
      const chunkRecord = new PayloadChunkRecord(
        IdGenerator.next('chunk'),
        sessionId,
        filePath,
        chunkIndex,
        0,
        payload.length,
        '',
        TimeUtil.nowMs()
      );
      const ref = new StoragePayloadRef(
        StoragePayloadKind.FILE,
        payload.length,
        '',
        chunkRecord.chunkPath,
        chunkRecord.chunkOffset,
        chunkRecord.sha256
      );
      return Result.ok(new PayloadStoreResult(ref, chunkRecord));
    } catch (error) {
      const err = error as BusinessError;
      return Result.fail(new ResultError(StoreErrorCodes.FILE_WRITE_FAILED, err.message));
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

  private nextChunkIndex(sessionId: string): number {
    const current = this.chunkCounters.get(sessionId) ?? 0;
    const next = current + 1;
    this.chunkCounters.set(sessionId, next);
    return next;
  }

  private async ensureDir(path: string): Promise<void> {
    try {
      fileIo.mkdirSync(path, true);
    } catch (_error) {
      // Directory may already exist.
    }
  }
}
