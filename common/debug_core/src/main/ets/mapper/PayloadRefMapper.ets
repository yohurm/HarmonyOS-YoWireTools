import { StoragePayloadKind, StoragePayloadRef } from 'common_storage';
import { PayloadRef, PayloadRefKind } from '../domain/model/PayloadRef';

/**
 * Maps domain PayloadRef <-> storage StoragePayloadRef.
 */
export class PayloadRefMapper {
  static toDomain(ref: StoragePayloadRef | undefined): PayloadRef | undefined {
    if (ref === undefined) {
      return undefined;
    }
    const kind = ref.storageType === StoragePayloadKind.FILE ? PayloadRefKind.FILE : PayloadRefKind.INLINE;
    return new PayloadRef(kind, ref.length, ref.inlineBytesBase64, ref.filePath, ref.offset, ref.sha256);
  }

  static toStorage(ref: PayloadRef | undefined): StoragePayloadRef | undefined {
    if (ref === undefined) {
      return undefined;
    }
    const storageType = ref.kind === PayloadRefKind.FILE ? StoragePayloadKind.FILE : StoragePayloadKind.INLINE;
    return new StoragePayloadRef(storageType, ref.length, ref.inlineBytesBase64, ref.filePath, ref.offset, ref.sha256);
  }
}
