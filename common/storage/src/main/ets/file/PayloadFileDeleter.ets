import { fileIo } from '@kit.CoreFileKit';
import { StoragePayloadKind, StoragePayloadRef } from '../domain/StoragePayloadRef';
import { PayloadChunkRecord } from '../domain/PayloadChunkRecord';

/**
 * Deletes payload files referenced by storage metadata.
 */
export class PayloadFileDeleter {
  static deleteRef(ref: StoragePayloadRef | undefined): number {
    if (ref === undefined || ref.storageType !== StoragePayloadKind.FILE || ref.filePath.length === 0) {
      return 0;
    }
    return PayloadFileDeleter.deletePath(ref.filePath, ref.length);
  }

  static deleteChunk(chunk: PayloadChunkRecord): number {
    return PayloadFileDeleter.deletePath(chunk.chunkPath, chunk.chunkLength);
  }

  private static deletePath(path: string, byteLength: number): number {
    try {
      fileIo.unlinkSync(path);
      return byteLength;
    } catch (_error) {
      return 0;
    }
  }
}
