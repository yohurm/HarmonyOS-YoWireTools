/**
 * Payload chunk metadata mapped to debug_payload_chunk table.
 */
export class PayloadChunkRecord {
  readonly id: string;
  readonly sessionId: string;
  readonly chunkPath: string;
  readonly chunkIndex: number;
  readonly chunkOffset: number;
  readonly chunkLength: number;
  readonly sha256: string;
  readonly createdAtMs: number;

  constructor(
    id: string,
    sessionId: string,
    chunkPath: string,
    chunkIndex: number,
    chunkOffset: number,
    chunkLength: number,
    sha256: string,
    createdAtMs: number
  ) {
    this.id = id;
    this.sessionId = sessionId;
    this.chunkPath = chunkPath;
    this.chunkIndex = chunkIndex;
    this.chunkOffset = chunkOffset;
    this.chunkLength = chunkLength;
    this.sha256 = sha256;
    this.createdAtMs = createdAtMs;
  }
}
