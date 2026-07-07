import { PayloadChunkRecord } from '../domain/PayloadChunkRecord';
import { StoragePayloadRef } from '../domain/StoragePayloadRef';

/**
 * Result of storing payload bytes: storage ref plus optional chunk metadata row.
 */
export class PayloadStoreResult {
  readonly payloadRef: StoragePayloadRef;
  readonly chunkRecord: PayloadChunkRecord | undefined;

  constructor(payloadRef: StoragePayloadRef, chunkRecord?: PayloadChunkRecord) {
    this.payloadRef = payloadRef;
    this.chunkRecord = chunkRecord;
  }
}
